// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
import 'promise-polyfill/src/polyfill';
import 'whatwg-fetch'
import 'govuk-frontend/govuk-esm/vendor/polyfills/Function/prototype/bind'
import 'govuk-frontend/govuk-esm/vendor/polyfills/Element/prototype/classList'

require("@rails/ujs").start()
require("../src/runner/contentloaded.js")
require("../src/runner/analytics")
require("../src/runner/index")

// Entry point for fb-editor stylesheets
import "../styles/application.scss"

const accessibleAutocomplete = require("accessible-autocomplete")
import 'accessible-autocomplete/dist/accessible-autocomplete.min.css'

// Initialise autocomplete components
const autocompleteElements = document.querySelectorAll('.fb-autocomplete');
Array.prototype.forEach.call(autocompleteElements, function(element) {
  accessibleAutocomplete.enhanceSelectElement({
    defaultValue: '',
    autoselect: false,
    showAllValues: true,
    selectElement: element,
  });
});


// the autocomplete component only updates the underlying <select> element when
// a valid option is chosen. If a user sets an answer, then returns to change
// their answer and either blanks the autocomplete or enters an invalid/partial string
// the submitted value will not be changed. This is strange UX and confusing for
// the user.
// On autocomoplete pages, on submit, we compare the value in the autocomplete
// input with the underlying select* if they are different we set the selects
// value to empty in order to trigger validation
// * the autocomplete value will just be text, the selects value will be a json
// string {'text': 'United Kingdom', value: 'UK'}

const autocompleteComponent = document.querySelector('[data-fb-content-type="autocomplete"]');
if(autocompleteComponent) {
  const autocompleteForm = autocompleteComponent.parentNode;

  autocompleteForm.addEventListener('submit', function(event) {
    const form = event.target;
    const autocompleteField = form.querySelector('input.autocomplete__input');
    const autocompleteSelect = form.querySelector('.fb-autocomplete');
    console.log('the field entry')
    console.log(autocompleteField)
    console.log('the field entry value')
    console.log(autocompleteField.value)
    console.log('the field entry value after sub')
    console.log(autocompleteField.value.replace('&', "\\u0026"))
    console.log('the select')
    console.log(autocompleteSelect)
    // if the select is not empty and the values do not match or if the
    // autocomplete is empty trigger validation
    if(autocompleteSelect.value != '' && !autocompleteSelect.value.includes(autocompleteField.value.replace('&', "\\u0026")) || autocompleteField.value == '') {
      autocompleteSelect.value = '';
    }
  });
}


// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)

