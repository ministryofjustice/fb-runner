module FeatureSteps
  def and_I_go_back
    form.back_link.click
  end

  def and_I_go_to_next_page
    form.continue_button.click
  end

  def and_I_send_my_application
    form.accept_and_send_button.click
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

  def and_I_go_to_dog_picture_page
    visit '/dog-picture'
  end

  def and_I_go_to_postal_address_page
    visit '/postal-address'
  end

  def when_I_visit_the_service
    form.load
    form.start_button.click
  end

  def complain_about_tribunal_metadata
    JSON.parse(File.read(fixtures_directory.join('version.json')))
  end

  def then_I_should_see_that_I_should_add_a_dog_picture
    then_I_should_see_the_error_message(
      'Choose a file to upload'
    )
  end

  def then_I_should_see_the_error_message(message)
    expected_message = [message]
    expect(form.error_summary).to eq(expected_message)
    expect(form.error_messages).to eq(expected_message)
  end

  def then_I_should_see_the_confirmation_message
    expect(form.confirmation_heading.text).to eq('Complaint sent')
    expect(
      form.confirmation_body.text.gsub('’', "'") # shrug
    ).to eq('Some day I will be the most powerful Jedi ever!')
    expect(form.text).not_to include('Optional lede')
  end

  def and_I_fill_in_address
    form.address_line_one_field.set('99 road')
    form.city_field.set('Wondercity')
    form.postcode_field.set('SW1H 9EA')
    form.country_field.set('England')
  end

  def given_the_app_is_using_the_fixture(fixture)
    allow(Rails.configuration).to receive(:service).and_return(
      MetadataPresenter::Service.new(
        JSON.parse(File.read(fixtures_directory.join(fixture)))
      )
    )
  end
end
