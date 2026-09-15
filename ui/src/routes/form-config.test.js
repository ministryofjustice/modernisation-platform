const assert = require('node:assert/strict');
const test = require('node:test');

const { validate } = require('./form-config');

function validFormData() {
  return {
    environmentDetails: 'An account for an example service',
    appName: 'example-service',
    appDescription: 'An example service',
    environments: ['Development', 'Production'],
    accessDev: ['developer', 'sandbox'],
    'accessDevSsoGroup-developer': 'example-developers',
    'accessDevSsoGroup-sandbox': 'example-sandbox',
    accessTest: [],
    accessPreprod: [],
    accessProd: ['view-only'],
    'accessProdSsoGroup-view-only': 'example-viewers',
    tagApplication: 'Example service',
    tagBusinessUnit: 'LAA',
    tagServiceArea: 'Example service area',
    tagInfrastructureSupport: 'example@justice.gov.uk',
    tagOwner: 'Example owner',
    slackChannel: 'example-support',
    subnetSets: 'No',
    appConnect: 'With a MoJ Official device',
    additionalFeatures: []
  };
}

test('validate accepts a complete structured request', () => {
  assert.deepEqual(validate(validFormData()), {});
});

test('validate requires access levels for every selected environment', () => {
  const data = validFormData();
  data.accessProd = [];

  assert.equal(validate(data).accessProd, 'Select at least one access level for production');
});

test('validate rejects sandbox access outside development', () => {
  const data = validFormData();
  data.accessProd = ['sandbox'];

  assert.equal(validate(data).accessProd, 'Select valid access levels for production');
});

test('validate requires an SSO group for every selected access role', () => {
  const data = validFormData();
  delete data['accessDevSsoGroup-sandbox'];

  assert.equal(
    validate(data)['accessDevSsoGroup-sandbox'],
    'Enter an SSO group name for sandbox access in development'
  );
});

test('validate rejects unsupported select and checkbox values', () => {
  const data = validFormData();
  data.tagBusinessUnit = 'Unknown';
  data.appConnect = 'Direct connection';
  data.additionalFeatures = ['Untrusted feature'];

  const errors = validate(data);
  assert.equal(errors.tagBusinessUnit, 'Select a valid business unit');
  assert.equal(errors.appConnect, 'Select how users connect to the application');
  assert.equal(errors.additionalFeatures, 'Select valid optional platform features');
});

test('validate rejects malformed optional GitHub team slugs', () => {
  const data = validFormData();
  data.codeowners = 'MinistryOfJustice/example team';
  data.githubActionReviewers = 'reviewers@example.com';

  const errors = validate(data);
  assert.equal(errors.codeowners, 'GitHub code owner team must be a lowercase team slug');
  assert.equal(
    errors.githubActionReviewers,
    'GitHub Actions reviewer team must be a lowercase team slug'
  );
});