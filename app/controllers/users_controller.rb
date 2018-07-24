# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :set_user, only: %i[show update destroy]
  after_action :verify_authorized, except: %i[index show create login]

  # GET /users
  def index
    @users = User.all
    render json: @users
  end

  # GET /users/1
  def show
    render json: @user, except: [ :password_digest ]
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
    # TODO Maybe consider blanking out info and deactivating rather than deleting outright.
    @user.destroy
  end

  def login
    params.require([:email, :password])

    @user = User.find_by(email: params[:email].downcase)
    if @user.authenticate(params[:password])
      token = loop do
        _token = SecureRandom.hex(16)
        break _token unless AuthenticationToken.where(user: @user, token: _token).exists?
      end
      auth_token = AuthenticationToken.create user: @user, token: token
      render json: { message: 'All good! :)', token: token }
    else
      render json: { message: 'THOU SHALL NOT PASS!' }
    end
  end

  def logout
    token = AuthenticationToken.find_by(token: request.headers['X-Auth-Token'])
    if token.nil?
      skip_authorization
    else
      authorize token.user
      token.destroy
    end
  end

  private

  def current_user
    token = AuthenticationToken.find_by(token: request.headers['X-Auth-Token'])
    token.user unless token.nil?
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
