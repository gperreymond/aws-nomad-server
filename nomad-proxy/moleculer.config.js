const { v4: uuidv4 } = require('uuid')
const { name, version } = require('./package.json')
const { moleculer: { metrics } } = require('./application.config')

module.exports = {
  nodeID: `node-${name}-${version}-${uuidv4()}`,
  logger: true,
  metrics: {
    enabled: true,
    reporter: [{
      type: 'Prometheus',
      options: {
        port: metrics.port,
        path: '/metrics',
        defaultLabels: registry => ({
          namespace: registry.broker.namespace,
          nodeID: registry.broker.nodeID
        })
      }
    }]
  },
  tracing: {
    enabled: false
  }
}
