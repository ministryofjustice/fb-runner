require 'rails_helper'

RSpec.describe RobotsTxtsController do
  describe 'robots.txt' do
    context 'when not blocking all web crawlers' do
      before do
        allow(Rails.application.config).to receive(:deny_all_web_crawlers).and_return(false)
        get '/robots.txt'
      end

      it 'allows all crawlers' do
        expect(response.status).to eq(404)
        expect(response.headers['X-Robots-Tag']).to be_nil
      end
    end
  end

  context 'when blocking all web crawlers' do
    before do
      get '/robots.txt'
    end

    it 'blocks all crawlers' do
      expect(response).to render_template(:deny_all)
      expect(response.headers['X-Robots-Tag']).to eq('none')
    end
  end
end
