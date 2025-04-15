/*
  Modal Dialog Component
  ----------------------
   Shows content in an accessible modal dialog

   Minimum required markup is shown below.

   |==========================================================================|
   |  NOTE: the dialog *must* be outside of the inert container otherwise it  |
   | will be impossible to interact with the modal as it will be made inert.  |
   |==========================================================================|

  <body>
   <div class="govuk-modal-dialogue-inert-container">
     <!-- all your page content here -->
   </div>
    <div class="govuk-modal-dialogue" data-inert-container=".govuk-modal-dialogue-inert-container">
       <div class="govuk-modal-dialogue__wrapper" >
         <dialog class="govuk-modal-dialogue__box" aria-labelledby="modal-title" aria-modal="true" role="modal" tabindex="-1">
           <div class="govuk-modal-dialogue__header">
             <button type="button" class="govuk-button govuk-modal-dialogue__close" aria-label="close" data-element="govuk-modal-dialogue-close">x</button>
           </div>
           <div class="govuk-modal-dialogue__content">
             <h2 class="govuk-modal-dialogue__heading govuk-heading-l" id="modal-title">Title</h2>
             <div class="govuk-modal-dialogue__description govuk-body">
                Content
             </div>
           </div>
         </dialog>
       </div>
       <div class="govuk-modal-dialogue__backdrop"></div>
     </div>
   </body>

   Instantiate
   -----------
   var dialog = new ModalDialog(element).init(options)

   Options
   -------
   An object which can contain the following keys:
   triggerElement: node which will have a click event listener added to trigger opening of the modal
   focusElement: element that should gain focus when the dialog opens (defaults to the dialog itself)
   onOpen: a callback function which will be invoked when the modal is opened
   onClose: a callback function which will be invoked when the modal is closed
   onDialogNotSupported: a callback function that will be invoked if there is no native <dialog> or dialog polyfill support

*/

// import { nodeListForEach } from 'govuk-frontend/dist/govuk/common/index'
// import 'govuk-frontend/govuk-esm/vendor/polyfills/Element/prototype/classList'
// import 'govuk-frontend/govuk-esm/vendor/polyfills/Function/prototype/bind'
// import 'govuk-frontend/govuk-esm/vendor/polyfills/Event'

function ModalDialog ($module) {
  this.$module = $module
  this.$dialogBox = $module.querySelector('dialog')
  this.$container = document.documentElement

  // Allowed focussable elements
  this.focussable = [
    'button',
    '[href]',
    'input',
    'select',
    'textarea'
  ]

  this.open = this.handleOpen.bind(this)
  this.close = this.handleClose.bind(this)
  this.focus = this.handleFocus.bind(this)
  this.focusTrap = this.handleFocusTrap.bind(this)
  this.boundKeyDown = this.handleKeyDown.bind(this)

  // Modal elements
  this.$closeButtons = this.$dialogBox.querySelectorAll('[data-element="govuk-modal-dialogue-close"]')
  this.$focussable = this.$dialogBox.querySelectorAll(this.focussable.toString())
  this.$focusableLast = this.$focussable[this.$focussable.length - 1]
  this.$inertContainer = document.querySelector( this.$module.dataset.inertContainer || '.govuk-modal-dialogue-inert-container' )
}

// Initialize component
ModalDialog.prototype.init = function (options) {
// Check for module
  if (!this.$module) {
    return
  }

  this.options = options || {}

  this.$focusElement = this.options.focusElement || this.$dialogBox

  // Check for native dialog (or polyfill) support
  // if no support trigger a callback allowing us to show a fallback
  if (!this.dialogSupported()) {
    if (typeof this.options.onDialogNotSupported === 'function') {
      this.options.onDialogNotSupported.call()
    }
    return
  }

  if (this.$dialogBox.hasAttribute('open')) {
    this.open()
  }

  this.initEvents()

  return this
}

ModalDialog.prototype.dialogSupported = function () {
  if (typeof HTMLDialogElement === 'function') {
    // Native dialog is supported by browser
    return true
  } else {
    // Native dialog is not supported by browser so use polyfill
    try {
      window.dialogPolyfill.registerDialog(this.$dialog)
      return true
    } catch (error) {
      // Doesn't support polyfill (IE8)
      return false
    }
  }
}
// Initialize component events
ModalDialog.prototype.initEvents = function (options) {
  if (this.options.triggerElement) {
    this.options.triggerElement.addEventListener('click', this.open)
  }

  // Close dialogue on close button click
  nodeListForEach(this.$closeButtons, function(element) {
    element.addEventListener('click', this.close.bind(this));
  }.bind(this));
}

