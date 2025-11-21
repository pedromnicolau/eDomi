class ContactsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [ :create ]

  def create
    @contact = Contact.new(contact_params)

    if @contact.save
      # Envia o email (tenta em background; em caso de falha, log e não retorna 500)
      begin
        ContactMailer.contact_message(@contact).deliver_later
      rescue => e
        Rails.logger.error("Falha ao enfileirar ContactMailer: #{e.message}")
      end

      render json: { message: "Mensagem enviada com sucesso!" }, status: :created
    else
      render json: { error: @contact.errors.full_messages.join(", ") }, status: :unprocessable_entity
    end
  end

  private

  def contact_params
    params.require(:contact).permit(:name, :email, :message)
  end
end
