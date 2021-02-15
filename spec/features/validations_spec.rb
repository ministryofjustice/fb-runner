RSpec.feature 'Navigation' do
  let(:form) { VersionFixture.new }

  background do
    given_the_service_has_a_metadata
    when_I_visit_the_service
  end

  scenario 'when required field is blank' do
    and_I_left_my_name_blank
    then_I_should_see_that_I_should_answer_my_name
  end

  scenario 'when minimum length field is too short' do
    and_I_add_one_character_to_my_name
    then_I_should_see_that_my_name_is_too_short
  end

  scenario 'when maximum length field is too large' do
    and_I_add_many_characters_to_my_name
    then_I_should_see_that_my_name_is_too_large
  end

  scenario 'when number field is not a number' do
    and_I_visit_my_age_page
    when_I_add_an_invalid_age
    then_I_should_see_that_I_should_enter_a_number
  end

  scenario 'when number field is blank and it is required' do
    and_I_visit_my_age_page
    when_I_left_my_age_blank
    then_I_should_see_that_I_should_answer_my_age
  end

  scenario 'when no radio button is selected and it is required' do
    and_I_go_to_declare_my_star_wars_opinion_page
    when_I_did_not_choose_a_radio_button
    then_I_should_see_that_I_should_choose_a_radio_option
  end

  scenario 'when date field is totally blank' do
    and_I_go_to_my_holiday_page
    and_I_go_to_next_page
    then_I_should_see_that_I_should_add_a_holiday
  end

  scenario 'when date field is partially blank' do
    and_I_go_to_my_holiday_page
    when_I_add_only_my_holiday_month
    then_I_should_see_that_I_should_add_a_holiday
  end

  scenario 'when date field has non numeric values' do
    and_I_go_to_my_holiday_page
    when_I_add_non_numeric_values_to_my_holiday
    then_I_should_see_that_I_should_add_a_valid_holiday
  end

  scenario 'when date field has invalid date' do
    and_I_go_to_my_holiday_page
    when_I_add_a_date_that_does_not_exist_to_my_holiday
    then_I_should_see_that_I_should_add_a_valid_holiday
  end

  def and_I_left_my_name_blank
    form.full_name_field.set('')
    and_I_go_to_next_page
  end

  def and_I_add_one_character_to_my_name
    form.full_name_field.set('G')
    and_I_go_to_next_page
  end

  def and_I_add_many_characters_to_my_name
    form.full_name_field.set('Gandalf Mithrandir the Wizard')
    and_I_go_to_next_page
  end

  def and_I_visit_my_age_page
    visit '/your-age'
  end

  def when_I_add_an_invalid_age
    form.age_field.set('Millenium Falcon')
    and_I_go_to_next_page
  end

  def when_I_left_my_age_blank
    form.age_field.set('')
    and_I_go_to_next_page
  end

  def when_I_did_not_choose_a_radio_button
    and_I_go_to_next_page
  end

  def when_I_add_only_my_holiday_month
    form.holiday_month_field.set('10')
    and_I_go_to_next_page
  end

  def when_I_add_non_numeric_values_to_my_holiday
    form.holiday_day_field.set('ab')
    form.holiday_month_field.set('cd')
    form.holiday_year_field.set('efgh')
    and_I_go_to_next_page
  end

  def when_I_add_a_date_that_does_not_exist_to_my_holiday
    form.holiday_day_field.set('31')
    form.holiday_month_field.set('02')
    form.holiday_year_field.set('2021')
    and_I_go_to_next_page
  end

  def then_I_should_see_that_I_should_answer_my_name
    then_I_should_see_the_error_message(
      'Enter an answer for Full name'
    )
  end

  def then_I_should_see_that_I_should_answer_my_age
    then_I_should_see_the_error_message(
      'Enter an answer for Your age'
    )
  end

  def then_I_should_see_that_my_name_is_too_short
    then_I_should_see_the_error_message(
      "Your answer for 'Full name' is too short (2 characters at least)"
    )
  end

  def then_I_should_see_that_my_name_is_too_large
    then_I_should_see_the_error_message(
      "Your answer for 'Full name' is too long (10 characters at most)"
    )
  end

  def then_I_should_see_that_I_should_enter_a_number
    then_I_should_see_the_error_message(
      'Enter a number for Your age'
    )
  end

  def then_I_should_see_that_I_should_choose_a_radio_option
    then_I_should_see_the_error_message(
      'Enter an answer for Do you like Star Wars?'
    )
  end

  def then_I_should_see_that_I_should_add_a_holiday
    then_I_should_see_the_error_message(
      'Enter an answer for What is the day that you like to take holidays?'
    )
  end

  def then_I_should_see_that_I_should_add_a_valid_holiday
    then_I_should_see_the_error_message(
      'Enter a valid date for What is the day that you like to take holidays?'
    )
  end

  def then_I_should_see_the_error_message(message)
    expected_message = [message]
    expect(form.error_summary).to eq(expected_message)
    expect(form.error_messages).to eq(expected_message)
  end
end
