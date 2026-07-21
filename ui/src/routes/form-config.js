// Central config so both the form view and the check-answers view stay in sync.
// Mirrors .github/ISSUE_TEMPLATE/new-environment.yml.

const accessLevels = [
  'view-only',
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

const formFields = {
  accessLevels,
  accessLevelsNonDev,
  businessUnits,
  environments,
  additionalFeatures,
  userConnectivity
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
    ssoGroupName: 'Enter the SSO group name',
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

  // App name constraints
  if (data.appName) {
    const name = String(data.appName);
    if (name.length > 30) errors.appName = 'Application name must be 30 characters or fewer';
    else if (!/^[a-z0-9-]+$/.test(name))
      errors.appName = 'Application name must be lowercase letters, numbers and hyphens only';
  }

  // Basic email check for infrastructure-support
  if (data.tagInfrastructureSupport && !/^\S+@\S+\.\S+$/.test(data.tagInfrastructureSupport)) {
    errors.tagInfrastructureSupport = 'Enter a valid email address for infrastructure-support';
  }

  return errors;
}

module.exports = { formFields, validate };
