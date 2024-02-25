const nconf = require('nconf')
const path = require('path')
nconf.argv().env().file({ file: 'nconf.json' })

// ************************************
// Typecasting from kube env
// ************************************
let APP_MOLECULER_API_GATEWAY_PORT = 5000
let APP_MOLECULER_GRAPHQL_GATEWAY_PORT = 4000
let APP_MOLECULER_METRICS_PORT = 5050
// ************************************
if (nconf.get('APP_MOLECULER_API_GATEWAY_PORT')) { APP_MOLECULER_API_GATEWAY_PORT = parseInt(nconf.get('APP_MOLECULER_API_GATEWAY_PORT')) }
if (nconf.get('APP_MOLECULER_GRAPHQL_GATEWAY_PORT')) { APP_MOLECULER_GRAPHQL_GATEWAY_PORT = parseInt(nconf.get('APP_MOLECULER_GRAPHQL_GATEWAY_PORT')) }
if (nconf.get('APP_MOLECULER_METRICS_PORT')) { APP_MOLECULER_METRICS_PORT = parseInt(nconf.get('APP_MOLECULER_METRICS_PORT')) }
// ************************************

const APP_ENVIRONMENT = nconf.get('APP_ENVIRONMENT') || 'development'
const APP_NOMAD_ADDR = nconf.get('APP_NOMAD_ADDR') || 'http://localhost:4646'
const APP_NOMAD_TOKEN = nconf.get('APP_NOMAD_TOKEN') || ''
const APP_NOMAD_BASIC_AUTH_USERNAME = nconf.get('APP_NOMAD_BASIC_AUTH_USERNAME') || ''
const APP_NOMAD_BASIC_AUTH_PASSWORD = nconf.get('APP_NOMAD_BASIC_AUTH_PASSWORD') || ''

module.exports = {
  environment: APP_ENVIRONMENT,
  cache: {
    directory: path.resolve(__dirname, 'cache')
  },
  nomad: {
    addr: APP_NOMAD_ADDR,
    token: APP_NOMAD_TOKEN,
    username: APP_NOMAD_BASIC_AUTH_USERNAME,
    password: APP_NOMAD_BASIC_AUTH_PASSWORD
  },
  graphql: {
    port: APP_MOLECULER_GRAPHQL_GATEWAY_PORT
  },
  moleculer: {
    port: APP_MOLECULER_API_GATEWAY_PORT,
    metrics: {
      port: APP_MOLECULER_METRICS_PORT
    }
  }
}
