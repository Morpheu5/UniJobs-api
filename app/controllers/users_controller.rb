# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :set_user, only: %i[show update destroy]

  # GET /users
  def index
    @users = User.all

    render json: @users
  end

  # GET /users/1
  def show
    render json: @user
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
    if @user.update(user_params)
      render json: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # DELETE /users/1
  def destroy
    @user.destroy
  end

  def login
    params.require([:email, :password])

    @user = User.find_by(email: params[:email].downcase)
    if @user.authenticate(params[:password])
      # TODO Create a new token and return this to the user along with some extra info maybe.
      render json: { message: 'All good! :)' }
    else
      render json: { message: 'THOU SHALL NOT PASS!' }
    end
  end

  def logout
    # TODO Destroy the token
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def user_params
    params.require(:user).permit(:email, :email_confirmation, :given_name, :family_name, :password, :password_confirmation)
  end
end
