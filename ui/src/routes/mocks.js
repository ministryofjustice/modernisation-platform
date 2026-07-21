const express = require('express');

const router = express.Router();

/**
 * Mock routes for upcoming self-service features.
 *
 * Each GET renders a designed form for the feature.
 * Each POST just redirects to a shared "preview submitted" page - no downstream
 * action is taken yet. These pages exist to show what the finished journeys
 * could look like and to gather stakeholder feedback.
 */

const mocks = [
  {
    slug: 'sso-access',
    view: 'mock/sso-access.njk',
    title: 'Change SSO access'
  },
  {
    slug: 'update-tags',
    view: 'mock/update-tags.njk',
    title: 'Update account tags'
  },
  {
    slug: 'networking',
    view: 'mock/networking.njk',
    title: 'Networking changes'
  },
  {
    slug: 'decommission',
    view: 'mock/decommission.njk',
    title: 'Decommission an account'
  }
];

// Example accounts / teams so the mock forms feel real
const sampleAccounts = [
  'example-app-development',
  'example-app-test',
  'example-app-preproduction',
  'example-app-production',
  'another-app-development',
  'another-app-production'
];

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

const vpcEndpointServices = [
  'com.amazonaws.eu-west-2.athena',
  'com.amazonaws.eu-west-2.dynamodb',
  'com.amazonaws.eu-west-2.rds',
  'com.amazonaws.eu-west-2.secretsmanager',
  'com.amazonaws.eu-west-2.sqs'
];

const templateContext = {
  accounts: sampleAccounts,
  accessLevels,
  businessUnits,
  vpcEndpointServices
};

for (const mock of mocks) {
  router.get(`/${mock.slug}`, (req, res) => {
    res.render(mock.view, { title: mock.title, ctx: templateContext });
  });

  router.post(`/${mock.slug}`, (req, res) => {
    const reference = `PREVIEW-${Date.now().toString(36).toUpperCase()}`;
    res.render('mock/preview-confirmation.njk', {
      title: mock.title,
      reference,
      submitted: req.body
    });
  });
}

module.exports = router;
