RSpec.feature 'Navigation' do
  let(:form) { VersionFixture.new }

  before do
    allow(VerifySession).to receive(:before).and_return(false)
  end

  background do
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

  scenario 'when no checkbox is selected and it is required' do
    and_I_go_to_burger_page
    when_I_do_not_choose_a_checkbox
    then_I_should_see_choose_a_checkbox
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

  scenario 'when upload is required and there is no file' do
    and_I_go_to_dog_picture_page
    and_I_go_to_next_page
    then_I_should_see_that_I_should_add_a_dog_picture
  end

  scenario 'when mandatory fields are empty and the address is required' do
    and_I_go_to_postal_address_page
    and_I_fill_in_address
    form.postcode_field.set('')
    and_I_go_to_next_page
    then_I_should_see_that_I_should_add_my_postcode
  end

  scenario 'when postcode format is invalid' do
    and_I_go_to_postal_address_page
    and_I_fill_in_address
    form.postcode_field.set('SW1H')
    and_I_go_to_next_page
    then_I_should_see_that_I_should_add_a_valid_postcode
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

  def when_I_do_not_choose_a_checkbox
    and_I_go_to_next_page
  end

  def then_I_should_see_that_I_should_answer_my_name
    then_I_should_see_the_error_message(
      'Enter an answer for "Full name"'
    )
  end

  def then_I_should_see_that_I_should_answer_my_age
    then_I_should_see_the_error_message(
      'Enter an answer for "Your age"'
    )
  end

  def then_I_should_see_that_my_name_is_too_short
    then_I_should_see_the_error_message(
      'Your answer for "Full name" must be 2 characters or more'
    )
  end

  def then_I_should_see_that_my_name_is_too_large
    then_I_should_see_the_error_message(
      'Your answer for "Full name" must be 10 characters or fewer'
    )
  end

  def then_I_should_see_that_I_should_enter_a_number
    then_I_should_see_the_error_message(
      'Enter a number for "Your age"'
    )
  end

  def then_I_should_see_that_I_should_choose_a_radio_option
    then_I_should_see_the_error_message(
      'Enter an answer for "Do you like Star Wars?"'
    )
  end

  def then_I_should_see_that_I_should_add_a_holiday
    then_I_should_see_the_error_message(
      'Enter an answer for "What is the day that you like to take holidays?"'
    )
  end

  def then_I_should_see_that_I_should_add_a_valid_holiday
    then_I_should_see_the_error_message(
      'Enter a valid date for "What is the day that you like to take holidays?"'
    )
  end

  def then_I_should_see_choose_a_checkbox
    then_I_should_see_the_error_message(
      'Enter an answer for "What would you like on your burger?"'
    )
  end

  def then_I_should_see_that_I_should_add_my_postcode
    then_I_should_see_the_error_message(
      'Enter postcode for "Confirm your postal address"'
    )
  end


  def then_I_should_see_that_I_should_add_a_valid_postcode
    then_I_should_see_the_error_message(
      'Enter a valid UK postcode for "Confirm your postal address"'
    )
  end
end
