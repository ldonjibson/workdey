# frozen_string_literal: true
module SessionsHelper
  def log_in(user)
    session[:user_id] = user.id
  end

  def log_out
    session.clear
    @current_user = nil
  end

  def current_user
    @current_user ||= User.find_by_id(session[:user_id])
  end

  def logged_in?
    !current_user.nil?
  end
end
