# frozen_string_literal: true

module Api
  module V1
    class UsersController < ApplicationController
      include ::V1::Authenticatable

      before_action :set_user, only: %i[show update destroy]
      after_action :verify_authorized, except: %i[index show create login verify_email]

      # GET /users
      def index
        @user = current_user
        if @user.nil?
          skip_authorization
          head :unauthorized
        else
          authorize @user
          @users = User.all
          render json: @users, except: %i[password_digest verification_token]
        end
      end

      # GET /users/1
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

      # POST /users
      def create
        @user = User.new(user_params)
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
        if user_params[:old_password]
          # Re-check that the user has entered the right current password
          if @user&.authenticate(user_params[:old_password])
            if @user.update(password: user_params[:password])
              render json: @user, except: [:password_digest]
            else
              render json: @user.errors, status: :unprocessable_entity
            end
          else
            head :unauthorized
          end
        elsif @user.update(user_params)
          render json: @user, except: [:password_digest]
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
          render json: @user, except: [:password_digest]
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
        params.require(:user).permit(:email, :given_name, :family_name, :password, :old_password, :gender)
      end
    end
  end
end
