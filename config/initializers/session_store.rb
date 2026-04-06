# frozen_string_literal: true

# Keep session cookie valid across edomi.com.br and any subdomain in production.
session_domain = if Rails.env.production?
  :all
else
  nil
end

Rails.application.config.session_store :cookie_store,
  key: "_edomi_session",
  secure: Rails.env.production?,
  httponly: true,
  same_site: :lax,
  domain: session_domain,
  tld_length: 2
