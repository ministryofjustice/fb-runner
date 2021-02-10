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

  def and_I_left_my_name_blank
    form.full_name_field.set('')
    form.continue_button.click
  end

  def and_I_add_one_character_to_my_name
    form.full_name_field.set('G')
    form.continue_button.click
  end

  def and_I_add_many_characters_to_my_name
    form.full_name_field.set('Gandalf Mithrandir the Wizard')
    form.continue_button.click
  end

  def and_I_visit_my_age_page
    visit '/your-age'
  end

  def when_I_add_an_invalid_age
    form.age_field.set('Millenium Falcon')
    form.continue_button.click
  end

  def then_I_should_see_that_I_should_answer_my_name
    then_I_should_see_the_error_message(
      'Enter an answer for Full name'
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

  def then_I_should_see_the_error_message(message)
    expected_message = [message]
    expect(form.error_summary).to eq(expected_message)
    expect(form.error_messages).to eq(expected_message)
  end
end
