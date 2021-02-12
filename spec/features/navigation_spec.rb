RSpec.feature 'Navigation' do
  let(:form) { VersionFixture.new }

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

  scenario 'change your answer from check your answer page' do
    when_I_visit_the_service
    and_I_add_my_full_name
    and_I_add_my_email
    and_I_add_my_parent_info
    and_I_add_my_age
    and_I_add_my_family_hobbies
    and_I_declare_my_dislike_of_star_wars
    and_I_check_that_my_answers_are_correct
    and_I_change_my_full_name_answer
    then_I_should_see_my_changed_full_name_on_check_your_answers
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
    and_I_add_my_age
    and_I_add_my_family_hobbies
    and_I_declare_my_dislike_of_star_wars
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

  def and_I_add_my_age
    form.age_field.set('31')
    form.continue_button.click
  end

  def and_I_add_my_family_hobbies
    form.family_hobbies_field.set(
      "Play with the dogs\r\nSurfing!" # emulates textarea carriage return
    )
    form.continue_button.click
  end

  def and_I_declare_my_dislike_of_star_wars
    form.hell_no.click
    form.continue_button.click
  end

  def and_I_check_that_my_answers_are_correct
    expect(form.full_name_checkanswers.text).to include("Full name\nHan Solo")
    expect(form.email_checkanswers.text).to include(
      "Your email address\nhan.solo@gmail.com"
    )
    expect(form.parent_checkanswers.text).to include("Parent name\nUnknown")
    expect(form.age_checkanswers.text).to include("Your age\n31")
    expect(form.family_hobbies_checkanswers.text).to include(
      "Your family hobbies\nPlay with the dogs\nSurfing!"
    )
    expect(form.do_you_like_star_wars_checkanswers.text).to include("Hell no!")
  end

  def and_I_send_my_application
    form.accept_and_send_button.click
  end

  def and_I_change_my_full_name_answer
    form.full_name_change_answer_link.click
    form.full_name_field.set('Jabba')
    form.continue_button.click
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

  def then_I_should_see_my_changed_full_name_on_check_your_answers
    expect(form.full_name_checkanswers.text).to eq(
      "Full name\nJabba\nChange Your answer for Full name"
    )
  end
end
