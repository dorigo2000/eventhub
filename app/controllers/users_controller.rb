class UsersController < ApplicationController
  before_action :require_login

  private

  def require_login
    unless session[:user_id]
      redirect_to root_path
    end
  end
end