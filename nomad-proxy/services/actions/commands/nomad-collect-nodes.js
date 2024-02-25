const axios = require('axios')
const fse = require('fs-extra')

const { cache, nomad } = require('../../../application.config')

const handler = async function (ctx) {
  try {
    this.logger.info(ctx.action.name, ctx.params)
    // ensure cache directory
    await fse.ensureDir(cache.directory)
    // construct options
    const options = {
      headers: {
        'Content-Type': 'application/json'
      }
    }
    if (nomad.token !== '') { options.headers['X-Nomad-Token'] = nomad.token }
    if (nomad.username !== '') { options.auth = { username: nomad.username, password: nomad.password } }
    // get all nodes
    const { data } = await axios.get(`${nomad.addr}/v1/nodes`, options)
    const result = data.map(item => {
      return {
        ID: item.ID,
        Name: item.Name,
        NodeClass: item.NodeClass,
        Address: item.Address,
        Status: item.Status
      }
    })
    // write data
    await fse.writeJSON(`${cache.directory}/nodes.json`, result)
    return { success: true }
  } catch (e) {
    /* istanbul ignore next */
    this.logger.error(ctx.action.name, e.message)
    /* istanbul ignore next */
    return Promise.reject(e)
  }
}

module.exports = {
  rest: 'POST /commands/collect-nodes',
  handler
}
