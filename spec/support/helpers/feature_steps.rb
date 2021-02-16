module FeatureSteps
  def given_the_service_has_a_metadata
    expect(Rails.configuration.service_metadata).to eq(complain_about_tribunal_metadata)
  end

  def and_I_go_to_next_page
    form.continue_button.click
  end

  def and_I_add_my_full_name
    form.full_name_field.set('Han Solo')
    and_I_go_to_next_page
  end

  def and_I_add_my_email
    form.email_field.set('han.solo@gmail.com')
    and_I_go_to_next_page
  end

  def and_I_go_to_my_holiday_page
    visit '/holiday'
  end

  def and_I_go_to_declare_my_star_wars_opinion_page
    visit '/do-you-like-star-wars'
  end

  def and_I_go_to_burger_page
    visit '/burgers'
  end

  def when_I_visit_the_service
    form.load
    form.start_button.click
  end

  def complain_about_tribunal_metadata
    JSON.parse(File.read(fixtures_directory.join('version.json')))
  end
end
