# frozen_string_literal: true

class UsersController < ApplicationController
  include Authenticatable

  before_action :set_user, only: %i[show update destroy]
  after_action :verify_authorized, except: %i[index show create login]

  # GET /users
  def index
    @users = User.all
    render json: @users
  end

  # GET /users/1
  def show
    render json: @user, except: [:password_digest]
  end

  # POST /users
  def create
    @user = User.new(user_params)
    if @user.save
      render json: @user, status: :created, location: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /users/1
  def update
    authorize @user
    if @user.update(user_params)
      render json: @user
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

  # POST /login
  def login
    params.require(%i[email password])

    @user = User.find_by(email: params[:email].downcase)
    if @user&.authenticate(params[:password])
      db_token = create_token_for_user @user
      render json: { message: 'All good! :)', user_id: db_token.user_id, token: db_token.token }
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
    params.require(:user).permit(:email, :email_confirmation, :given_name, :family_name, :password, :password_confirmation)
  end
end
