const fs = require('fs').promises

const utilities = {
  async getFilesRecursively (directory) {
    const ls = await fs.readdir(directory, { withFileTypes: true })
    const files = ls.filter(file => !file.isDirectory()).filter(file => file.name.endsWith('.json')).map(async file => {
      const filePath = `${directory}/${file.name}`
      const contents = await fs.readFile(filePath, 'utf8').then(content => JSON.parse(content))
      return { ...contents, ...{ source: filePath } }
    })

    const folders = ls.filter(file => file.isDirectory())

    for (const folder of folders) {
      files.push(...await utilities.getFilesRecursively(`${directory}/${folder.name}/`))
    }

    return Promise.all(files)
  },
  checkKeys (object, keys, required = true) {
    const objKeys = Object.keys(object)
    return keys.filter(key => !objKeys.includes(key))
  }
}

module.exports = utilities
