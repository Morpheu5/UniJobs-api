require 'rails_helper'

## TODO: DRY the code up where possible.

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

    it 'does not return the password digest' do
      get "/api/users/#{[*@some_users, *@some_admins].sample.id}"
      expect(json['password_digest']).to equal(nil)
    end

    it 'does not return the verification token' do
      get "/api/users/#{[*@some_users, *@some_admins].sample.id}"
      expect(json['verification_token']).to equal(nil)
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

    it 'only creates regular users' do
      post '/api/users', params: { user: FactoryBot.attributes_for(:admin) }
      expect(json['role']).to eq('USER')
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
      expect(User.find(@new_user.id).given_name).to_not eq('Testing Alice')
    end

    it 'fails with PUT' do
      put "/api/users/#{@new_user.id}", params: { user: { family_name: 'Testing Smith' } }
      expect(response).to have_http_status(:forbidden)
      expect(User.find(@new_user.id).family_name).to_not eq('Testing Smith')
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

RSpec.context 'When logged in' do
  before(:each) do
    @user = create(:user, password: 'testpassword')
    @other_user = create(:user, password: 'othertestpassword')
    @admin = create(:admin, password: 'admintestpassword')
  end

  context 'as a user' do
    before(:each) do
      post '/api/login', params: { email: @user.email, password: 'testpassword'}
      @token = json['token']
      @auth_headers = { Authorization: "Bearer #{@token}" }
    end

    describe 'access to all users' do
      it 'fails' do
        get '/api/users', headers: { **@auth_headers }
        expect(response).to have_http_status(:forbidden)
      end
    end
    
    describe 'access to one user' do
      it 'is successful' do
        get "/api/users/#{@other_user.id}", headers: { **@auth_headers }
        expect(response).to have_http_status(:ok)
      end
  
      it 'retrieves the correct user' do
        get "/api/users/#{@other_user.id}", headers: { **@auth_headers }
        expect(json['id']).to equal(@other_user.id)
      end

      it 'does not return the password digest' do
        get "/api/users/#{@other_user.id}", headers: { **@auth_headers }
        expect(json['password_digest']).to equal(nil)
      end
  
      it 'does not return the verification token' do
        get "/api/users/#{@other_user.id}", headers: { **@auth_headers }
        expect(json['verification_token']).to equal(nil)
      end  
    end

    describe 'user creation' do
      before(:each) do
        @new_user = FactoryBot.attributes_for(:user)
      end

      it 'fails' do
        post '/api/users', params: { user: @new_user }, headers: { **@auth_headers }
        expect(response).to have_http_status(:forbidden)
      end
    end

    describe 'user update' do
      it 'succeeds with PATCH' do
        patch "/api/users/#{@user.id}", params: { user: { given_name: 'Testing Alice' } }, headers: { **@auth_headers }
        expect(response).to have_http_status(:ok)
        expect(json['given_name']).to eq('Testing Alice')
      end
  
      it 'succeeds with PUT' do
        put "/api/users/#{@user.id}", params: { user: { family_name: 'Testing Smith' } }, headers: { **@auth_headers }
        expect(response).to have_http_status(:ok)
        expect(json['family_name']).to eq('Testing Smith')
      end
  
      it 'updates the password when the old_password is correct' do
        put "/api/users/#{@user.id}", params: { user: { old_password: 'testpassword', password: 'newpassword!' } }, headers: { **@auth_headers }
        expect(response).to have_http_status(:ok)
      end

      it 'does not update the password when the old_password is wrong' do
        put "/api/users/#{@user.id}", params: { user: { old_password: 'wrongtestpassword', password: 'newpassword!' } }, headers: { **@auth_headers }
        expect(response).to have_http_status(:forbidden)
      end

      it 'fails to update own role' do
        put "/api/users/#{@user.id}", params: { user: { role: 'TEST_ADMIN' } }, headers: { **@auth_headers }
        expect(User.find(@user.id).role).to eq('USER')
      end
    end

    describe 'other user update' do
      it 'fails with PATCH' do
        patch "/api/users/#{@other_user.id}", params: { user: { given_name: 'Testing Alice' } }, headers: { **@auth_headers }
        expect(response).to have_http_status(:forbidden)
        expect(User.find(@other_user.id).given_name).to_not eq('Testing Alice')
      end
  
      it 'fails with PUT' do
        put "/api/users/#{@other_user.id}", params: { user: { family_name: 'Testing Smith' } }, headers: { **@auth_headers }
        expect(response).to have_http_status(:forbidden)
        expect(User.find(@other_user.id).family_name).to_not eq('Testing Smith')
      end
  
      it 'does not update the password when the old_password is correct' do
        put "/api/users/#{@other_user.id}", params: { user: { old_password: 'othertestpassword', password: 'newpassword!' } }, headers: { **@auth_headers }
        expect(response).to have_http_status(:forbidden)
      end

      it 'does not update the password when the old_password is wrong' do
        put "/api/users/#{@other_user.id}", params: { user: { old_password: 'wrongtestpassword', password: 'newpassword!' } }, headers: { **@auth_headers }
        expect(response).to have_http_status(:forbidden)
      end

      it 'fails to update role' do
        put "/api/users/#{@other_user.id}", params: { user: { role: 'TEST_ADMIN' } }, headers: { **@auth_headers }
        expect(User.find(@other_user.id).role).to eq('USER')
      end
    end

    describe 'logout log out' do
      it 'succeeds' do
        post '/api/logout', headers: { **@auth_headers }
        expect(response).to have_http_status(:no_content)
      end

      it 'removes the token' do
        post '/api/logout', headers: { **@auth_headers }
        expect(AuthenticationToken.where(user: @user, token: @token)).to_not exist()
      end
    end
  end

  context 'as an admin' do
    before(:each) do
      post '/api/login', params: { email: @admin.email, password: 'admintestpassword'}
      @token = json['token']
      @auth_headers = { Authorization: "Bearer #{@token}" }
    end

    describe 'access to all users' do
      it 'succeeds' do
        get '/api/users', headers: { **@auth_headers }
        expect(response).to have_http_status(:ok)
      end

      ## TODO: Test for pagination
    end
    
    describe 'access to one user' do
      it 'is successful' do
        get "/api/users/#{@other_user.id}", headers: { **@auth_headers }
        expect(response).to have_http_status(:ok)
      end
  
      it 'retrieves the correct user' do
        get "/api/users/#{@other_user.id}", headers: { **@auth_headers }
        expect(json['id']).to equal(@other_user.id)
      end

      it 'does not return the password digest' do
        get "/api/users/#{@other_user.id}", headers: { **@auth_headers }
        expect(json['password_digest']).to equal(nil)
      end
  
      it 'does not return the verification token' do
        get "/api/users/#{@other_user.id}", headers: { **@auth_headers }
        expect(json['verification_token']).to equal(nil)
      end  
    end

    describe 'user creation' do
      before(:each) do
        @new_user = FactoryBot.attributes_for(:user)
      end

      it 'fails' do
        post '/api/users', params: { user: @new_user }, headers: { **@auth_headers }
        expect(response).to have_http_status(:forbidden)
      end
    end

    describe 'user update' do
      it 'succeeds with PATCH' do
        patch "/api/users/#{@admin.id}", params: { user: { given_name: 'Testing Alice' } }, headers: { **@auth_headers }
        expect(response).to have_http_status(:ok)
        expect(json['given_name']).to eq('Testing Alice')
      end
  
      it 'succeeds with PUT' do
        put "/api/users/#{@admin.id}", params: { user: { family_name: 'Testing Smith' } }, headers: { **@auth_headers }
        expect(response).to have_http_status(:ok)
        expect(json['family_name']).to eq('Testing Smith')
      end
  
      it 'updates the password when the old_password is correct' do
        put "/api/users/#{@admin.id}", params: { user: { old_password: 'admintestpassword', password: 'newpassword!' } }, headers: { **@auth_headers }
        expect(response).to have_http_status(:ok)
      end

      it 'does not update the password when the old_password is wrong' do
        put "/api/users/#{@admin.id}", params: { user: { old_password: 'wrongtestpassword', password: 'newpassword!' } }, headers: { **@auth_headers }
        expect(response).to have_http_status(:forbidden)
      end

      it 'can update own role' do
        put "/api/users/#{@admin.id}", params: { user: { role: 'USER' } }, headers: { **@auth_headers }
        expect(User.find(@admin.id).role).to eq('USER')
      end
    end

    describe 'other user update' do
      it 'succeeds with PATCH' do
        patch "/api/users/#{@other_user.id}", params: { user: { given_name: 'Testing Alice' } }, headers: { **@auth_headers }
        expect(response).to have_http_status(:ok)
        expect(User.find(@other_user.id).given_name).to eq('Testing Alice')
      end
  
      it 'succeeds with PUT' do
        put "/api/users/#{@other_user.id}", params: { user: { family_name: 'Testing Smith' } }, headers: { **@auth_headers }
        expect(response).to have_http_status(:ok)
        expect(User.find(@other_user.id).family_name).to eq('Testing Smith')
      end
  
      it 'does not update the password even if the old_password is correct' do
        put "/api/users/#{@other_user.id}", params: { user: { old_password: 'othertestpassword', password: 'newpassword!' } }, headers: { **@auth_headers }
        expect(response).to have_http_status(:forbidden)
      end

      it 'does not update the password when the old_password is wrong' do
        put "/api/users/#{@other_user.id}", params: { user: { old_password: 'wrongtestpassword', password: 'newpassword!' } }, headers: { **@auth_headers }
        expect(response).to have_http_status(:forbidden)
      end

      it 'can update role' do
        put "/api/users/#{@other_user.id}", params: { user: { role: 'TEST_ADMIN' } }, headers: { **@auth_headers }
        expect(User.find(@other_user.id).role).to eq('TEST_ADMIN')
      end
    end
  end
end
