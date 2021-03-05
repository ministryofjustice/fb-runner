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
    and_I_add_my_holiday
    and_I_add_my_burger
    and_I_add_my_star_wars_knowledge
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

  def and_I_check_that_my_answers_are_correct
    expect(form.full_name_checkanswers.text).to include("Full name Han Solo")
    expect(form.email_checkanswers.text).to include(
      "Your email address han.solo@gmail.com"
    )
    expect(form.parent_checkanswers.text).to include("Parent name Unknown")
    expect(form.age_checkanswers.text).to include("Your age 31")
    expect(form.family_hobbies_checkanswers.text).to include(
      "Your family hobbies Play with the dogs Surfing! Change Your answer for Your family hobbies"
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
  end

  def and_I_send_my_application
    form.accept_and_send_button.click
  end

  def and_I_change_my_full_name_answer
    form.full_name_change_answer_link.click
    form.full_name_field.set('Jabba')
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
    expect(form.confirmation_lede.text).to eq('Optional lede')
    expect(form.confirmation_body.text).to eq("You'll receive a confirmation email")
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
end
