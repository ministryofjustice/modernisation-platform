const express = require('express');
const { formFields, validate } = require('./form-config');

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

router.post('/new-environment/submit', (req, res) => {
  const data = req.session.formData;
  if (!data) return res.redirect('/new-environment');

  // POC: just render a confirmation page. In future this could:
  //   - Create a GitHub issue via the REST API
  //   - Open a PR against modernisation-platform-environments
  const reference = `MP-${Date.now().toString(36).toUpperCase()}`;
  req.session.formData = null;
  res.render('confirmation.njk', { reference, data });
});

// Ensure array fields (checkbox / multi-select) are always arrays, not undefined/string
function normaliseBody(body) {
  const out = { ...body };
  const arrayFields = [
    'environments',
    'accessDev',
    'accessTest',
    'accessPreprod',
    'accessProd',
    'additionalFeatures'
  ];
  for (const field of arrayFields) {
    if (out[field] === undefined) out[field] = [];
    else if (!Array.isArray(out[field])) out[field] = [out[field]];
  }
  return out;
}

module.exports = router;
