RSpec.feature 'Validation' do
  let(:form) { RegexFixture.new }

  before do
    allow(VerifySession).to receive(:before).and_return(false)
    given_the_app_is_using_the_fixture('regex.json')
  end

  background do
    when_I_visit_the_service
  end

  scenario 'happy path' do
    visit '/multipage'
    form.capitals_field.set('ABC')
    form.digits_field.set('123')
    form.continue_button.click
    expect(form.text).to include('No number (optional)')
    form.regex_field.set('abc')
    form.continue_button.click
    expect(form.text).to include('Check your answers')
  end

  scenario 'when required field is blank' do
    visit '/multipage'
    form.capitals_field.set('ABC')
    form.continue_button.click
    expect(form.error_summary.to_s).to include('Enter an answer')
  end

  scenario 'when entering wrong regex' do
    visit '/regex'
    form.regex_field.set('123')
    form.continue_button.click
    expect(form.error_summary.to_s).to include('must match the required format')
  end
end