class VersionFixture < SitePrism::Page
  extend DataContentId

  set_url '/'
  element :heading, 'h1'
  element :start_button, :button, I18n.t('presenter.actions.start')
  element :continue_button, 'button[type="submit"]', text: I18n.t('presenter.actions.continue'), visible: true
  element :full_name_field, :field, 'Full name'
  element :parent_field, :field, 'Parent name'
  element :email_field, :field, 'Email address'
  element :age_field, :field, 'Your age'
  element :family_hobbies_field, :field, 'Family Hobbies'
  element :only_on_weekends, :radio_button, 'Only on weekends'
  element :hell_no, :radio_button, 'Hell no!'
  element :holiday_day_field, :field, 'Day'
  element :holiday_month_field, :field, 'Month'
  element :holiday_year_field, :field, 'Year'
  element :cheeseburger, :checkbox, 'Mozzarella, cheddar, feta'
  element :beef_burger, :checkbox, 'Beef, cheese, tomato'
  element :chicken_burger, :checkbox, 'Chicken, cheese, tomato'
  element :palace_band, :field, "What was the name of the band playing in Jabba's palace?"
  element :mando_name, :radio_button, 'Din Jarrin'
  element :countries, :field, 'Countries'
  element :back_link, :link, 'Back'
  element :remove_multi_file, :link, 'thats-still-not-a-knife.txt', visible: false
  elements :error_summary_list, '.govuk-error-summary__list'
  elements :inline_error_messages, '.govuk-error-message'
  elements :summary_list, '.govuk-summary-list__row'
  element :accept_and_send_button, :button, I18n.t('presenter.actions.submit')
  element :confirmation_heading, '.govuk-panel__title'
  data_content_id :confirmation_lede, 'page[lede]'
  data_content_id :confirmation_body, 'page[body]'
  element :address_line_one_field, :field, 'Address line 1'
  element :city_field, :field, 'Town or city'
  element :postcode_field, :field, 'Postcode'
  element :country_field, :field, 'Country'

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

  def multiple_questions_heading
    page.find(:css, 'h2', text: 'How well do you know Star Wars?')
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

  def holiday_checkanswers
    summary_list[6]
  end

  def burger_checkanswers
    summary_list[7]
  end

  def star_wars_knowledge_1_checkanswers
    summary_list[8]
  end

  def star_wars_knowledge_2_checkanswers
    summary_list[9]
  end

  def dog_picture_checkanswers
    summary_list[10]
  end

  def dog_picture_change_answer_link
    dog_picture_checkanswers.find('a')
  end
end
