class ApplicationMailer < ActionMailer::Base
  # Use resend.dev domain for development, your verified domain for production
  default from: Rails.env.production? ? "eDomi <noreply@edomi.com.br>" : "eDomi <onboarding@resend.dev>"
  layout "mailer"
end
