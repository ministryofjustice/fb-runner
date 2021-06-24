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
    then_I_should_be_on_check_your_answers_page

    given_that_MoJ_is_not_the_best_formbuilder
    then_I_should_be_on_which_formbuilder_page
  end

  def given_that_MoJ_is_the_best_formbuilder
    form.moj.choose
    form.continue_button.click
  end

  def then_I_should_be_on_check_your_answers_page
    expect(form.current_path).to eq('/check-answers')
  end

  def given_that_MoJ_is_not_the_best_formbuilder
    visit 'best-formbuilder'
    form.others.choose
    form.continue_button.click
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
    form.continue_button.click
  end

  def given_I_like_star_wars
    form.star_wars_only_on_weekends.choose
    form.continue_button.click
  end

  def then_I_should_be_on_star_wars_general_knowledge_page
    expect(form.current_path).to eq('/star-wars-knowledge')
  end

  def given_I_dont_like_star_wars
    visit 'do-you-like-star-wars'
    form.star_wars_hell_no.choose
    form.continue_button.click
  end

  def then_I_should_be_on_favourite_fruit_page
    expect(form.current_path).to eq('/favourite-fruit')
  end

  def given_I_like_apples
    form.apples.choose
    form.continue_button.click
  end

  def then_I_should_be_on_apple_juice_page
    expect(form.current_path).to eq('/apple-juice')
  end

  def given_I_like_apple_juice
    form.yes.choose
    form.continue_button.click
  end
  alias given_I_like_orange_juice given_I_like_apple_juice

  def then_I_should_be_on_favourite_band_page
    expect(form.current_path).to eq('/favourite-band')
  end

  def given_I_like_oranges
    visit 'favourite-fruit'
    form.oranges.choose
    form.continue_button.click
  end

  def then_I_should_be_on_orange_juice_page
    expect(form.current_path).to eq('/orange-juice')
  end

  def given_I_like_pears
    visit 'favourite-fruit'
    form.pears.choose
    form.continue_button.click
  end

  def given_I_dont_answer_the_favourite_band_page
    form.continue_button.click
  end

  def then_I_should_be_on_best_formbuilder_page
    expect(form.current_path).to eq('/best-formbuilder')
  end

  def given_I_like_beatles
    visit '/favourite-band'
    form.beatles.choose
    form.continue_button.click
  end

  def then_I_should_be_on_music_app_page
    expect(form.current_path).to eq('/music-app')
  end

  def given_I_use_itunes
    form.itunes.choose
    form.continue_button.click
  end
end
