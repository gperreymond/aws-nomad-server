const WebMixin = require('moleculer-web')

const { moleculer: { port } } = require('../application.config')

module.exports = {
  name: 'api-gateway',
  mixins: [WebMixin],
  settings: {
    port,
    cors: {
      origin: '*',
      methods: ['GET', 'OPTIONS', 'POST', 'PUT', 'DELETE'],
      allowedHeaders: [],
      exposedHeaders: [],
      credentials: false,
      maxAge: 3600
    },
    routes: [{
      path: '/api',
      whitelist: ['*.*'],
      autoAliases: true
    }, {
      aliases: {
        'GET status/liveness' (req, res) {
          res.setHeader('Content-Type', 'application/json; charset=utf-8')
          res.end(JSON.stringify({ alive: true }))
        },
        'GET status/readiness' (req, res) {
          res.setHeader('Content-Type', 'application/json; charset=utf-8')
          res.end(JSON.stringify({ ready: true }))
        }
      }
    }]
  }
}
