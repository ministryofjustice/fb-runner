require("govuk-frontend/govuk/all").initAll()
require.context('govuk-frontend/govuk/assets/images', true)
const accessibleAutocomplete = require("accessible-autocomplete")
window.accessibleAutocomplete = accessibleAutocomplete

import "../styles/govuk.scss"
