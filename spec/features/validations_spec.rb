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

  def then_I_should_see_that_I_should_answer_my_name
    expected_message = ['Enter an answer for Full name']
    expect(form.error_summary).to eq(expected_message)
    expect(form.error_messages).to eq(expected_message)
  end

  def then_I_should_see_that_my_name_is_too_short
    expected_message =
      ["Your answer for 'Full name' is too short (2 characters at least)"]
    expect(form.error_summary).to eq(expected_message)
    expect(form.error_messages).to eq(expected_message)
  end

  def then_I_should_see_that_my_name_is_too_large
    expected_message =
      ["Your answer for 'Full name' is too long (10 characters at most)"]
    expect(form.error_summary).to eq(expected_message)
    expect(form.error_messages).to eq(expected_message)
  end
end
