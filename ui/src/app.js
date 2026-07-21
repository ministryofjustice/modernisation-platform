const path = require('path');
const express = require('express');
const session = require('express-session');
const nunjucks = require('nunjucks');

const routes = require('./routes');
const mockRoutes = require('./routes/mocks');

const app = express();
const PORT = process.env.PORT || 3000;

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

// Body + session
app.use(express.urlencoded({ extended: true }));
app.use(
  session({
    secret: process.env.SESSION_SECRET || 'poc-secret-change-me',
    resave: false,
    saveUninitialized: true,
    cookie: { httpOnly: true, sameSite: 'lax', maxAge: 1000 * 60 * 60 }
  })
);

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
  console.error(err);
  res.status(500).render('error.njk', { message: 'Sorry, there is a problem with the service' });
});

app.listen(PORT, () => {
  console.log(`Modernisation Platform UI listening on http://localhost:${PORT}`);
});
