function accept(cookieName) {
  setAnalyticsCookie(cookieName, 'accepted')
  hideCookieMessage()
  window.location.replace(window.location.pathname+'?analytics=accepted')
}

function reject(cookieName) {
  setAnalyticsCookie(cookieName, 'rejected')
  removeAnalyticsCookies()
  hideCookieMessage()
  window.location.replace(window.location.pathname+'?analytics=rejected')
}

function setAnalyticsCookie(cookieName, cookieValue) {
  document.cookie = `${cookieName}=${cookieValue}; expires=${new Date(
    new Date().getTime() + 1000 * 60 * 60 * 24 * 365
  ).toUTCString()}; path=/`
}

function hideCookieMessage() {
  const message = document.querySelector('[data-cookie-banner-element="message"]')
  if(!message) return;

  message.setAttribute('hidden', '')
}

function showMessage (messageType) {
  const message = document.querySelector(`[data-cookie-banner-element="message-${messageType}"]`);
  if(!message) return;

  message.removeAttribute('hidden');
}

function hideCookieBanner () {
  const banner = document.querySelector('[data-module="cookie-banner"]')
  if(!banner) return;
  
  banner.setAttribute('hidden', '')
}

function removeAnalyticsCookies () {
  const cookiePrefixes = ['_ga', '_gid', '_gat_gtag_', '_hj', '_utma', '_utmb', '_utmc', '_utmz']
  for (const cookie of document.cookie.split(';')) {
    for (const cookiePrefix of cookiePrefixes) {
      const cookieName = cookie.split('=')[0].trim()
      if (cookieName.startsWith(cookiePrefix)) {
        deleteCookie(cookieName)
      }
    }
  }
}

function deleteCookie (cookieName) {
  document.cookie = `${cookieName}=; Path=/; Domain=${location.hostname}; Expires=Thu, 01 Jan 1970 00:00:01 UTC;`
  document.cookie = `${cookieName}=; Path=/; Domain=.justice.gov.uk; Expires=Thu, 01 Jan 1970 00:00:01 UTC;`
}


// So we can just access required functions from the window object
window.analytics = {
  accept: accept,
  reject: reject,
  hideCookieBanner: hideCookieBanner,
  removeAnalyticsCookies: removeAnalyticsCookies,
  showMessage: showMessage
}

// In case we want to require it like a module
module.exports = window.analytics;
