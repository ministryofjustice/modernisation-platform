const { randomUUID } = require('crypto');

const ENVIRONMENT_ACCESS_FIELDS = {
  Development: 'accessDev',
  Test: 'accessTest',
  Preproduction: 'accessPreprod',
  Production: 'accessProd'
};

function ssoGroupFieldName(environment, accessLevel) {
  return `${ENVIRONMENT_ACCESS_FIELDS[environment]}SsoGroup-${accessLevel}`;
}

function optionalTeam(value) {
  const team = String(value || '').trim();
  return team ? [team] : [];
}

function buildEnvironmentRequest(data, requestId = randomUUID()) {
  const environments = data.environments.map((name) => ({
    name: name.toLowerCase(),
    access: data[ENVIRONMENT_ACCESS_FIELDS[name]].map((level) => ({
      level,
      ssoGroupName: data[ssoGroupFieldName(name, level)].trim()
    }))
  }));

  return {
    schemaVersion: 2,
    requestId,
    application: {
      name: data.appName.trim(),
      tag: data.tagApplication.trim(),
      description: data.appDescription.trim(),
      codeowners: optionalTeam(data.codeowners),
      githubActionReviewers: optionalTeam(data.githubActionReviewers)
    },
    environments,
    tags: {
      businessUnit: data.tagBusinessUnit,
      serviceArea: data.tagServiceArea.trim(),
      infrastructureSupport: data.tagInfrastructureSupport.trim(),
      owner: data.tagOwner.trim(),
      slackChannel: String(data.slackChannel || '').trim()
    },
    networking: {
      isolated: data.subnetSets === 'Yes',
      userConnectivity: data.appConnect
    },
    requestDetails: {
      environmentDetails: data.environmentDetails.trim(),
      additionalFeatures: data.additionalFeatures,
      otherInformation: String(data.otherInfo || '').trim()
    },
    criticalNationalInfrastructure: false,
    goLiveDate: ''
  };
}

async function dispatchEnvironmentRequest(request, options = {}) {
  const environment = options.environment || process.env;
  const fetchImplementation = options.fetchImplementation || fetch;
  const token = environment.GITHUB_TOKEN;

  if (!token) throw new Error('GITHUB_TOKEN is required when environment request dispatch is enabled');

  const owner = environment.GITHUB_OWNER || 'ministryofjustice';
  const repository = environment.GITHUB_REPOSITORY || 'modernisation-platform';
  const workflow = environment.GITHUB_WORKFLOW || 'create-newenv.yml';
  const ref = environment.GITHUB_WORKFLOW_REF || 'main';
  const url = `https://api.github.com/repos/${encodeURIComponent(owner)}/${encodeURIComponent(repository)}/actions/workflows/${encodeURIComponent(workflow)}/dispatches`;

  const response = await fetchImplementation(url, {
    method: 'POST',
    headers: {
      Accept: 'application/vnd.github+json',
      Authorization: `Bearer ${token}`,
      'Content-Type': 'application/json',
      'User-Agent': 'modernisation-platform-self-service',
      'X-GitHub-Api-Version': '2022-11-28'
    },
    body: JSON.stringify({
      ref,
      inputs: { request_json: JSON.stringify(request) }
    })
  });

  if (!response.ok) {
    const responseBody = (await response.text()).slice(0, 500);
    throw new Error(`GitHub workflow dispatch failed with ${response.status}: ${responseBody}`);
  }
}

function requestReference(requestId) {
  return `MP-${requestId.replaceAll('-', '').slice(0, 12).toUpperCase()}`;
}

module.exports = {
  buildEnvironmentRequest,
  dispatchEnvironmentRequest,
  requestReference,
  ssoGroupFieldName
};