RSpec.feature 'Navigation' do
  let(:form) { ComplainAboutTribunal.new }

  background do
    given_the_service_has_a_metadata
  end

  scenario 'when I navigate forward and back through the form' do
    when_I_visit_the_service
    and_I_add_my_full_name
    and_I_add_my_email
    and_I_go_back
    then_I_should_see_my_email
    and_I_go_back
    then_I_should_see_my_full_name
  end

  scenario 'when I visit a non existent page' do
    when_I_visit_a_non_existent_page
    then_I_should_see_not_found_page
  end

  scenario 'when I finish to complete the form' do
    when_I_visit_the_service
    and_I_add_my_full_name
    and_I_add_my_email
    and_I_add_my_parent_info
    and_I_check_that_my_answers_are_correct
    and_I_send_my_application
    then_I_should_see_the_confirmation_message
  end

  def when_I_visit_a_non_existent_page
    visit '/i-will-initiate-self-destruct'
  end

  def and_I_go_back
    form.back_link.click
  end

  def and_I_add_my_parent_info
    form.parent_field.set('Unknown')
    form.continue_button.click
  end

  def and_I_check_that_my_answers_are_correct
    expect(form.first_name_section.text).to eq('Full name Han Solo')
    expect(form.email_section.text).to eq('Your email address han.solo@gmail.com')
    expect(form.parent_section.text).to eq('Parent name Unknown')
  end

  def and_I_send_my_application
    form.accept_and_send_button.click
  end

  def and_I_change_my_full_name_answer
    form.full_name_change_answer_link.click
  end

  def then_I_should_see_my_full_name
    expect(form.full_name_field.value).to eq('Han Solo')
  end

  def then_I_should_see_my_email
    expect(form.email_field.value).to eq('han.solo@gmail.com')
  end

  def then_I_should_see_not_found_page
    expect(form.text).to include(
      "The page you were looking for doesn't exist (404)"
    )
  end

  def then_I_should_see_the_confirmation_message
    expect(form.confirmation_heading.text).to eq('Complaint sent')
    expect(form.confirmation_lede.text).to eq('Optional lede')
    expect(form.confirmation_body.text).to eq("You'll receive a confirmation email")
  end
end
