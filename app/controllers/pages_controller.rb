class PagesController < ApplicationController
  def privacy_policy; end
  def terms; end
  def about; end
  def contact; end

  def submit_contact
    contact = params.fetch(:contact, {}).permit(:name, :email, :message)
    if contact[:name].present? && contact[:email].present? && contact[:message].present?
      # Aqui você pode integrar com ActionMailer ou armazenar a mensagem.
      flash[:notice] = "Mensagem enviada. Obrigado — responderemos em breve."
      redirect_to contact_path
    else
      flash.now[:alert] = "Por favor, preencha nome, email e mensagem."
      render :contact, status: :unprocessable_entity
    end
  end
end
