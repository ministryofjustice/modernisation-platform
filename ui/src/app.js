const path = require('path');
const express = require('express');
const session = require('express-session');
const nunjucks = require('nunjucks');
const { csrfSync } = require('csrf-sync');

const routes = require('./routes');
const mockRoutes = require('./routes/mocks');

const app = express();
const PORT = process.env.PORT || 3000;
const sessionSecret = process.env.SESSION_SECRET || 'poc-secret-change-me';

if (
  process.env.ENVIRONMENT_REQUEST_MODE === 'dispatch' &&
  ['poc-secret-change-me', 'change-me-in-real-deployments'].includes(sessionSecret)
) {
  throw new Error('A non-default SESSION_SECRET is required when workflow dispatch is enabled');
}

// Nunjucks - includes govuk-frontend templates so we can use the design system
const appViews = [
  path.join(__dirname, 'views'),
  path.join(__dirname, '..', 'node_modules', 'govuk-frontend', 'dist')
];

const env = nunjucks.configure(appViews, {
  autoescape: true,
  express: app,
  watch: false,
  noCache: process.env.NODE_ENV !== 'production'
});

app.set('view engine', 'njk');

// Static assets - serve GOV.UK Frontend assets (fonts, images, css, js)
app.use(
  '/assets',
  express.static(
    path.join(__dirname, '..', 'node_modules', 'govuk-frontend', 'dist', 'govuk', 'assets')
  )
);
app.use(
  '/govuk-frontend',
  express.static(path.join(__dirname, '..', 'node_modules', 'govuk-frontend', 'dist', 'govuk'))
);
app.use('/javascripts', express.static(path.join(__dirname, 'public', 'javascripts')));

// Body + session
app.use(express.urlencoded({ extended: false, limit: '50kb' }));
app.use(
  session({
    secret: sessionSecret,
    resave: false,
    saveUninitialized: true,
    cookie: { httpOnly: true, sameSite: 'lax', maxAge: 1000 * 60 * 60 }
  })
);

const { generateToken, csrfSynchronisedProtection } = csrfSync({
  getTokenFromRequest: (req) => req.body.csrfToken
});

app.use((req, res, next) => {
  res.locals.csrfToken = generateToken(req);
  next();
});
app.use('/new-environment', csrfSynchronisedProtection);

// Expose common template globals
env.addGlobal('serviceName', 'Modernisation Platform');
env.addGlobal('assetPath', '/assets');

app.use('/', routes);
app.use('/', mockRoutes);

// Basic 404
app.use((req, res) => {
  res.status(404).render('error.njk', { message: 'Page not found' });
});

// Basic error handler
// eslint-disable-next-line no-unused-vars
app.use((err, req, res, next) => {
  if (err.code === 'EBADCSRFTOKEN') {
    return res.status(403).render('error.njk', {
      message: 'Your form session is no longer valid. Return to the form and try again.'
    });
  }
  console.error(err);
  res.status(500).render('error.njk', { message: 'Sorry, there is a problem with the service' });
});

if (require.main === module) {
  app.listen(PORT, () => {
    console.log(`Modernisation Platform UI listening on http://localhost:${PORT}`);
  });
}

module.exports = app;
