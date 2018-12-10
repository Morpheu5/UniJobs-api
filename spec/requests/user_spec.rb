require 'rails_helper'

RSpec.context 'When logged out' do
  before(:each) do
    @some_users = create_list(:user, 5)
    @some_admins = create_list(:admin, 2)
  end

  describe 'access to all users' do
    it 'fails' do
      get '/api/users'
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'access to one user' do
    it 'is successful' do
      get "/api/users/#{[*@some_users, *@some_admins].sample.id}"
      expect(response).to have_http_status(:ok)
    end

    it 'retrieves the correct user' do
      user = [*@some_users, *@some_admins].sample
      get "/api/users/#{user.id}"
      expect(json['id']).to equal(user.id)
    end
  end

  describe 'user creation' do
    before(:each) do
      @new_user = FactoryBot.attributes_for(:user)
    end

    it 'is successful' do
      post '/api/users', params: { user: @new_user }
      expect(response).to have_http_status(:created)
    end

    ### TODO: Maybe have checks for all the parameters

    it 'does not return the password digest' do
      post '/api/users', params: { user: @new_user }
      expect(json['password_digest']).to equal(nil)
    end

    it 'does not return the verification token' do
      post '/api/users', params: { user: @new_user }
      expect(json['verification_token']).to equal(nil)
    end
  end

  describe 'user update' do
    before(:each) do
      @new_user = FactoryBot.create(:user, password: 'testpassword')
    end

    it 'fails with PATCH' do
      patch "/api/users/#{@new_user.id}", params: { user: { given_name: 'Testing Alice' } }
      expect(response).to have_http_status(:forbidden)
    end

    it 'fails with PUT' do
      put "/api/users/#{@new_user.id}", params: { user: { family_name: 'Testing Smith' } }
      expect(response).to have_http_status(:forbidden)
    end

    it 'fails to update the password even if old_password is provided correctly' do
      put "/api/users/#{@new_user.id}", params: { user: { old_password: 'testpassword', password: 'newpassword!' } }
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe 'user deletion' do
    ### TODO Write tests when we have actual user deletion procedures in place.
  end

  describe 'user login' do
    before(:each) do
      @new_user = FactoryBot.create(:user, password: 'testpassword')
    end

    it 'is successful with the right credentials' do
      post '/api/login', params: { email: @new_user.email, password: 'testpassword' }
      expect(response).to have_http_status(:ok)
    end

    it 'fails with the wrong password' do
      post '/api/login', params: { email: @new_user.email, password: 'wrongpassword' }
      expect(response).to have_http_status(:forbidden)
    end

    it 'fails with the wrong credentials' do
      post '/api/login', params: { email: 'somerandomemail@example.com', password: 'wrongpassword' }
      expect(response).to have_http_status(:forbidden)
    end
  end
end
