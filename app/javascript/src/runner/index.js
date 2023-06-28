import TimeoutWarning from './timeout-warning.js'
const {
  htmlAdjustment
} = require('../shared/content');

const ENVIRONMENT_PREVIEW = "preview";
const ENVIRONMENT_RUNNER = "runner";


/* Discover what environment we're playing in by checking the URL
 **/
function environment() {
  return location.pathname.search(/^\/services\/.*?\/preview\/$/) >= 0 ? ENVIRONMENT_PREVIEW : ENVIRONMENT_RUNNER;
}

function initializeCookieBanner() {
  const banner  = document.querySelector('[data-module="cookie-banner"]');
  if(!banner) return;

  banner.addEventListener('click', function(event) {
    if(event.target.matches('[data-cookie-banner-element="accept-button"]')) {
      window.analytics.accept(event.target.dataset.cookieName);
      return;
    }

    if(event.target.matches('[data-cookie-banner-element="reject-button"]')) {
      window.analytics.reject(event.target.dataset.cookieName);
      return;
    }

    if(event.target.matches('[data-cookie-banner-element="hide-button"]')) {
      window.analytics.hideCookieBanner();
      return;
    }
  })
}

/*
 * If the user has just accepted or rejected cookies show the confirmation
 * message in the cookie banner
 * determined by presence of ?analytics={accepted|rejected} url param
 */
function showAnalyticsConfirmationMessage() {
  var queryString = location.search;
  if(queryString.includes('analytics')) {
    var status = queryString.split('=').pop();
    window.analytics.showMessage(status);
  }
}


/* Stop cookie banner from showing in preview mode.
 * We don't need cookie or analytics related warnings
 * in the preview.
 **/
function preventCookieBannerInPreview() {
  var cookieBanner = document.getElementById("govuk-cookie-banner");
  if(cookieBanner && environment() ==  ENVIRONMENT_PREVIEW) {
    cookieBanner.setAttibute('hidden');
  }
}

function initializeTimeoutWarning() {
  const $timeoutWarning = document.querySelector('[data-module="govuk-timeout-warning"]');
  if($timeoutWarning && environment() != ENVIRONMENT_PREVIEW) {
    new TimeoutWarning($timeoutWarning).init()
  }
}


/* Enhances the edited (or static) content should it require special formatting
 * or non-standard elements.
 * e.g.
 *  - Adds GovUk classes to any <table> element
 *  - Changes supported GovSpeak markup to required HTML.
 **/
function supportGovUkContent() {
  var content = document.querySelectorAll("[data-fb-content-type=content], [data-fb-content-type=static]");
  for( var c=0; c<content.length; ++c) {
    content[c].innerHTML = htmlAdjustment(content[c].innerHTML);
  }
}


/* Page initialiser section
 **/
contentLoaded(window, () => {
  preventCookieBannerInPreview();
  initializeTimeoutWarning();
  supportGovUkContent();
  initializeCookieBanner();
  showAnalyticsConfirmationMessage();
});
