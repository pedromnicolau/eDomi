class ContactsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [ :create ]

  def create
    @contact = Contact.new(contact_params)

    if @contact.save
      # Envia o email
      ContactMailer.contact_message(@contact).deliver_now

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
