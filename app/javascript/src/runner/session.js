// How long before the session expires to inform the user (in seconds)
var sessionWarningThreshold = 300;
// Are we currently showing the user the expiry warning
var sessionWarningShown = false;

function  checkSessionTimeRemaining() {
  fetch('/session/remaining')
  .then(function(response) {
    return response.text()
  }).then(function(secondsRemaining) {
    if(secondsRemaining <= 0 ) {
      // Session has expired - redirect to session expired page
      // window.location = '/session/expired';
    }

    if(secondsRemaining < sessionWarningThreshold && !sessionWarningShown) {
      // Session is about to expire - inform user and act on response
      // sessionWarningShown = true;
      // document.body.addEventListener('click', function() {
      //   fetch('/session/extend').then(function(response) {
      //     return response.ok;
      //   }).then(function(ok) {
      //     if(ok) {
      //       // Reset
      //       sessionWarningShown = false
      //     }
      //   });
      // });
    }
  });
}


// So we can just access required functions from the window object
window.checkSessionTimeRemaining = checkSessionTimeRemaining

module.exports = checkSessionTimeRemaining;
