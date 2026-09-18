const assert = require('node:assert/strict');
const { spawnSync } = require('node:child_process');
const path = require('node:path');
const test = require('node:test');

const app = require('./app');

async function withServer(callback) {
  const server = app.listen(0, '127.0.0.1');
  await new Promise((resolve) => server.once('listening', resolve));
  const { port } = server.address();

  try {
    await callback(`http://127.0.0.1:${port}`);
  } finally {
    await new Promise((resolve, reject) => {
      server.close((error) => (error ? reject(error) : resolve()));
    });
  }
}

function sessionCookie(response) {
  return response.headers.get('set-cookie').split(';', 1)[0];
}

test('new environment form includes a session-backed CSRF token', async () => {
  await withServer(async (baseUrl) => {
    const response = await fetch(`${baseUrl}/new-environment`);
    const body = await response.text();

    assert.equal(response.status, 200);
    assert.match(body, /name="csrfToken" value="[^"]+"/);
    assert.match(response.headers.get('set-cookie'), /HttpOnly/);
  });
});

test('new environment form renders an SSO group field for each access role', async () => {
  await withServer(async (baseUrl) => {
    const response = await fetch(`${baseUrl}/new-environment`);
    const body = await response.text();

    assert.equal(response.status, 200);
    assert.match(body, /name="accessDevSsoGroup-developer"/);
    assert.match(body, /data-copy-sso-group="accessDevSsoGroup-developer"/);
    assert.doesNotMatch(body, /name="ssoGroupName"/);
  });
});

test('new environment POST rejects requests without the CSRF token', async () => {
  await withServer(async (baseUrl) => {
    const getResponse = await fetch(`${baseUrl}/new-environment`);
    const response = await fetch(`${baseUrl}/new-environment`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        Cookie: sessionCookie(getResponse)
      },
      body: 'appName=example-service',
      redirect: 'manual'
    });
    const body = await response.text();

    assert.equal(response.status, 403);
    assert.match(body, /Your form session is no longer valid/);
  });
});

test('new environment POST accepts the matching CSRF token', async () => {
  await withServer(async (baseUrl) => {
    const getResponse = await fetch(`${baseUrl}/new-environment`);
    const body = await getResponse.text();
    const csrfToken = body.match(/name="csrfToken" value="([^"]+)"/)[1];
    const response = await fetch(`${baseUrl}/new-environment`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        Cookie: sessionCookie(getResponse)
      },
      body: new URLSearchParams({ csrfToken }),
      redirect: 'manual'
    });

    assert.equal(response.status, 302);
    assert.equal(response.headers.get('location'), '/new-environment');
  });
});

test('collaborator form exposes repeatable application access rows', async () => {
  await withServer(async (baseUrl) => {
    const response = await fetch(`${baseUrl}/new-collaborator`);
    const body = await response.text();

    assert.equal(response.status, 200);
    assert.match(body, /name="csrfToken" value="[^"]+"/);
    assert.match(body, /name="accessApplication"/);
    assert.match(body, /name="accessEnvironment"/);
    assert.match(body, /name="accessRole"/);
    assert.match(body, /data-add-access-row/);
    assert.match(body, /Add row/);
    assert.match(body, /Use lowercase Modernisation Platform application names/);
    assert.doesNotMatch(body, /pushPermissions|deploymentApproval/);
  });
});

test('collaborator request reaches review and preview confirmation', async () => {
  await withServer(async (baseUrl) => {
    const formResponse = await fetch(`${baseUrl}/new-collaborator`);
    const formBody = await formResponse.text();
    const cookie = sessionCookie(formResponse);
    const csrfToken = formBody.match(/name="csrfToken" value="([^"]+)"/)[1];
    const formData = new URLSearchParams({
      csrfToken,
      requestorName: 'Samwise Gamgee',
      requestorEmail: 'samwise.gamgee@justice.gov.uk',
      collaboratorEmail: 'frodo@example.com',
      collaboratorGithub: 'frodo-baggins',
      additionalInformation: 'Temporary project access'
    });
    formData.append('accessApplication', 'rivendell');
    formData.append('accessEnvironment', 'development');
    formData.append('accessRole', 'sandbox');
    formData.append('accessApplication', 'mordor-reporting');
    formData.append('accessEnvironment', 'production');
    formData.append('accessRole', 'read-only');

    const postResponse = await fetch(`${baseUrl}/new-collaborator`, {
      method: 'POST',
      headers: { Cookie: cookie },
      body: formData,
      redirect: 'manual'
    });

    assert.equal(postResponse.status, 302);
    assert.equal(postResponse.headers.get('location'), '/new-collaborator/check');

    const checkResponse = await fetch(`${baseUrl}/new-collaborator/check`, {
      headers: { Cookie: cookie }
    });
    const checkBody = await checkResponse.text();
    const submitToken = checkBody.match(/name="csrfToken" value="([^"]+)"/)[1];

    assert.equal(checkResponse.status, 200);
    assert.match(checkBody, /Check collaborator request/);
    assert.match(checkBody, /rivendell[\s\S]*Development[\s\S]*Sandbox/);
    assert.match(checkBody, /mordor-reporting[\s\S]*Production[\s\S]*Read only/);

    const submitResponse = await fetch(`${baseUrl}/new-collaborator/submit`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        Cookie: cookie
      },
      body: new URLSearchParams({ csrfToken: submitToken })
    });
    const submitBody = await submitResponse.text();

    assert.equal(submitResponse.status, 200);
    assert.match(submitBody, /Collaborator request previewed/);
    assert.match(submitBody, /Nothing has been sent to GitHub/);
  });
});

test('dispatch mode refuses a placeholder session secret', () => {
  const result = spawnSync(process.execPath, ['-e', "require('./src/app')"], {
    cwd: path.resolve(__dirname, '..'),
    encoding: 'utf8',
    env: {
      ...process.env,
      ENVIRONMENT_REQUEST_MODE: 'dispatch',
      SESSION_SECRET: 'change-me-in-real-deployments'
    }
  });

  assert.notEqual(result.status, 0);
  assert.match(result.stderr, /A non-default SESSION_SECRET is required/);
});