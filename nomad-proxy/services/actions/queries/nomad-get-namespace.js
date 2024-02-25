const fse = require('fs-extra')
const { filter } = require('lodash')

const { cache } = require('../../../application.config')

const handler = async function (ctx) {
  try {
    this.logger.info(ctx.action.name, ctx.params)
    const { id } = ctx.params
    // TODO: if file exists?
    // read data
    const data = await fse.readJSON(`${cache.directory}/namespaces.json`)
    const found = filter(data, function (item) { return item.ID === id })
    console.log(found)
    if (found.lenght === 0) throw new Error('Namespace doesn\'t exist!')
    return found[0]
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
    id: { type: 'string' }
  }
}
