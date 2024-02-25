const ApolloServer = require('../mixins/apollo-server.mixin')

module.exports = {
  name: 'graphql-gateway',
  mixins: [ApolloServer]
}