// Open modal
ModalDialog.prototype.handleOpen = function (event) {
  if (event) {
    event.preventDefault()
  }

  // Save last-focussed element
  this.$lastActiveElement = document.activeElement

  // Disable scrolling, show wrapper
  this.$container.classList.add('govuk-!-scroll-disabled')
  this.$module.classList.add('govuk-modal-dialogue--open')

  //make the content of the page inert
  this.$inertContainer.inert = true
  // hide content from screen readers in browsers that do not support inert
  this.$inertContainer.setAttribute('aria-hidden', 'true')

  // Close on escape key, trap focus
  document.addEventListener('keydown', this.boundKeyDown, true)

  // Optional 'onOpen' callback
  if (typeof this.options.onOpen === 'function') {
    this.options.onOpen.call(this)
  }

  // Skip open if already open
  if (this.$dialogBox.hasAttribute('open')) {
    return
  }

  // Show modal
  this.$dialogBox.setAttribute('open', '')

  // Handle focus
  this.focus()
}

// Close modal
ModalDialog.prototype.handleClose = function (event) {
  if (event) {
    event.preventDefault()
  }

  // Skip close if already closed
  if (!this.$dialogBox.hasAttribute('open')) {
    return
  }

  // Hide modal
  this.$dialogBox.removeAttribute('open')

  // Hide wrapper, enable scrolling
  this.$module.classList.remove('govuk-modal-dialogue--open')
  this.$container.classList.remove('govuk-!-scroll-disabled')
  // make content active again, and un-hide from AT
  this.$inertContainer.inert = false
  this.$inertContainer.setAttribute('aria-hidden', 'false')

  // Restore focus to last active element
  this.$lastActiveElement.focus()

  // Optional 'onClose' callback
  if (typeof this.options.onClose === 'function') {
    this.options.onClose.call(this)
  }

  // Remove escape key and trap focus listener
  document.removeEventListener('keydown', this.boundKeyDown, true)
}

ModalDialog.prototype.isOpen = function() {
  return this.$dialogBox.hasAttribute('open');
}

// Lock scroll, focus modal
ModalDialog.prototype.handleFocus = function () {
  this.$dialogBox.scrollIntoView()
  this.$focusElement.focus({ preventScroll: true })
}

// Ensure focus stays within modal
ModalDialog.prototype.handleFocusTrap = function (event) {
  var $focusElement

  // Check for tabbing outside dialog
  var hasFocusEscaped = document.activeElement !== this.$dialogBox

  // Loop inner focussable elements
  if (hasFocusEscaped) {
    nodeListForEach(this.$focussable, function (element) {
      // Actually, focus is on an inner focussable element
      if (hasFocusEscaped && document.activeElement === element) {
        hasFocusEscaped = false
      }
    })

    // Wrap focus back to first element
    $focusElement = hasFocusEscaped
      ? this.$dialogBox
      : undefined
  }

  // Wrap focus back to first/last element
  if (!$focusElement) {
    if ((document.activeElement === this.$focusableLast && !event.shiftKey) || !this.$focussable.length) {
      $focusElement = this.$dialogBox
    } else if (document.activeElement === this.$dialogBox && event.shiftKey) {
      $focusElement = this.$focusableLast
    }
  }

  // Wrap focus
  if ($focusElement) {
    event.preventDefault()
    $focusElement.focus({ preventScroll: true })
  }
}

// Listen for key presses
ModalDialog.prototype.handleKeyDown = function (event) {
  var KEY_TAB = 9
  var KEY_ESCAPE = 27

  switch (event.keyCode) {
    case KEY_TAB:
      this.focusTrap(event)
      break

    case KEY_ESCAPE:
      this.close()
      break
  }
}

function nodeListForEach (nodes, callback) {
  if (window.NodeList.prototype.forEach) {
    return nodes.forEach(callback)
  }
  for (var i = 0; i < nodes.length; i++) {
    callback.call(window, nodes[i], i, nodes);
  }
}

export default ModalDialog
