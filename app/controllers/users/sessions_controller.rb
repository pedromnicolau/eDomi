class Users::SessionsController < Devise::SessionsController
  skip_before_action :verify_authenticity_token, only: [ :create, :destroy ]
  respond_to :json

  def create
    self.resource = warden.authenticate(auth_options)

    if resource
      sign_in(resource_name, resource)
      yield resource if block_given?
      render json: {
        id: resource.id,
        email: resource.email,
        name: resource.name
      }, status: :ok
    else
      render json: {
        error: "Email ou senha incorretos. Verifique suas credenciais e tente novamente."
      }, status: :unauthorized
    end
  rescue => e
    render json: {
      error: "Email ou senha incorretos. Verifique suas credenciais e tente novamente."
    }, status: :unauthorized
  end

  def destroy
    signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
    yield if block_given?
    respond_to_on_destroy
  end

  def after_sign_in_path_for(resource)
    root_path
  end

  protected

  def respond_to_on_destroy
    if request.format.json? || request.xhr? || request.headers['Accept'].to_s.include?('application/json')
      head :no_content
    else
      redirect_to root_path, status: :see_other
    end
  end
end
