
import ModalDialog from './modal-dialog.js'

function TimeoutWarning ($module) {
  this.$module = $module
  this.$dialog = $module.querySelector('.govuk-timeout-warning__dialog')
  this.$fallbackElement = document.querySelector('.govuk-timeout-warning-fallback')
  this.modalDialog = new ModalDialog(this.$dialog).init( {
    onClose: this.dialogClose.bind(this),
    onDialogNotSupported: this.dialogFallback.bind(this),
  })
  this.timers = []
  // UI countdown timer specific markup
  this.$countdown = $module.querySelector('.timer')
  this.$accessibleCountdown = $module.querySelector('.at-timer')
  // UI countdown specific settings
  this.idleMinutesBeforeTimeOut = $module.getAttribute('data-minutes-idle-timeout') ? $module.getAttribute('data-minutes-idle-timeout') : 25
  this.timeOutRedirectUrl = $module.getAttribute('data-url-redirect') ? $module.getAttribute('data-url-redirect') : 'timeout'
  this.minutesTimeOutModalVisible = $module.getAttribute('data-minutes-modal-visible') ? $module.getAttribute('data-minutes-modal-visible') : 5
  this.timerText = $module.getAttribute('data-timer-text') ? $module.getAttribute('data-timer-text') : 'Your session will be reset in '
  this.timerExtraText = $module.getAttribute('data-timer-extra-text') ? $module.getAttribute('data-timer-extra-text') : 'This is to protect your data.'
  this.timerRedirectText = $module.getAttribute('data-timer-redirect-text') ? $module.getAttribute('data-timer-redirect-text') : 'You are about to be redirected'
}

// Initialise component
TimeoutWarning.prototype.init = function () {
  // Check for module and dialog
  if (!this.$module || !this.modalDialog) {
    return
  }

  // Start watching for idleness
  this.countIdleTime()

}

// Count idle time (user not interacting with page)
// Reset idle time counter when user interacts with the page
// If user is idle for specified time period, open timeout warning as dialog
TimeoutWarning.prototype.countIdleTime = function () {
  var debounce
  var idleTime
  var milliSecondsBeforeTimeOut = this.idleMinutesBeforeTimeOut * 60000

  // As user interacts with the page, keep resetting the timer
  window.onload = resetIdleTime.bind(this)
  window.onmousemove = resetIdleTime.bind(this)
  window.onmousedown = resetIdleTime.bind(this) // Catches touchscreen presses
  window.onclick = resetIdleTime.bind(this) // Catches touchpad clicks
  window.onkeypress = resetIdleTime.bind(this)
  window.onkeyup = resetIdleTime.bind(this) // Catches Android keypad presses

  function resetIdleTime () {
    if(!this.isDialogOpen()) {
      // As user has interacted with the page, reset idle time
      clearTimeout(idleTime)
      clearTimeout(debounce)

      function idleTimer() {
        this.extendTimeOnServer();
        idleTime = setTimeout(this.openDialog.bind(this), milliSecondsBeforeTimeOut)
      }

      debounce = setTimeout(idleTimer.bind(this), 3000);
    }
  }
}

TimeoutWarning.prototype.openDialog = function () {
    this.modalDialog.open();
    this.startUiCountdown()

    // if (window.history.pushState) {
    //   window.history.pushState('', '') // This updates the History API to enable state to be "popped" to detect browser navigation for disableBackButtonWhenOpen
    // }
}

TimeoutWarning.prototype.dialogFallback = function () {
  // TODO show the fallback
  this.$fallbackElement.style.display = 'block'
}

