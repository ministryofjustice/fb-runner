RSpec.feature 'Navigation' do
  let(:form) { VersionFixture.new }

  before do
    allow(VerifySession).to receive(:before).and_return(false)
  end

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
    and_I_add_my_holiday
    and_I_add_my_burger
    and_I_add_my_star_wars_knowledge
    and_I_visit_the_how_many_lights_page
    and_I_upload_a_dog_picture
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
    and_I_add_my_holiday
    and_I_add_my_burger
    and_I_add_my_star_wars_knowledge
    and_I_visit_the_how_many_lights_page
    and_I_upload_a_dog_picture
    and_I_check_that_my_answers_are_correct
    and_I_send_my_application
    then_I_should_see_the_confirmation_message
  end

  scenario 'when I go back to a page with radio component' do
    and_I_go_to_declare_my_star_wars_opinion_page
    and_I_declare_my_dislike_of_star_wars
    and_I_go_back
    then_I_should_hell_no_option_chosen
  end

  scenario 'when I go back to a page with date component' do
    and_I_go_to_my_holiday_page
    and_I_add_my_holiday
    and_I_go_back
    then_I_should_see_my_holiday_in_the_fields
  end

  scenario 'when I go back to a page with a checkbox component' do
    and_I_go_to_burger_page
    and_I_add_my_burger
    and_I_go_back
    then_I_should_see_cheese_chicken_chosen
  end

  scenario 'when I change an answer on upload component' do
    and_I_go_to_dog_picture_page
    and_I_upload_a_dog_picture
    and_I_change_the_answer_for_dog_picture
    then_I_should_see_the_dog_picture_filename
    and_I_go_to_next_page
    then_I_should_be_on_the_check_your_answers_page
    and_I_change_the_answer_for_dog_picture
    and_I_remove_the_file
    and_I_go_to_next_page
    then_I_should_see_that_I_should_add_a_dog_picture
    and_I_upload_a_dog_picture
    then_I_should_be_on_the_check_your_answers_page
  end

  def and_I_remove_the_file
    click_link 'Remove file'
  end

  def and_I_change_the_answer_for_dog_picture
    form.dog_picture_change_answer_link.click
    expect(page.current_url).to include('dog-picture')
  end

  def when_I_visit_a_non_existent_page
    visit '/i-will-initiate-self-destruct'
  end

  def and_I_go_back
    form.back_link.click
  end

  def and_I_add_my_parent_info
    form.parent_field.set('Unknown')
    and_I_go_to_next_page
  end

  def and_I_add_my_age
    form.age_field.set('31')
    and_I_go_to_next_page
  end

  def and_I_add_my_family_hobbies
    form.family_hobbies_field.set(
      "Play with the dogs\r\nSurfing!" # emulates textarea carriage return
    )
    and_I_go_to_next_page
  end

  def and_I_declare_my_dislike_of_star_wars
    form.hell_no.click
    and_I_go_to_next_page
  end

  def and_I_add_my_holiday
    form.holiday_day_field.set('01')
    form.holiday_month_field.set('06')
    form.holiday_year_field.set('2021')
    and_I_go_to_next_page
  end

  def and_I_add_my_burger
    form.cheeseburger.click
    form.chicken_burger.click
    and_I_go_to_next_page
  end

  def and_I_add_my_star_wars_knowledge
    form.palace_band.set('Max Rebo Band')
    form.mando_name.click
    and_I_go_to_next_page
  end

  def and_I_visit_the_how_many_lights_page
    expect(form.heading.text).to eq('Tell me how many lights you see')
    and_I_go_to_next_page
  end

  def then_I_should_be_on_the_check_your_answers_page
    expect(page.current_url).to include('check-answers')
  end

  def and_I_check_that_my_answers_are_correct
    then_I_should_be_on_the_check_your_answers_page
    expect(form.full_name_checkanswers.text).to include("Full name Han Solo")
    expect(form.email_checkanswers.text).to include(
      "Email address han.solo@gmail.com"
    )
    expect(form.parent_checkanswers.text).to include("Parent name Unknown")
    expect(form.age_checkanswers.text).to include("Your age 31")
    expect(form.family_hobbies_checkanswers.text).to include(
      "Family Hobbies Play with the dogs Surfing! Change Your answer for Family Hobbies"
    )
    expect(form.do_you_like_star_wars_checkanswers.text).to include("Hell no!")
    expect(form.burger_checkanswers.text).to include("Mozzarella, cheddar, feta")
    expect(form.holiday_checkanswers.text).to eq(
      'What is the day that you like to take holidays? 01 June 2021 Change Your answer for What is the day that you like to take holidays?'
    )
    expect(form.multiple_questions_heading.text).to include('How well do you know Star Wars?')
    expect(form.star_wars_knowledge_1_checkanswers.text).to include(
      "What was the name of the band playing in Jabba's palace? Max Rebo Band Change Your answer for What was the name of the band playing in Jabba's palace?"
    )
    expect(form.star_wars_knowledge_2_checkanswers.text).to include(
      "What is The Mandalorian's real name? Din Jarrin Change Your answer for What is The Mandalorian's real name?"
    )
    expect(form.dog_picture_checkanswers.text).to include(
      'Upload your best dog photo thats-not-a-knife.txt'
    )
  end

  def and_I_send_my_application
    form.accept_and_send_button.click
  end

  def and_I_change_my_full_name_answer
    form.full_name_change_answer_link.click
    form.full_name_field.set('Jabba')
    and_I_go_to_next_page
  end

  def and_I_upload_a_dog_picture
    # it is not a dog picture but it is a file.
    attach_file(
      'answers[dog-picture_upload_1]',
      'spec/fixtures/thats-not-a-knife.txt'
    )
    and_I_go_to_next_page
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
    expect(
      form.confirmation_body.text.gsub('’', "'") # shrug
    ).to eq('Some day I will be the most powerful Jedi ever!')
    expect(form.text).not_to include('Optional lede')
  end

  def then_I_should_see_my_changed_full_name_on_check_your_answers
    expect(form.full_name_checkanswers.text).to eq(
      "Full name Jabba Change Your answer for Full name"
    )
  end

  def then_I_should_see_my_holiday_in_the_fields
    expect(form.holiday_day_field.value).to eq('01')
    expect(form.holiday_month_field.value).to eq('06')
    expect(form.holiday_year_field.value).to eq('2021')
  end

  def then_I_should_hell_no_option_chosen
    expect(form.only_on_weekends).to_not be_checked
    expect(form.hell_no).to be_checked
  end

  def then_I_should_see_cheese_chicken_chosen
    expect(form.beef_burger).to_not be_checked
    expect(form.chicken_burger).to be_checked
    expect(form.cheeseburger).to be_checked
  end

  def then_I_should_see_the_dog_picture_filename
    expect(form.text).to include('thats-not-a-knife.txt')
  end
end

