module.exports = {
  name: 'nomad',
  actions: {
    // commands
    collectNamespaces: require('../actions/commands/nomad-collect-namespaces'),
    collectNodes: require('../actions/commands/nomad-collect-nodes'),
    collectJobs: require('../actions/commands/nomad-collect-jobs'),
    collectAllocations: require('../actions/commands/nomad-collect-allocations'),
    // queries
    getAllNamespaces: require('../actions/queries/nomad-get-all-namespaces'),
    getAllNodes: require('../actions/queries/nomad-get-all-nodes'),
    getAllJobs: require('../actions/queries/nomad-get-all-jobs'),
    getAllJobsByNamespace: require('../actions/queries/nomad-get-all-jobs-by-namespace'),
    getAllJobsByNode: require('../actions/queries/nomad-get-all-jobs-by-node'),
    getNamespace: require('../actions/queries/nomad-get-namespace')
  }
}
