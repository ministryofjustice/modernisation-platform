const environments = ['development', 'test', 'preproduction', 'production'];
const accessLevels = [
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
];
const accessLevelsNonDevelopment = accessLevels.filter((level) => level !== 'sandbox');
const maxAccessRows = 20;

const environmentLabels = {
  development: 'Development',
  test: 'Test',
  preproduction: 'Preproduction',
  production: 'Production'
};

const accessLevelLabels = {
  'read-only': 'Read only',
  developer: 'Developer',
  'security-audit': 'Security audit',
  sandbox: 'Sandbox',
  migration: 'Migration',
  'instance-management': 'Instance management',
  'fleet-manager': 'Fleet Manager',
  'platform-engineer-admin': 'Platform engineer admin',
  'ssm-session-access': 'SSM session access',
  'data-scientist': 'Data scientist',
  'node4-role': 'Node4 role',
  'quicksight-admin-access': 'QuickSight admin',
  'reporting-operations': 'Reporting operations',
  's3-upload': 'S3 upload'
};

const formFields = {
  environments,
  accessLevels,
  accessLevelsNonDevelopment,
  environmentLabels,
  accessLevelLabels,
  maxAccessRows
};

function required(value) {
  if (Array.isArray(value)) return value.length > 0;
  return value !== undefined && value !== null && String(value).trim() !== '';
}

function asArray(value) {
  if (value === undefined) return [];
  return Array.isArray(value) ? value : [value];
}

function buildAccessRows(data) {
  const applications = asArray(data.accessApplication);
  const selectedEnvironments = asArray(data.accessEnvironment);
  const roles = asArray(data.accessRole);
  const rowCount = Math.max(applications.length, selectedEnvironments.length, roles.length);

  return Array.from({ length: rowCount }, (_, index) => ({
    application: String(applications[index] || '').trim(),
    environment: String(selectedEnvironments[index] || '').trim(),
    access: String(roles[index] || '').trim()
  }));
}

function validateCollaborator(data) {
  const errors = {};
  const requiredFields = {
    requestorName: 'Enter the requestor name',
    requestorEmail: 'Enter the requestor email address',
    collaboratorEmail: 'Enter the collaborator email address',
    collaboratorGithub: 'Enter the collaborator GitHub username'
  };

  for (const [field, message] of Object.entries(requiredFields)) {
    if (!required(data[field])) errors[field] = message;
  }

  if (
    data.requestorEmail &&
    !/^[A-Za-z0-9._%+-]+@justice\.gov\.uk$/i.test(String(data.requestorEmail).trim())
  ) {
    errors.requestorEmail = 'Enter a valid justice.gov.uk email address';
  }

  if (data.collaboratorEmail) {
    const email = String(data.collaboratorEmail).trim();
    if (email.length > 254 || !/^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/.test(email)) {
      errors.collaboratorEmail = 'Enter a valid collaborator email address';
    }
  }

  if (
    data.collaboratorGithub &&
    !/^[A-Za-z0-9](?:-?[A-Za-z0-9]){0,38}$/.test(String(data.collaboratorGithub).trim())
  ) {
    errors.collaboratorGithub = 'Enter a valid GitHub username';
  }

  const accessRows = buildAccessRows(data);
  if (accessRows.length === 0) {
    errors.accessRows = 'Add at least one application access request';
  } else if (accessRows.length > maxAccessRows) {
    errors.accessRows = `Add no more than ${maxAccessRows} access requests`;
  }

  accessRows.slice(0, maxAccessRows).forEach((row, index) => {
    if (!required(row.application)) {
      errors[`accessApplication-${index}`] = `Enter the application name for access ${index + 1}`;
    } else if (!/^[a-z0-9][a-z0-9-]{0,63}$/.test(row.application)) {
      errors[`accessApplication-${index}`] =
        'Application name must use lowercase letters, numbers and hyphens only';
    }

    if (!required(row.environment)) {
      errors[`accessEnvironment-${index}`] = `Select the environment for access ${index + 1}`;
    } else if (!environments.includes(row.environment)) {
      errors[`accessEnvironment-${index}`] = 'Select a valid environment';
    }

    if (!required(row.access)) {
      errors[`accessRole-${index}`] = `Select the role for access ${index + 1}`;
    } else {
      const allowedLevels =
        row.environment === 'development' ? accessLevels : accessLevelsNonDevelopment;
      if (!allowedLevels.includes(row.access)) {
        errors[`accessRole-${index}`] = `Select a valid role for ${row.environment || 'the environment'}`;
      }
    }
  });

  return errors;
}

module.exports = { buildAccessRows, formFields, validateCollaborator };