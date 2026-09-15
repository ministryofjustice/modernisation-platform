const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const test = require('node:test');

const {
  buildEnvironmentRequest,
  dispatchEnvironmentRequest,
  requestReference
} = require('./environment-request');

function formData() {
  return {
    environmentDetails: 'Two accounts for an example service',
    appName: 'example-service',
    appDescription: 'A service used to test account creation',
    codeowners: 'example-codeowners',
    githubActionReviewers: 'example-reviewers',
    environments: ['Development', 'Production'],
    accessDev: ['developer', 'sandbox'],
    'accessDevSsoGroup-developer': 'example-service-developers',
    'accessDevSsoGroup-sandbox': 'example-service-sandbox',
    accessTest: [],
    accessPreprod: [],
    accessProd: ['view-only'],
    'accessProdSsoGroup-view-only': 'example-service-viewers',
    tagApplication: 'Example service',
    tagBusinessUnit: 'LAA',
    tagServiceArea: 'Example service area',
    tagInfrastructureSupport: 'example@justice.gov.uk',
    tagOwner: 'Example owner',
    slackChannel: 'example-support',
    subnetSets: 'No',
    appConnect: 'With a MoJ Official device',
    additionalFeatures: ['Additional VPC Endpoints'],
    otherInfo: 'No other information'
  };
}

test('buildEnvironmentRequest maps form values to the versioned request contract', () => {
  const requestId = '3dad8b5d-06a7-4edb-a757-708d95e05f90';
  const request = buildEnvironmentRequest(formData(), requestId);
  const expectedRequest = JSON.parse(
    fs.readFileSync(
      path.resolve(__dirname, '../../../scripts/tests/fixtures/environment-request.json'),
      'utf8'
    )
  );

  assert.deepEqual(request, expectedRequest);
});

test('dispatchEnvironmentRequest sends one JSON workflow input', async () => {
  const request = buildEnvironmentRequest(formData(), '3dad8b5d-06a7-4edb-a757-708d95e05f90');
  let capturedUrl;
  let capturedOptions;
  const fetchImplementation = async (url, options) => {
    capturedUrl = url;
    capturedOptions = options;
    return { ok: true, status: 204 };
  };

  await dispatchEnvironmentRequest(request, {
    environment: {
      GITHUB_TOKEN: 'test-token',
      GITHUB_OWNER: 'example-org',
      GITHUB_REPOSITORY: 'example-repo',
      GITHUB_WORKFLOW: 'request.yml',
      GITHUB_WORKFLOW_REF: 'integration'
    },
    fetchImplementation
  });

  assert.equal(
    capturedUrl,
    'https://api.github.com/repos/example-org/example-repo/actions/workflows/request.yml/dispatches'
  );
  assert.equal(capturedOptions.method, 'POST');
  assert.equal(capturedOptions.headers.Authorization, 'Bearer test-token');
  const body = JSON.parse(capturedOptions.body);
  assert.equal(body.ref, 'integration');
  assert.deepEqual(JSON.parse(body.inputs.request_json), request);
});

test('dispatchEnvironmentRequest reports GitHub API failures', async () => {
  const fetchImplementation = async () => ({
    ok: false,
    status: 422,
    text: async () => 'Workflow does not have workflow_dispatch trigger'
  });

  await assert.rejects(
    dispatchEnvironmentRequest(formData(), {
      environment: { GITHUB_TOKEN: 'test-token' },
      fetchImplementation
    }),
    /GitHub workflow dispatch failed with 422/
  );
});

test('requestReference creates a short support reference', () => {
  assert.equal(
    requestReference('3dad8b5d-06a7-4edb-a757-708d95e05f90'),
    'MP-3DAD8B5D06A7'
  );
});