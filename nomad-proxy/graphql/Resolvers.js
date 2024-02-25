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
    }
  },
  Namespace: {
    Jobs: (parent, __, contextValue, ___) => {
      return contextValue.$moleculer.call('nomad.getAllJobsByNamespace', { namespace: parent.ID })
    }
  },
  Job: {
    Namespace: (parent, __, contextValue, ___) => {
      console.log(parent)
      return contextValue.$moleculer.call('nomad.getNamespace', { id: parent.NamespaceID })
    }
  }
}