// Starts a UI countdown timer. If timer is not cancelled before 0
// reached + 4 seconds grace period, user is redirected.
TimeoutWarning.prototype.startUiCountdown = function () {
  this.clearTimers() // Clear any other modal timers that might have been running
  var $module = this
  var $countdown = this.$countdown
  var $accessibleCountdown = this.$accessibleCountdown
  var minutes = this.minutesTimeOutModalVisible
  var timerRunOnce = false
  var iOS = /iPad|iPhone|iPod/.test(navigator.userAgent) && !window.MSStream
  var timers = this.timers

  var seconds = 60 * minutes

  $countdown.innerHTML = minutes + ' minute' + (minutes > 1 ? 's' : '');

  (function runTimer () {
    var minutesLeft = parseInt(seconds / 60, 10)
    var secondsLeft = parseInt(seconds % 60, 10)
    var timerExpired = minutesLeft < 1 && secondsLeft < 1

    var minutesText = minutesLeft > 0 ? '<span class="tabular-numbers">' + minutesLeft + '</span> minute' + (minutesLeft > 1 ? 's' : '') + '' : ' '
    var secondsText = secondsLeft >= 1 ? ' <span class="tabular-numbers">' + secondsLeft + '</span> second' + (secondsLeft > 1 ? 's' : '') + '' : ''
    var atMinutesNumberAsText = ''
    var atSecondsNumberAsText = ''

    try {
      atMinutesNumberAsText = this.numberToWords(minutesLeft) // Attempt to convert numerics into text as iOS VoiceOver ccassionally stalled when encountering numbers
      atSecondsNumberAsText = this.numberToWords(secondsLeft)
    } catch (e) {
      atMinutesNumberAsText = minutesLeft
      atSecondsNumberAsText = secondsLeft
    }

    var atMinutesText = minutesLeft > 0 ? atMinutesNumberAsText + ' minute' + (minutesLeft > 1 ? 's' : '') + '' : ''
    var atSecondsText = secondsLeft >= 1 ? ' ' + atSecondsNumberAsText + ' second' + (secondsLeft > 1 ? 's' : '') + '' : ''

    // Below string will get read out by screen readers every time the timeout refreshes (every 15 secs. See below).
    // Please add additional information in the modal body content or in below extraText which will get announced to AT the first time the time out opens
    var text = '<p>' + $module.timerText +'<span class="countdown"> ' + minutesText + secondsText + '</span>.</p>'
    var atText = $module.timerText + ' ' + atMinutesText
    if (atSecondsText) {
      if (minutesLeft > 0) {
        atText += ' and'
      }
      atText += atSecondsText + '.'
    } else {
      atText += '.'
    }
    var extraText = '<p>' + $module.timerExtraText + '</p>'

    if (timerExpired) {

      $accessibleCountdown.innerHTML = $module.timerRedirectText

      setTimeout($module.redirect.bind($module), 1000)
    } else {
      seconds--

      $countdown.innerHTML = text + extraText

      if (minutesLeft < 1 && secondsLeft < 20) {
        $accessibleCountdown.setAttribute('aria-live', 'assertive')
      }

      if (!timerRunOnce) {
        // Read out the extra content only once. Don't read out on iOS VoiceOver which stalls on the longer text

        if (iOS) {
          $accessibleCountdown.innerHTML = atText
        } else {
          $accessibleCountdown.innerHTML = atText + extraText
        }
        timerRunOnce = true
      } else if (secondsLeft % 15 === 0) {
        // Update screen reader friendly content every 15 secs
        $accessibleCountdown.innerHTML = atText
      }

      // JS doesn't allow resetting timers globally so timers need to be retained for resetting.
      timers.push(setTimeout(runTimer, 1000))
    }
  })()
}

TimeoutWarning.prototype.saveLastFocusedEl = function () {
  this.$lastFocusedEl = document.activeElement
  if (!this.$lastFocusedEl || this.$lastFocusedEl === document.body) {
    this.$lastFocusedEl = null
  } else if (document.querySelector) {
    this.$lastFocusedEl = document.querySelector(':focus')
  }
}

