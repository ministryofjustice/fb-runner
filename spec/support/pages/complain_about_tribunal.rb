class ComplainAboutTribunal < SitePrism::Page
  set_url '/'
  element :start_button, :button, 'Start'
  element :continue_button, :button, 'Continue'
  element :full_name_field, :field, 'Full name'
  element :email_field, :field, 'Your email address'
  element :back_link, :link, 'Back'
  elements :error_summary_list, '.govuk-error-summary__list'
  elements :inline_error_messages, '.govuk-error-message'

  def error_summary
    error_summary_list.map(&:text)
  end

  def error_messages
    ## gov-uk error messages adds a span inside span with
    # visually hidden "Error: " which capybara shows
    # independently if visible is true or false.
    inline_error_messages.map do |error_message|
      error_message.text.gsub('Error: ', '')
    end
  end
end
