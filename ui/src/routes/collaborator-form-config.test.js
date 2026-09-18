const assert = require('node:assert/strict');
const test = require('node:test');

const { formFields, validateCollaborator } = require('./collaborator-form-config');

function validFormData() {
  return {
    requestorName: 'Samwise Gamgee',
    requestorEmail: 'samwise.gamgee@justice.gov.uk',
    collaboratorEmail: 'frodo@example.com',
    collaboratorGithub: 'frodo-baggins',
    accessApplication: ['rivendell', 'mordor-reporting'],
    accessEnvironment: ['development', 'production'],
    accessRole: ['sandbox', 'read-only'],
    additionalInformation: ''
  };
}

test('validateCollaborator accepts complete repeatable access rows', () => {
  assert.deepEqual(validateCollaborator(validFormData()), {});
});

test('collaborator roles match the accepted access policy', () => {
  assert.deepEqual(formFields.accessLevels, [
    'read-only',
    'developer',
    'security-audit',
    'sandbox',
    'migration',
    'instance-management',
    'fleet-manager',
    'platform-engineer-admin',
    'ssm-session-access',
    'data-scientist',
    'node4-role',
    'quicksight-admin-access',
    'reporting-operations',
    's3-upload'
  ]);
  assert.deepEqual(formFields.accessLevelsNonDevelopment, [
    'read-only',
    'developer',
    'security-audit',
    'migration',
    'instance-management',
    'fleet-manager',
    'platform-engineer-admin',
    'ssm-session-access',
    'data-scientist',
    'node4-role',
    'quicksight-admin-access',
    'reporting-operations',
    's3-upload'
  ]);
});

test('validateCollaborator requires every field in each access row', () => {
  const data = validFormData();
  data.accessRole[1] = '';

  assert.equal(
    validateCollaborator(data)['accessRole-1'],
    'Select the role for access 2'
  );
});

test('validateCollaborator restricts sandbox access to development', () => {
  const data = validFormData();
  data.accessRole[1] = 'sandbox';

  assert.equal(
    validateCollaborator(data)['accessRole-1'],
    'Select a valid role for production'
  );
});

test('validateCollaborator rejects invalid identity and application fields', () => {
  const data = validFormData();
  data.requestorEmail = 'samwise@example.com';
  data.collaboratorEmail = 'invalid';
  data.collaboratorGithub = '-frodo';
  data.accessApplication[0] = 'Rivendell!';

  const errors = validateCollaborator(data);
  assert.equal(errors.requestorEmail, 'Enter a valid justice.gov.uk email address');
  assert.equal(errors.collaboratorEmail, 'Enter a valid collaborator email address');
  assert.equal(errors.collaboratorGithub, 'Enter a valid GitHub username');
  assert.equal(
    errors['accessApplication-0'],
    'Application name must use lowercase letters, numbers and hyphens only'
  );
});

test('validateCollaborator rejects unsupported environments', () => {
  const data = validFormData();
  data.accessEnvironment[1] = 'management';

  assert.equal(validateCollaborator(data)['accessEnvironment-1'], 'Select a valid environment');
});