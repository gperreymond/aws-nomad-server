module.exports = `
  type Namespace {
    ID: ID!
    Name: String!
    Jobs: [Job]!
  }
  type Job {
    ID: ID!
    Name: String!
    NamespaceID: String!
    Namespace: Namespace!
    Status: String!
  }
`
