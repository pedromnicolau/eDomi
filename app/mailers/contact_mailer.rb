class ContactMailer < ApplicationMailer
  default from: "noreply@edomi.com.br"

  def contact_message(contact)
    @contact = contact

    mail(
      to: "contato@edomi.com.br",
      subject: "Nova mensagem de contato - #{contact.name}",
      reply_to: contact.email
    )
  end
end
