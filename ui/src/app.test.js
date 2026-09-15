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