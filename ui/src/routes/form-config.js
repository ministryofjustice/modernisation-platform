// Central config so both the form view and the check-answers view stay in sync.
// Mirrors .github/ISSUE_TEMPLATE/new-environment.yml.

const { ssoGroupFieldName } = require('../services/environment-request');

const accessLevels = [
  'view-only',
  'secrets-manager-editor',
  'developer',
  'sandbox',
  'migration',
  'instance-management',
  'instance-access',
  'security-audit',
  'reporting-operations',
  'data-engineer',
  'fleet-manager',
  's3-upload',
  'ssm-session-access',
  'data-scientist'
];

// 'sandbox' only applies to Development in the original template
const accessLevelsNonDev = accessLevels.filter((l) => l !== 'sandbox');

const businessUnits = [
  'Central Digital',
  'HMPPS',
  'OPG',
  'LAA',
  'HMCTS',
  'CICA',
  'Platforms',
  'Technology Services'
];

const environments = ['Development', 'Test', 'Preproduction', 'Production'];

const additionalFeatures = [
  'Additional VPC Endpoints',
  'Extended DNS Zones',
  'Other'
];

const userConnectivity = [
  'Over the public internet',
  'With a purple cabled device',
  'With a MoJ Official device'
];

const environmentAccessFields = {
  Development: 'accessDev',
  Test: 'accessTest',
  Preproduction: 'accessPreprod',
  Production: 'accessProd'
};

const ssoGroupFields = Object.fromEntries(
  environments.map((environment) => {
    const levels = environment === 'Development' ? accessLevels : accessLevelsNonDev;
    return [
      environment,
      Object.fromEntries(levels.map((level) => [level, ssoGroupFieldName(environment, level)]))
    ];
  })
);

const formFields = {
  accessLevels,
  accessLevelsNonDev,
  businessUnits,
  environments,
  additionalFeatures,
  userConnectivity,
  ssoGroupFields
};

function required(v) {
  if (Array.isArray(v)) return v.length > 0;
  return v !== undefined && v !== null && String(v).trim() !== '';
}

function validate(data) {
  const errors = {};

  const requiredFields = {
    environmentDetails: 'Enter the environment details',
    appName: 'Enter the application name',
    appDescription: 'Enter a description of the application',
    environments: 'Select at least one environment',
    tagApplication: 'Enter the application tag',
    tagBusinessUnit: 'Select a business unit',
    tagServiceArea: 'Enter the service area',
    tagInfrastructureSupport: 'Enter the infrastructure-support email',
    tagOwner: 'Enter the owner',
    subnetSets: 'Select whether you require isolated networking',
    appConnect: 'Select how users connect to the application'
  };

  for (const [field, message] of Object.entries(requiredFields)) {
    if (!required(data[field])) errors[field] = message;
  }

  const selectedEnvironments = Array.isArray(data.environments) ? data.environments : [];
  if (selectedEnvironments.some((environment) => !environments.includes(environment))) {
    errors.environments = 'Select valid environments';
  } else {
    for (const environment of selectedEnvironments) {
      const field = environmentAccessFields[environment];
      const selectedAccess = Array.isArray(data[field]) ? data[field] : [];
      const allowedAccess = environment === 'Development' ? accessLevels : accessLevelsNonDev;

      if (!required(selectedAccess)) {
        errors[field] = `Select at least one access level for ${environment.toLowerCase()}`;
      } else if (selectedAccess.some((level) => !allowedAccess.includes(level))) {
        errors[field] = `Select valid access levels for ${environment.toLowerCase()}`;
      } else {
        for (const level of selectedAccess) {
          const ssoField = ssoGroupFieldName(environment, level);
          if (!required(data[ssoField])) {
            errors[ssoField] = `Enter an SSO group name for ${level} access in ${environment.toLowerCase()}`;
          }
        }
      }
    }
  }

  // App name constraints
  if (data.appName) {
    const name = String(data.appName);
    if (name.length > 30) errors.appName = 'Application name must be 30 characters or fewer';
    else if (!/^[a-z0-9-]+$/.test(name))
      errors.appName = 'Application name must be lowercase letters, numbers and hyphens only';
  }

  const teamSlugPattern = /^[a-z0-9-]+$/;
  if (data.codeowners && !teamSlugPattern.test(data.codeowners)) {
    errors.codeowners = 'GitHub code owner team must be a lowercase team slug';
  }
  if (data.githubActionReviewers && !teamSlugPattern.test(data.githubActionReviewers)) {
    errors.githubActionReviewers = 'GitHub Actions reviewer team must be a lowercase team slug';
  }

  // Basic email check for infrastructure-support
  if (data.tagInfrastructureSupport && !/^\S+@\S+\.\S+$/.test(data.tagInfrastructureSupport)) {
    errors.tagInfrastructureSupport = 'Enter a valid email address for infrastructure-support';
  }

  if (data.tagBusinessUnit && !businessUnits.includes(data.tagBusinessUnit)) {
    errors.tagBusinessUnit = 'Select a valid business unit';
  }

  if (data.subnetSets && !['No', 'Yes'].includes(data.subnetSets)) {
    errors.subnetSets = 'Select whether you require isolated networking';
  }

  if (data.appConnect && !userConnectivity.includes(data.appConnect)) {
    errors.appConnect = 'Select how users connect to the application';
  }

  if (data.slackChannel && data.slackChannel.includes('#')) {
    errors.slackChannel = "Slack channel must not include '#'";
  }

  const selectedFeatures = Array.isArray(data.additionalFeatures) ? data.additionalFeatures : [];
  if (selectedFeatures.some((feature) => !additionalFeatures.includes(feature))) {
    errors.additionalFeatures = 'Select valid optional platform features';
  }

  return errors;
}

module.exports = { formFields, validate };
