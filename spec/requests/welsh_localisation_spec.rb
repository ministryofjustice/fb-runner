RSpec.describe 'Welsh localisation', type: :request do
  let(:welsh_service) do
    service = Rails.configuration.service.dup
    service.metadata.locale = 'cy'
    service
  end

  before do
    allow(
      Rails.configuration
    ).to receive(:service).and_return(welsh_service)
  end

  describe 'home page' do
    before { get '/' }

    context 'html lang' do
      it 'declares the language in the html tag' do
        assert_select 'html[lang=cy]'
      end
    end

    context 'start button' do
      it 'has a start button translated to Welsh' do
        assert_select 'button.govuk-button--start', 'Dechrau nawr'
      end
    end

    context 'footer links' do
      it 'has the links translated to Welsh' do
        assert_select 'ul.govuk-footer__inline-list' do
          assert_select 'li:nth-child(1) > a', 'Cwcis'
          assert_select 'li:nth-child(2) > a', 'Preifatrwydd'
          assert_select 'li:nth-child(3) > a', 'Hygyrchedd'
        end
      end
    end
  end

  describe 'question pages' do
    before do
      post '/'
      follow_redirect!
    end

    context 'form buttons' do
      it 'has buttons translated to Welsh' do
        assert_select 'form.new_answers' do
          assert_select 'button.govuk-button', count: 1, text: 'Parhau'
        end
      end
    end
  end
end
