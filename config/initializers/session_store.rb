# frozen_string_literal: true

# Session cookie defaults to host-only in production.
# Set SESSION_COOKIE_DOMAIN to enable cross-subdomain cookies when needed:
# - SESSION_COOKIE_DOMAIN=.edomi.com.br (explicit domain)
# - SESSION_COOKIE_DOMAIN=all with SESSION_COOKIE_TLD_LENGTH=2 (automatic root domain)
session_store_options = {
  key: "_edomi_session",
  secure: Rails.env.production?,
  httponly: true,
  same_site: :lax
}

if Rails.env.production?
  cookie_domain = ENV["SESSION_COOKIE_DOMAIN"].to_s.strip

  if cookie_domain.casecmp("all").zero?
    session_store_options[:domain] = :all
    session_store_options[:tld_length] = ENV.fetch("SESSION_COOKIE_TLD_LENGTH", "2").to_i
  elsif cookie_domain.present?
    session_store_options[:domain] = cookie_domain
  end
end

Rails.application.config.session_store :cookie_store, **session_store_options
