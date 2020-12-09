RSpec.feature 'Navigation' do
  let(:form) { ComplainAboutTribunal.new }

  scenario 'when I navigate through the form' do
    given_the_service_has_a_metadata
    when_I_visit_the_service
    and_I_add_my_full_name
    and_I_add_my_email
    and_I_go_back_to_full_name_page
    then_I_should_see_my_full_name
  end

  scenario 'when I visit a non existent page' do
    given_the_service_has_a_metadata
    when_I_visit_a_non_existent_page
    then_I_should_see_not_found_page
  end

  def given_the_service_has_a_metadata
    expect(Rails.configuration.service_metadata).to eq(complain_about_tribunal_metadata)
  end

  def when_I_visit_the_service
    form.load
    form.start_button.click
  end

  def when_I_visit_a_non_existent_page
    visit '/i-will-initiate-self-destruct'
  end

  def and_I_add_my_full_name
    form.full_name_field.set('Han Solo')
    form.continue_button.click
  end

  def and_I_add_my_email
    form.email_field.set('han.solo@gmail.com')
  end

  def and_I_go_back_to_full_name_page
    form.back_link.click
  end

  def then_I_should_see_my_full_name
    expect(form.full_name_field.value).to eq('Han Solo')
  end

  def then_I_should_see_not_found_page
    expect(form.text).to include(
      "The page you were looking for doesn't exist (404)"
    )
  end

  def complain_about_tribunal_metadata
    JSON.parse(
      File.read(
        MetadataPresenter::Engine.root.join(
          'spec', 'fixtures', 'version.json'
        )
      )
    )
  end
end
