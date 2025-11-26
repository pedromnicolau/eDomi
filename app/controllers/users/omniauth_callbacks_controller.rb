class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    auth = request.env["omniauth.auth"]
    @user = User.from_omniauth(auth)

    if @user.persisted?
      sign_in @user, event: :authentication

      # Força persistir a sessão
      request.env["warden"].set_user(@user, scope: :user, store: true)

      if @user.must_set_password?
        redirect_to "/users/password/set"
      else
        redirect_to root_path
      end
    else
      session["devise.google_data"] = auth.except("extra")
      redirect_to "/users/sign_in?error=#{CGI.escape(@user.errors.full_messages.join(', '))}"
    end
  end

  def failure
    message = failure_message || "Autenticação cancelada"
    redirect_to "/users/sign_in?error=#{CGI.escape(message)}"
  end
end
