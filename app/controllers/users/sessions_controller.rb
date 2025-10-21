class Users::SessionsController < Devise::SessionsController
  # quando a tela de login for exibida com ?redirect_to=... salvamos em session para usar após login
  def new
    session[:user_return_to] = params[:redirect_to] if params[:redirect_to].present?
    super
  end

  # após login, usa o path salvo (inclui query) se presente, caso contrário fallback padrão do Devise
  def after_sign_in_path_for(resource)
    session.delete(:user_return_to) || super
  end
end
