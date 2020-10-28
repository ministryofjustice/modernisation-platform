const fs = require('fs').promises

module.exports = async ({ github, context, command, file }) => {
  try {
    const artifact = await fs.readFile(process.env.GITHUB_WORKSPACE + '/' + file, 'utf8')
    const output = `### ${command}\r\n
<details><summary>Show output</summary>\r\n
\`\`\`${artifact.substr(0, 65536)}\`\`\`\r\n
</details>`

    await github.issues.createComment({
      issue_number: context.issue.number,
      owner: context.repo.owner,
      repo: context.repo.repo,
      body: output
    })
  } catch (e) {
    console.error(e)
    process.exit(1)
  }
}
