const { randomUUID } = require('crypto');
const { buildAccessRows } = require('../routes/collaborator-form-config');

function buildCollaboratorRequest(data, requestId = randomUUID()) {
  return {
    schemaVersion: 2,
    requestId,
    requestor: {
      name: data.requestorName.trim(),
      email: data.requestorEmail.trim()
    },
    collaborator: {
      email: data.collaboratorEmail.trim(),
      githubUsername: data.collaboratorGithub.trim()
    },
    accounts: buildAccessRows(data),
    additionalInformation: String(data.additionalInformation || '').trim()
  };
}

module.exports = { buildCollaboratorRequest };