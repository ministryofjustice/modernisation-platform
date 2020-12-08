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

exports.handler = function (event, context, callback) {
  // Get invites
  ram.getResourceShareInvitations({}, function (grsierr, grsidata) {
    if (grsierr) {
      console.log(grsierr, grsierr.stack)
    } else {
      for (var i = grsidata.resourceShareInvitations.length - 1; i >= 0; i--) {
        ram.acceptResourceShareInvitation({
          resourceShareInvitationArn: grsidata.resourceShareInvitations[i].resourceShareInvitationArn
        }, function (arsierr, arsidata) {
          if (arsierr) {
            console.log(arsierr, arsierr.stack)
          } else {
            callback(null, 'success')
          }
        })
      }
    }
  })
}
