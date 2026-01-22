class UsersController < ApplicationController
  before_action :require_login, only: %i[edit update]

  def new
    @user = User.new
  end

  def edit
    @user = current_user
  end

  def create
    @user = User.new(user_params)

    if @user.save
      session[:user_id] = @user.id
      redirect_to root_path, notice: "Account created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @user = current_user

    if @user.update(user_update_params)
      redirect_to root_path, notice: "Account updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end

  def user_update_params
    attrs = user_params
    if attrs[:password].blank?
      attrs = attrs.except(:password, :password_confirmation)
    end
    attrs
  end
end
