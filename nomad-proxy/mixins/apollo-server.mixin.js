const { ApolloServer } = require('@apollo/server')
const { startStandaloneServer } = require('@apollo/server/standalone')

const { graphql } = require('../application.config')

const resolvers = require('../graphql/Resolvers')
const queries = require('../graphql/Queries')
const schemas = require('../graphql/Schemas')

module.exports = {
  name: 'apollo-server',
  async started () {
    const __broker = this.broker
    const server = new ApolloServer({
      typeDefs: `#graphql
      ${queries}
      ${schemas}
      `,
      resolvers
    })
    await startStandaloneServer(server, {
      listen: { port: graphql.port },
      context: async () => ({
        $moleculer: __broker
      })
    })
    this.logger.info('🚀 ApolloServer ready...')
    return true
  },
  async stopped () {
    await this.conn.close()
    return true
  }
}
