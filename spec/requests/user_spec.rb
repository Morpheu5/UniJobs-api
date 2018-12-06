require 'rails_helper'

describe 'Public access to users' do
  it 'returns 401 when not logged in' do
    get '/api/users'
    expect(response).to have_http_status(:unauthorized)
  end
end