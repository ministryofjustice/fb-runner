
/* Adjust the HTML output before it is shown.
 * This won't affect the stored markdown but it should allow the presented
 * HTML reflect the required visual design.
 **/
function htmlAdjustment(html) {
  html = supportGovUKTableCSS(html);
  html = supportGovSpeakCtaMarkup(html);
  return html;
}


/* Adjust the HTML output before it is shown.
 * This won't affect the stored markdown but it should allow the presented
 * HTML reflect the required visual design.
 **/
function markdownAdjustment(markdown) {
  return supportGovSpeakCtaMarkup(markdown);
}


/* Since markdown does not support class name application (without third-party
 * scripts), and GovUK CSS requires a horrendous amount of class names to pull
 * inbtheir preferred CSS style, we're making JS controlled adjustments to the
 * converted (markdown to html) markup. The alternative would be to replicate
 * GovUK CSS to which could be applied to <table> elements withing content.
 **/
function supportGovUKTableCSS(html) {
  html = html.replace(/<table>/mig, "<table class=\"govuk-table\">");
  html = html.replace(/<thead>/mig, "<thead class=\"govuk-table__head\">");
  html = html.replace(/<tbody>/mig, "<tbody class=\"govuk-table__body\">");
  html = html.replace(/<tr>/mig, "<tr class=\"govuk-table__row\">");
  html = html.replace(/<th>/mig, "<th class=\"govuk-table__header\">");
  html = html.replace(/<td>/mig, "<td class=\"govuk-table__cell\">");
  return html;
}


/* Since there is no HTML 'call to action' element, markdown does not support
 * any syntax that can produce such output. The GovSpeak project does provide
 * some conversion to produce a visual output, coupled with CSS, that can act
 * as a CTA component. We do not support GovSpeak so this function uses the
 * same expected 'markdown' syntax and converts into the same HTML output that
 * GovSpeak would generate (separate CSS needs to be applied).
 *
 * @content (String) Either markdown or html
 *
 * ---------------------------------------------------------------------------
 *
 * 1. If we're passing HTML then we expect
 *       <p>$cta something like this $cta </p>
 *
 *    and want to turn it into
 *       <div class=\"call-to-action\"><p>something like this</p></div>
 *
 *    This is the markup used by GovSpeak for CTA elements.
 *
 * ----------------------------------------------------------------------------
 *
 * 2. If we're passing markdown then we expect
 *       $cta something like this $cta
 *
 *    and want to turn it into
 *       $cta
 *       something like this
 *       $cta
 *
 *    The line-breaks, even if stored, get obliterated by the markdown converter
 *    so that is why we're having to put them back.
 *
 * ----------------------------------------------------------------------------
 *
 * NOTE: Case insensitive - either $cta or $CTA or $cTa, etc.
 *
 **/
function supportGovSpeakCtaMarkup(content) {
  // 1.
  content = content.replace(/<p>\$cta\n?(.*)?\n?\$cta<\/p>/mig, "<div class=\"call-to-action\"><p>$1</p></div>");
  // 2.
  content = content.replace(/\$cta It looks like this. \$cta/, "$cta\nIt looks like this.\n$cta");
  return content;
}



module.exports = {
  htmlAdjustment: htmlAdjustment,
  markdownAdjustment: markdownAdjustment
}
