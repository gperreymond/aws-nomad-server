// Resolver
// (parent, args, contextValue, info) => {
//   return contextValue.db.query('SELECT * FROM table_name');
// }

module.exports = {
  Query: {
    namespaces: async (_, __, contextValue, ___) => {
      return contextValue.$moleculer.call('nomad.getAllNamespaces')
    },
    jobs: async (_, __, contextValue, ___) => {
      return contextValue.$moleculer.call('nomad.getAllJobs')
    },
    nodes: async (_, __, contextValue, ___) => {
      return contextValue.$moleculer.call('nomad.getAllNodes')
    }
  },
  Namespace: {
    Jobs: (parent, __, contextValue, ___) => {
      return contextValue.$moleculer.call('nomad.getAllJobsByNamespace', { namespace: parent.ID })
    }
  },
  Node: {
    Jobs: (parent, __, contextValue, ___) => {
      return contextValue.$moleculer.call('nomad.getAllJobsByNode', { node: parent.ID })
    }
  },
  Job: {
    Namespace: (parent, __, contextValue, ___) => {
      return contextValue.$moleculer.call('nomad.getNamespace', { namespace: parent.NamespaceID })
    }
  }
}
