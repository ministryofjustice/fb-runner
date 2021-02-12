class VersionFixture < SitePrism::Page
  set_url '/'
  element :start_button, :button, 'Start'
  element :continue_button, :button, 'Continue'
  element :full_name_field, :field, 'Full name'
  element :parent_field, :field, 'Parent name'
  element :email_field, :field, 'Your email address'
  element :age_field, :field, 'Your age'
  element :family_hobbies_field, :field, 'Your family hobbies'
  element :hell_no, :radio_button, 'Hell no!'
  element :back_link, :link, 'Back'
  elements :error_summary_list, '.govuk-error-summary__list'
  elements :inline_error_messages, '.govuk-error-message'
  elements :summary_list, '.govuk-summary-list__row'
  element :accept_and_send_button, :button, 'Accept and send application'
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

  def full_name_checkanswers
    summary_list[0]
  end

  def full_name_change_answer_link
    full_name_checkanswers.find('a')
  end

  def email_checkanswers
    summary_list[1]
  end

  def parent_checkanswers
    summary_list[2]
  end

  def age_checkanswers
    summary_list[3]
  end

  def family_hobbies_checkanswers
    summary_list[4]
  end

  def do_you_like_star_wars_checkanswers
    summary_list[5]
  end
end
