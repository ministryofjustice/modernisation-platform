const assert = require('node:assert/strict');
const test = require('node:test');

const { buildCollaboratorRequest } = require('./collaborator-request');

test('buildCollaboratorRequest maps each access row independently', () => {
  const request = buildCollaboratorRequest(
    {
      requestorName: ' Samwise Gamgee ',
      requestorEmail: ' samwise.gamgee@justice.gov.uk ',
      collaboratorEmail: ' frodo@example.com ',
      collaboratorGithub: ' frodo-baggins ',
      accessApplication: [' rivendell ', ' mordor-reporting '],
      accessEnvironment: ['development', 'production'],
      accessRole: ['sandbox', 'read-only'],
      additionalInformation: ' Temporary project access '
    },
    '3dad8b5d-06a7-4edb-a757-708d95e05f90'
  );

  assert.deepEqual(request, {
    schemaVersion: 2,
    requestId: '3dad8b5d-06a7-4edb-a757-708d95e05f90',
    requestor: {
      name: 'Samwise Gamgee',
      email: 'samwise.gamgee@justice.gov.uk'
    },
    collaborator: {
      email: 'frodo@example.com',
      githubUsername: 'frodo-baggins'
    },
    accounts: [
      { application: 'rivendell', environment: 'development', access: 'sandbox' },
      { application: 'mordor-reporting', environment: 'production', access: 'read-only' }
    ],
    additionalInformation: 'Temporary project access'
  });
});