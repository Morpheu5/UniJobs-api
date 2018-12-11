# frozen_string_literal: true

module Api
  module V1
    class UsersController < ApplicationController
      include ::V1::Authenticatable

      before_action :set_user, only: %i[show update destroy]
      after_action :verify_authorized, except: %i[index show create login verify_email]

      def_param_group :user_creation_params do
        param :user, Hash do
          param :email, String, required: true
          param :password, String, required: true
          param :given_name, String
          param :family_name, String
          param :gender, ['male', 'female', 'other', 'unspecified'], allow_nil: true
        end
      end

      def_param_group :user_update_params do
        param :user, Hash do
          param :email, String
          param :old_password, String
          param :password, String, 'Only required if old_password is present'
          param :given_name, String
          param :family_name, String
          param :gender, ['male', 'female', 'other', 'unspecified'], allow_nil: true
          param :role, ['USER', 'ADMIN']
        end
      end

      def_param_group :user_response do
        property :id, Integer, required: true
        property :email, String, required: true
        property :given_name, String, required: false
        property :family_name, String, required: false
        property :role, ['USER', 'ADMIN'], required: true
        property :gender, ['male', 'female', 'other', 'unspecified'], allow_nil: true
        property :email_verified, [true, false], required: true
        property :created_at, String, required: true
        property :updated_at, String, required: true
      end

      api :GET, '/users', 'List users'
      error :unauthorized, 'On anonymous requests'
      error :forbidden, 'The requesting user is not an admin'
      returns :array_of => :user_response, code: 200, desc: 'All the users'
      def index
        @user = current_user
        if @user.nil?
          skip_authorization
          head :unauthorized
        else
          authorize @user
          ## TODO: Add pagination
          @users = User.all
          render json: @users, except: %i[password_digest verification_token]
        end
      end

      # GET /users/1
      api :GET, '/users/:id', 'Show one user'
      param :id, :number, 'The numeric ID of the user to retrieve', required: true
      error :not_found, 'User not found'
      returns :user_response
      def show
        render  json: @user,
                except: %i[password_digest verification_token],
                include: {
                  organizations: {
                    except: %i[parent_id created_at updated_at],
                    include: {
                      ancestors: {}
                    }
                  }
                }
      end

      api :POST, '/users', 'Create a new regular user'
      param_group :user_creation_params
      error :forbidden, 'Logged in users should not be able to create a new user'
      error :unprocessable_entity, 'Could not create the user'
      returns :user_response
      def create
        return head :forbidden unless current_user.nil?

        @user = User.new(user_params)
        # Force new user's role to be USER, can be upgraded later
        @user.role = 'USER'
        @user.verification_token = SecureRandom.urlsafe_base64(8)
        if @user.save
          # TODO: Add locale info
          UserMailer.with(user: @user).verify_email.deliver_now
          render  json: @user,
                  except: %i[password_digest verification_token],
                  status: :created
        else
          render json: @user.errors, status: :unprocessable_entity
        end
      end

      api :PATCH, '/users/:id', 'Update a user'
      api :PUT, '/users/:id', 'Update a user (see PATCH)'
      description 'Role updates are reserved to ADMINs.'
      param :id, :number, 'The numeric ID of the user to update', required: true
      param_group :user_update_params
      error :unauthorized, 'On anonymous requests'
      error :forbidden, 'Logged in user does not have permission to update the user'
      error :unprocessable_entity, 'Could not save changes to the user'
      returns :user_response
      def update
        authorize @user
        new_user_params = user_params
        new_user_params[:role] = @user.role unless (current_user.role == 'ADMIN' or current_user.id != @user.id)
        if new_user_params[:old_password]
          return head :forbidden unless @user == current_user
          # Re-check that the user has entered the right current password
          if @user&.authenticate(new_user_params[:old_password])
            if @user.update(password: new_user_params[:password])
              render json: @user, except: %i[password_digest verification_token]
            else
              render json: @user.errors, status: :unprocessable_entity
            end
          else
            head :forbidden
          end
        elsif @user.update(new_user_params)
          render json: @user, except: %i[password_digest verification_token]
        else
          render json: @user.errors, status: :unprocessable_entity
        end
      end

      api :DELETE, '/users/:id', 'Does not quite work yet'
      param :id, :number, 'The numeric ID of the user to delete', required: true
      def destroy
        authorize @user
        # TODO: Maybe consider blanking out info and deactivating rather than deleting outright.
        # @user.destroy
      end

      api :GET, '/users/whoami', 'Returns the currently logged-in user'
      returns code: :ok do
        param_group :user_response
        property :verification_token, String, required: false, allow_nil: true
      end
      error :no_content, 'On anonymous requests'
      def whoami
        @user = current_user
        if @user.nil?
          skip_authorization
        else
          authorize @user
          render json: @user, except: %i[password_digest]
        end
      end

      api :POST, '/users/verify_email', 'Email verification'
      param :token, String, 'Verification token as emailed on user registration', required: true
      error :not_found, 'The user to be verified was not found'
      def verify_email
        token = params.require(%i[token])

        @user = User.find_by(verification_token: token)
        if @user.nil?
          head :not_found
        else
          @user.verification_token = nil
          @user.email_verified = true
          @user.save
          head :no_content
        end
      end

      api :POST, '/login', 'Login with credentials'
      param :email, String, 'Email address used as login', required: true
      param :password, String, 'Password', required: true
      error :forbidden, 'Invalid credentials'
      returns code: :ok do
        property :message, String, required: true
        property :user_id, String, required: true
        property :token, String, 'Bearer token', required: true
      end
      def login
        params.require(%i[email password])

        @user = User.find_by(email: params[:email].downcase)
        if @user&.authenticate(params[:password])
          db_token = create_token_for_user @user
          payload = { sub: @user.id, iat: Time.now.to_i }
          jwt_token = JWT.encode(payload, db_token.token, 'HS512')
          render json: { message: 'All good! :)', user_id: db_token.user_id, token: jwt_token }
        else
          head :forbidden, error: 'THOU SHALL NOT PASS!'
        end
      end

      api :POST, '/logout', 'Logout'
      def logout
        @user = current_user
        skip_authorization if @user.nil?
        authenticate_with_http_token do |token, _options|
          db_token = verify_token(token)
          authorize db_token, :destroy?
          db_token.destroy
        end
      end

      private

      def create_token_for_user(user)
        loop do
          temp_token = SecureRandom.hex(64)
          break AuthenticationToken.create(user: @user, token: temp_token) unless AuthenticationToken.where(user: user, token: temp_token).exists?
        end
      end

      # Use callbacks to share common setup or constraints between actions.
      def set_user
        @user = User.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def user_params
        params.require(:user).permit(:email, :given_name, :family_name, :password, :old_password, :gender, :role)
      end
    end
  end
end