// Set focus back on last focused el when modal closed
TimeoutWarning.prototype.setFocusOnLastFocusedEl = function () {
  if (this.$lastFocusedEl) {
    window.setTimeout(function () {
      this.$lastFocusedEl.focus()
    }, 0)
  }
}


TimeoutWarning.prototype.isDialogOpen = function () {
  return this.modalDialog.isOpen();
}

TimeoutWarning.prototype.dialogClose = function () {
  if (this.isDialogOpen()) {
    this.clearTimers()
    this.extendTimeOnServer();
  }
}

// Clears modal timer
TimeoutWarning.prototype.clearTimers = function () {
  for (var i = 0; i < this.timers.length; i++) {
    clearTimeout(this.timers[i])
  }
}

TimeoutWarning.prototype.disableBackButtonWhenOpen = function () {
  window.addEventListener('popstate', function () {
    if (this.isDialogOpen()) {
      this.closeDialog()
    } else {
      window.history.go(-1)
    }
  })
}

TimeoutWarning.prototype.redirect = function () {
  window.location.replace(this.timeOutRedirectUrl)
}

// Example function for sending last active time of user to server
TimeoutWarning.prototype.extendTimeOnServer = function () {
     var xhttp = new XMLHttpRequest()
     xhttp.onreadystatechange = function () {
       if (this.readyState === 4 && this.status === 200) {
       }
     }

     xhttp.open('GET', '/session/extend', true)
     xhttp.send()
}

TimeoutWarning.prototype.numberToWords = function () {
  var string = n.toString()
  var units
  var tens
  var scales
  var start
  var end
  var chunks
  var chunksLen
  var chunk
  var ints
  var i
  var word
  var words = 'and'

  if (parseInt(string) === 0) {
    return 'zero'
  }

  /* Array of units as words */
  units = [ '', 'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine', 'ten', 'eleven', 'twelve', 'thirteen', 'fourteen', 'fifteen', 'sixteen', 'seventeen', 'eighteen', 'nineteen' ]

  /* Array of tens as words */
  tens = [ '', '', 'twenty', 'thirty', 'forty', 'fifty', 'sixty', 'seventy', 'eighty', 'ninety' ]

  /* Array of scales as words */
  scales = [ '', 'thousand', 'million', 'billion', 'trillion', 'quadrillion', 'quintillion', 'sextillion', 'septillion', 'octillion', 'nonillion', 'decillion', 'undecillion', 'duodecillion', 'tredecillion', 'quatttuor-decillion', 'quindecillion', 'sexdecillion', 'septen-decillion', 'octodecillion', 'novemdecillion', 'vigintillion', 'centillion' ]

  /* Split user arguemnt into 3 digit chunks from right to left */
  start = string.length
  chunks = []
  while (start > 0) {
    end = start
    chunks.push(string.slice((start = Math.max(0, start - 3)), end))
  }

  /* Check if function has enough scale words to be able to stringify the user argument */
  chunksLen = chunks.length
  if (chunksLen > scales.length) {
    return ''
  }

  /* Stringify each integer in each chunk */
  words = []
  for (i = 0; i < chunksLen; i++) {
    chunk = parseInt(chunks[i])

    if (chunk) {
      /* Split chunk into array of individual integers */
      ints = chunks[i].split('').reverse().map(parseFloat)

      /* If tens integer is 1, i.e. 10, then add 10 to units integer */
      if (ints[1] === 1) {
        ints[0] += 10
      }

      /* Add scale word if chunk is not zero and array item exists */
      if ((word = scales[i])) {
        words.push(word)
      }

      /* Add unit word if array item exists */
      if ((word = units[ints[0]])) {
        words.push(word)
      }

      /* Add tens word if array item exists */
      if ((word = tens[ ints[1] ])) {
        words.push(word)
      }

      /* Add hundreds word if array item exists */
      if ((word = units[ints[2]])) {
        words.push(word + ' hundred')
      }
    }
  }
  return words.reverse().join(' ')
}

export default TimeoutWarning
