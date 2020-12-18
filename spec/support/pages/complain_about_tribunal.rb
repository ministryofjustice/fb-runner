class ComplainAboutTribunal < SitePrism::Page
  set_url '/'
  element :start_button, :button, 'Start'
  element :continue_button, :button, 'Continue'
  element :full_name_field, :field, 'Full name'
  element :parent_field, :field, 'Parent name'
  element :email_field, :field, 'Your email address'
  element :back_link, :link, 'Back'
  elements :error_summary_list, '.govuk-error-summary__list'
  elements :inline_error_messages, '.govuk-error-message'
  elements :summary_list, '.govuk-summary-list__row'
  element :accept_and_send_button, :button, 'Accept and send application'
  element :full_name_change_answer_link, '.govuk-summary-list__row[0] a'
  element :confirmation_heading, '.govuk-panel__title'
  element :confirmation_lede, '.govuk-panel__body'
  element :confirmation_body, '.fb-body'

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

  def full_name_section
    summary_list[0]
  end

  def email_section
    summary_list[1]
  end

  def parent_section
    summary_list[2]
  end
end
