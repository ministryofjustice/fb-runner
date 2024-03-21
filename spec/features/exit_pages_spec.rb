RSpec.feature 'Exit pages' do
  let(:form) { ExitPagesFixture.new }

  before do
    allow(VerifySession).to receive(:before).and_return(false)
  end

  scenario 'navigate to exit page' do
    given_the_app_is_using_the_fixture('branching_7.json')
    given_I_start_the_form
    given_I_answer_the_page(form.page_b_field, 'bear')
    given_I_answer_the_page(form.page_c_field, 'cat')
    given_I_choose_an_item(form.item_3)
    given_I_answer_the_page(form.page_i_field, 'iguana')
    then_I_should_be_on_an_exit_page('/page-g')
    and_I_should_not_see_a_continue_button
  end

  scenario 'click back link on exit page and finish journey on check your answers page' do
    given_the_app_is_using_the_fixture('branching_7.json')
    given_I_start_the_form
    given_I_answer_the_page(form.page_b_field, 'bear')
    given_I_answer_the_page(form.page_c_field, 'cat')
    given_I_choose_an_item(form.item_3)
    given_I_answer_the_page(form.page_i_field, 'iguana')
    then_I_should_be_on_an_exit_page('/page-g')
    and_I_go_back
    then_I_should_see_page_i
    and_I_go_back
    given_I_choose_an_item(form.item_2)
    given_I_answer_the_page(form.page_i_field, 'impala')
    given_I_answer_the_page(form.page_k_field, 'kangaroo')
    given_I_answer_the_page(form.page_l_field, 'llama')
    then_I_should_be_on_check_your_answers_page
    and_I_should_see_only_the_question_and_answers_based_on_branching
    and_I_should_not_see_the_exit_page_on_the_answers_list
  end

  scenario 'when the form has no check answers and ends on an exit page' do
    given_the_app_is_using_the_fixture('exit_only_service.json')
    given_I_start_the_form
    given_I_answer_the_page(form.page_knowhere_field, 'somewhere')
    given_I_answer_the_page(form.page_ghost_field, 'who you gonna call?')
    then_I_should_be_on_an_exit_page('/page-goodbye')
    and_I_should_not_see_a_continue_button
  end

  def given_I_start_the_form
    form.load
    form.start_button.click
  end

  def given_I_answer_the_page(page_field, answer)
    page_field.set(answer)
    and_I_go_to_next_page
  end

  def given_I_choose_an_item(item)
    item.choose
    and_I_go_to_next_page
  end

  def and_I_go_back
    form.back_link.click
  end

  def then_I_should_be_on_an_exit_page(page)
    expect(form.current_path).to eq(page)
  end

  def then_I_should_see_page_i
    expect(form.text).to include('Page I')
  end

  def and_I_should_not_see_a_continue_button
    expect(page).to have_selector('#new_answers')
    expect(page).not_to have_selector('#new_answers .govuk-button')
  end

  def then_I_should_be_on_check_your_answers_page
    expect(form.current_path).to eq('/check-answers')
  end

  def and_I_should_see_only_the_question_and_answers_based_on_branching
    expect(form.check_your_answers_list).to match_array([
      'Page B bear',
      'Page C cat',
      'Page D Item 2',
      'Page I impala',
      'Page K kangaroo',
      'Page L llama'
    ])
  end

  def and_I_should_not_see_the_exit_page_on_the_answers_list
    expect(form.text).to_not include('Page G')
  end
end
