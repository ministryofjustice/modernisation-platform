const express = require('express');
const { formFields, validate } = require('./form-config');
const {
  buildAccessRows,
  formFields: collaboratorFormFields,
  validateCollaborator
} = require('./collaborator-form-config');
const {
  buildEnvironmentRequest,
  dispatchEnvironmentRequest,
  requestReference
} = require('../services/environment-request');
const { buildCollaboratorRequest } = require('../services/collaborator-request');

const router = express.Router();

router.get('/', (req, res) => {
  res.render('index.njk');
});

router.get('/new-environment', (req, res) => {
  const data = req.session.formData || {};
  const errors = req.session.errors || null;
  req.session.errors = null;
  res.render('new-environment.njk', { data, errors, fields: formFields });
});

router.post('/new-environment', (req, res) => {
  const data = normaliseBody(req.body);
  req.session.formData = data;

  const errors = validate(data);
  if (Object.keys(errors).length > 0) {
    req.session.errors = errors;
    return res.redirect('/new-environment');
  }

  return res.redirect('/new-environment/check');
});

router.get('/new-environment/check', (req, res) => {
  const data = req.session.formData;
  if (!data) return res.redirect('/new-environment');
  res.render('check-answers.njk', { data, fields: formFields });
});

router.post('/new-environment/submit', async (req, res, next) => {
  const data = req.session.formData;
  if (!data) return res.redirect('/new-environment');

  try {
    const request = buildEnvironmentRequest(data);
    const dispatchEnabled = process.env.ENVIRONMENT_REQUEST_MODE === 'dispatch';

    if (dispatchEnabled) await dispatchEnvironmentRequest(request);

    req.session.formData = null;
    return res.render('confirmation.njk', {
      reference: requestReference(request.requestId),
      dispatched: dispatchEnabled
    });
  } catch (error) {
    return next(error);
  }
});

router.get('/new-collaborator', (req, res) => {
  const data = req.session.collaboratorFormData || {};
  const errors = req.session.collaboratorErrors || null;
  const submittedRows = buildAccessRows(data);
  req.session.collaboratorErrors = null;
  res.render('new-collaborator.njk', {
    data,
    errors,
    fields: collaboratorFormFields,
    accessRows: submittedRows.length
      ? submittedRows
      : [{ application: '', environment: '', access: '' }]
  });
});

router.post('/new-collaborator', (req, res) => {
  const data = normaliseBody(req.body, [
    'accessApplication',
    'accessEnvironment',
    'accessRole'
  ]);
  req.session.collaboratorFormData = data;

  const errors = validateCollaborator(data);
  if (Object.keys(errors).length > 0) {
    req.session.collaboratorErrors = errors;
    return res.redirect('/new-collaborator');
  }

  return res.redirect('/new-collaborator/check');
});

router.get('/new-collaborator/check', (req, res) => {
  const data = req.session.collaboratorFormData;
  if (!data) return res.redirect('/new-collaborator');
  return res.render('collaborator-check-answers.njk', {
    data,
    fields: collaboratorFormFields,
    accessRows: buildAccessRows(data)
  });
});

router.post('/new-collaborator/submit', (req, res) => {
  const data = req.session.collaboratorFormData;
  if (!data) return res.redirect('/new-collaborator');

  const request = buildCollaboratorRequest(data);
  req.session.collaboratorFormData = null;
  return res.render('collaborator-confirmation.njk', {
    reference: requestReference(request.requestId)
  });
});

// Ensure array fields (checkbox / multi-select) are always arrays, not undefined/string
function normaliseBody(body, arrayFields = [
  'environments',
  'accessDev',
  'accessTest',
  'accessPreprod',
  'accessProd',
  'additionalFeatures'
]) {
  const out = { ...body };
  for (const field of arrayFields) {
    if (out[field] === undefined) out[field] = [];
    else if (!Array.isArray(out[field])) out[field] = [out[field]];
  }
  return out;
}

module.exports = router;
