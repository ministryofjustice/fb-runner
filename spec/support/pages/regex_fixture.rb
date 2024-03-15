class RegexFixture < SitePrism::Page
  extend DataContentId

  set_url '/'
  element :heading, 'h1'
  element :start_button, :button, I18n.t('presenter.actions.start')
  element :continue_button, 'button[type="submit"]', text: I18n.t('presenter.actions.continue'), visible: true
  element :capitals_field, :field, 'capitals'
  element :digits_field, :field, 'digits'
  element :regex_field, :field, 'No number (optional)'
  elements :error_summary_list, '.govuk-error-summary__list'

  def error_summary
    error_summary_list.map(&:text)
  end
end
