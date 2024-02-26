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
  type Node {
    ID: ID!
    Name: String!
    NodeClass: String!
    Address: String!
    Status: String!
    Jobs: [Job]!
  }
`
