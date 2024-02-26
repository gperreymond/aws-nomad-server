const fse = require('fs-extra')

const { cache } = require('../../../application.config')

const handler = async function (ctx) {
  try {
    this.logger.info(ctx.action.name, ctx.params)
    // if file exists?
    // read data
    const data = await fse.readJSON(`${cache.directory}/nodes.json`)
    return data
  } catch (e) {
    /* istanbul ignore next */
    this.logger.error(ctx.action.name, e.message)
    /* istanbul ignore next */
    return Promise.reject(e)
  }
}

module.exports = {
  handler
}
