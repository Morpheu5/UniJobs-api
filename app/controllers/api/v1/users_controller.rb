# frozen_string_literal: true

module Api
  module V1
    class UsersController < ApplicationController
      include ::V1::Authenticatable

      before_action :set_user, only: %i[show update destroy]
      after_action :verify_authorized, except: %i[index show create login verify_email]

      def_param_group :user do
        property :email, String, required: true
        property :given_name, String
        property :family_name, String
        property :role, String, required: true
        property :gender, ['male', 'female', 'other', 'unspecified']
        property :email_verified, [true, false], required: true
        property :created_at, String, required: true
        property :updated_at, String, required: true
      end

      def_param_group :user_response do
        property :id, Integer, required: true
        property :email, String, required: true
        property :given_name, String, required: false
        property :family_name, String, required: false
        property :role, String, required: true
        property :gender, ['male', 'female', 'other', 'unspecified']
        property :email_verified, [true, false], required: true
        property :created_at, String, required: true
        property :updated_at, String, required: true
      end

      api :GET, '/users', 'List users'
      error code: 401, desc: 'Unauthorized'
      error code: 403, desc: 'Forbidden'
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
      param :id, :number, 'The numeric ID of the user to retrieve'
      error code: 404, desc: 'Not found'
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

      api :POST, '/users'
      def create
        ## TODO: Maybe admins could create users...
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

      # PATCH/PUT /users/1
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

      # DELETE /users/1
      def destroy
        authorize @user
        # TODO: Maybe consider blanking out info and deactivating rather than deleting outright.
        # @user.destroy
      end

      def whoami
        @user = current_user
        if @user.nil?
          skip_authorization
        else
          authorize @user
          render json: @user, except: %i[password_digest]
        end
      end

      def verify_email
        token = params.require(%i[token])

        @user = User.find_by(verification_token: token)
        if @user.nil?
          head :unauthorized
        else
          @user.verification_token = nil
          @user.email_verified = true
          @user.save
          head :no_content
        end
      end

      # POST /login
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

      # POST /logout
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
