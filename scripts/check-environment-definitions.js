const utilities = require('./utilities.js')

module.exports = async ({ github, context }) => {
  try {
    // Get all configuration files
    const configurations = await utilities.getFilesRecursively('./environments').then(configuration => configuration.map(application => {
      // Ensure each configuration has the correct keys and/or tags
      const missingConfiguration = utilities.checkKeys(application, ['name', 'environments', 'tags'])
      const missingRequiredTags = utilities.checkKeys(application.tags, ['business-unit', 'application', 'is-production', 'owner'])

      return {
        ...application,
        ...{
          missing: {
            required: missingConfiguration.concat(missingRequiredTags)
          }
        }
      }
    }))

    const message = []

    // Filter out configurations with missing required keys
    const missingRequired = configurations.filter(configuration => configuration.missing.required.length)

    // If there are any, throw an error
    if (missingRequired.length) {
      message.push('### ❗ Required')

      missingRequired.forEach(configuration => {
        message.push(`\`${configuration.name}\` is missing: \`${configuration.missing.required.join('`, `')}\``)
      })

      message.push('Please refer to the Ministry of Justice [Tagging Guidelines](https://ministryofjustice.github.io/technical-guidance/documentation/standards/documenting-infrastructure-owners.html) for more information.')

      const formattedMessage = message.join('\r\n\r\n')

      await github.issues.createComment({
        issue_number: context.issue.number,
        owner: context.repo.owner,
        repo: context.repo.repo,
        body: formattedMessage
      })

      throw new Error(formattedMessage)
    }
  } catch (e) {
    console.error(e)
    process.exit(1)
  }
}
