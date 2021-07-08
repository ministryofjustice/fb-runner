RSpec.feature 'Navigation' do
  let(:form) { BranchingFixture.new }

  before do
    allow(VerifySession).to receive(:before).and_return(false)
  end

  background do
    given_the_app_is_using_the_branching_metadata
  end

  scenario 'navigating between branches' do
    given_I_enter_in_the_form
    given_I_add_my_full_name
    given_I_like_star_wars

    then_I_should_be_on_star_wars_general_knowledge_page

    given_I_dont_like_star_wars
    then_I_should_be_on_favourite_fruit_page

    given_I_like_apples
    then_I_should_be_on_apple_juice_page

    given_I_like_apple_juice
    then_I_should_be_on_favourite_band_page

    given_I_like_oranges
    then_I_should_be_on_orange_juice_page

    given_I_like_orange_juice
    then_I_should_be_on_favourite_band_page

    given_I_like_pears
    then_I_should_be_on_favourite_band_page

    given_I_dont_answer_the_favourite_band_page
    then_I_should_be_on_best_formbuilder_page

    given_I_like_beatles
    then_I_should_be_on_music_app_page

    given_I_use_itunes
    then_I_should_be_on_best_formbuilder_page

    given_that_MoJ_is_the_best_formbuilder
    then_I_should_be_on_the_burgers_page

    given_that_MoJ_is_not_the_best_formbuilder
    then_I_should_be_on_which_formbuilder_page

    given_that_MoJ_is_the_best_formbuilder

    given_that_I_like_burgers_with_beef
    then_I_should_see_a_content_about_global_warming

    given_that_I_like_chickens
    then_I_should_see_a_content_about_chickens

    and_I_go_to_next_page
    then_I_should_be_on_marvel_best_series

    and_I_choose_loki_as_the_best_marvel_series
    then_I_should_be_on_marvel_quotes_page

    given_I_choose_falcon_as_the_best_marvel_series
    then_I_should_be_on_marvel_quotes_page

    given_I_choose_wanda_vision_as_best_marvel_series
    then_I_should_be_on_arnold_quotes_page

    given_I_like_star_wars_on_weekends
    given_I_choose_wanda_vision_as_best_marvel_series
    then_I_should_be_on_other_quotes_page

    and_I_go_to_next_page
    then_I_should_be_on_arnold_quotes_page

    given_I_choose_the_right_arnold_quotes
    then_I_should_be_on_the_right_arnold_quotes_page

    and_I_go_back
    given_I_choose_the_wrong_arnold_quotes
    then_I_should_be_on_the_wrong_arnold_quotes_page

    and_I_go_back
    given_I_choose_the_incomplete_arnold_quotes
    then_I_should_be_on_the_incomplete_arnold_quotes_page

    and_I_go_to_next_page
    then_I_should_be_on_check_your_answers_page

    and_I_should_see_only_the_question_and_answers_based_on_branching
  end

  def and_I_should_see_only_the_question_and_answers_based_on_branching
    expect(form.check_your_answers_list).to match_array([
      'Full name Black Widow',
      'Do you like Star Wars? Only on weekends',
      "What was the name of the band playing in Jabba's palace? ",
      "What is The Mandalorian's real name? ",
      'What is your favourite fruit? Pears',
      'What is your favourite band? Beatles',
      'Which app do you use to listen music? iTunes',
      'What is the best form builder? MoJ',
      'What would you like on your burger? Chicken, cheese, tomato',
      'What is the best marvel series? WandaVision',
      'Select all Arnold Schwarzenegger quotes You are not you. You are me'
    ])
  end

  def given_I_choose_the_right_arnold_quotes
    check 'You are not you. You are me'
    check 'Get to the chopper'
    check 'You have been terminated'
    and_I_go_to_next_page
  end

  def given_I_choose_the_wrong_arnold_quotes
    check 'I am GROOT'
    check 'Dance Off, Bro.'
    and_I_uncheck_the_right_answers
    and_I_go_to_next_page
  end

  def and_I_uncheck_the_right_answers
    uncheck 'You are not you. You are me'
    uncheck 'Get to the chopper'
    uncheck 'You have been terminated'
  end

  def and_I_uncheck_the_wrong_answers
    uncheck 'I am GROOT'
    uncheck 'Dance Off, Bro.'
  end

  def given_I_choose_the_incomplete_arnold_quotes
    and_I_uncheck_the_right_answers
    and_I_uncheck_the_wrong_answers
    check 'You are not you. You are me'

    and_I_go_to_next_page
  end

  def then_I_should_be_on_arnold_quotes_page
    expect(form.current_path).to eq('/best-arnold-quote')
  end

  def then_I_should_be_on_the_right_arnold_quotes_page
    expect(form.current_path).to eq('/arnold-right-answers')
    expect(form.text).to include('You are right! Now, talk to the hand!')
  end

  def then_I_should_be_on_the_wrong_arnold_quotes_page
    expect(form.current_path).to eq('/arnold-wrong-answers')
    expect(form.text).to include(
      'You are wrong! These are from the Guardians of the Galaxy'
    )
  end

  def then_I_should_be_on_the_incomplete_arnold_quotes_page
    expect(form.current_path).to eq('/arnold-incomplete-answers')
    expect(form.text).to include(
      'You are wrong! The answers are incomplete.'
    )
  end

  def given_I_like_star_wars_on_weekends
    visit 'do-you-like-star-wars'
    given_I_like_star_wars
  end

  def and_I_choose_loki_as_the_best_marvel_series
    form.loki.choose
    and_I_go_to_next_page
  end

  def given_I_choose_falcon_as_the_best_marvel_series
    visit 'marvel-series'
    form.falcon.choose
    and_I_go_to_next_page
  end

  def given_I_choose_wanda_vision_as_best_marvel_series
    visit 'marvel-series'
    form.wandavision.choose
    and_I_go_to_next_page
  end

  def then_I_should_be_on_marvel_best_series
    expect(form.current_path).to eq('/marvel-series')
  end

  def then_I_should_be_on_marvel_quotes_page
    expect(form.current_path).to eq('/marvel-quotes')
  end

  def then_I_should_be_on_other_quotes_page
    expect(form.current_path).to eq('/other-quotes')
  end

  def then_I_should_be_on_the_burgers_page
    expect(form.current_path).to eq('/burgers')
  end

  def given_that_I_like_burgers_with_beef
    form.beef.check
    and_I_go_to_next_page
  end

  def then_I_should_see_a_content_about_global_warming
    expect(form.current_path).to eq('/global-warming')
    expect(form.text).to include('What about the trees?')
  end

  def given_that_I_like_chickens
    visit 'burgers'
    form.beef.uncheck
    form.chickens.check
    and_I_go_to_next_page
  end

  def then_I_should_see_a_content_about_chickens
    expect(form.current_path).to eq('/we-love-chickens')
    expect(form.text).to include('We love chickens')
  end

  def given_that_MoJ_is_the_best_formbuilder
    visit 'best-formbuilder'
    form.moj.choose
    and_I_go_to_next_page
  end

  def then_I_should_be_on_check_your_answers_page
    expect(form.current_path).to eq('/check-answers')
  end

  def given_that_MoJ_is_not_the_best_formbuilder
    visit 'best-formbuilder'
    form.others.choose
    and_I_go_to_next_page
  end

  def then_I_should_be_on_which_formbuilder_page
    expect(form.current_path).to eq('/which-formbuilder')
  end

  def given_the_app_is_using_the_branching_metadata
    allow(Rails.configuration).to receive(:service).and_return(
      MetadataPresenter::Service.new(
        JSON.parse(File.read(fixtures_directory.join('branching.json')))
      )
    )
  end

  def given_I_enter_in_the_form
    form.load
    form.start_button.click
  end

  def given_I_add_my_full_name
    form.full_name_field.set('Black Widow')
    and_I_go_to_next_page
  end

  def given_I_like_star_wars
    form.star_wars_only_on_weekends.choose
    and_I_go_to_next_page
  end

  def then_I_should_be_on_star_wars_general_knowledge_page
    expect(form.current_path).to eq('/star-wars-knowledge')
  end

  def given_I_dont_like_star_wars
    visit 'do-you-like-star-wars'
    form.star_wars_hell_no.choose
    and_I_go_to_next_page
  end

  def then_I_should_be_on_favourite_fruit_page
    expect(form.current_path).to eq('/favourite-fruit')
  end

  def given_I_like_apples
    form.apples.choose
    and_I_go_to_next_page
  end

  def then_I_should_be_on_apple_juice_page
    expect(form.current_path).to eq('/apple-juice')
  end

  def given_I_like_apple_juice
    form.yes.choose
    and_I_go_to_next_page
  end
  alias given_I_like_orange_juice given_I_like_apple_juice

  def then_I_should_be_on_favourite_band_page
    expect(form.current_path).to eq('/favourite-band')
  end

  def given_I_like_oranges
    visit 'favourite-fruit'
    form.oranges.choose
    and_I_go_to_next_page
  end

  def then_I_should_be_on_orange_juice_page
    expect(form.current_path).to eq('/orange-juice')
  end

  def given_I_like_pears
    visit 'favourite-fruit'
    form.pears.choose
    and_I_go_to_next_page
  end

  def given_I_dont_answer_the_favourite_band_page
    and_I_go_to_next_page
  end

  def then_I_should_be_on_best_formbuilder_page
    expect(form.current_path).to eq('/best-formbuilder')
  end

  def given_I_like_beatles
    visit '/favourite-band'
    form.beatles.choose
    and_I_go_to_next_page
  end

  def then_I_should_be_on_music_app_page
    expect(form.current_path).to eq('/music-app')
  end

  def given_I_use_itunes
    form.itunes.choose
    and_I_go_to_next_page
  end
end
