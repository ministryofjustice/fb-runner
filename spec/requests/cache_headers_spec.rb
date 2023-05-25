RSpec.describe 'cache control header', type: :request do
  before do
    allow(VerifySession).to receive(:before).and_return false
  end

  it 'sets the no-store cache header' do
    get '/name'
    expect(response.headers['Cache-Control']).to eq 'no-store'
  end
end
