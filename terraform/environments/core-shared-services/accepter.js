/// //////////////////////////////////////////////////////////////////
//   Accept RAM lambda
//
/// //////////////////////////////////////////////////////////////////
const AWS = require('aws-sdk')

// RAM object
const ram = new AWS.RAM()

AWS.config.apiVersions = {
  ram: '2018-01-04'
  // other service API versions
}

// Function to accept RAM share Initation
async function acceptInvite (shareARN) {
  // Grab environment variable
  const params = {
    resourceShareInvitationArn: shareARN /* required */
  }
  return ram.acceptResourceShareInvitation(params).promise()
}

exports.handler = async (event, context) => {
  try {
    const invites = await ram.getResourceShareInvitations({}).promise()

    console.log(invites)

    for (const invite of invites.resourceShareInvitations) {
      const inviteARN = invite.resourceShareInvitationArn
      console.log(inviteARN)
      await acceptInvite(inviteARN)
    }

    // const shareARN = process.env.shareARN
    // console.log(process.env)
    // await acceptInvite(shareARN)
    return event
  } catch (error) {
    console.error(error)
  }
}
