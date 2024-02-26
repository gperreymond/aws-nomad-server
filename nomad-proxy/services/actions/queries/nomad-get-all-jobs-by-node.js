const fse = require('fs-extra')
const { filter, find } = require('lodash')

const { cache } = require('../../../application.config')

const handler = async function (ctx) {
  try {
    this.logger.info(ctx.action.name, ctx.params)
    const { node } = ctx.params
    // TODO: if file exists?
    // read data
    const allocations = await fse.readJSON(`${cache.directory}/allocations.json`)
    const jobs = await fse.readJSON(`${cache.directory}/jobs.json`)
    const tmp = filter(allocations, function (item) { return item.NodeID === node })
    const data = tmp.map(item => {
      const job = find(jobs, function (o) { return o.ID === item.JobID && o.NamespaceID === item.Namespace })
      return {
        ID: item.JobID,
        Name: item.JobID,
        NamespaceID: item.Namespace,
        Status: job.Status
      }
    })
    console.log(data)
    return data
  } catch (e) {
    /* istanbul ignore next */
    this.logger.error(ctx.action.name, e.message)
    /* istanbul ignore next */
    return Promise.reject(e)
  }
}

module.exports = {
  handler,
  params: {
    node: { type: 'string' }
  }
}
