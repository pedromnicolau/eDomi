class Users::SessionsController < Devise::SessionsController
  # quando a tela de login for exibida com ?redirect_to=... salvamos em session para usar após login
  def new
    session[:user_return_to] = params[:redirect_to] if params[:redirect_to].present?
    super
  end

  def after_sign_in_path_for(resource)
    root_path
  end
end
