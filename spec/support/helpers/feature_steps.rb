module FeatureSteps
  def given_the_service_has_a_metadata
    expect(Rails.configuration.service_metadata).to eq(complain_about_tribunal_metadata)
  end

  def and_I_add_my_full_name
    form.full_name_field.set('Han Solo')
    form.continue_button.click
  end

  def and_I_add_my_email
    form.email_field.set('han.solo@gmail.com')
  end

  def when_I_visit_the_service
    form.load
    form.start_button.click
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
