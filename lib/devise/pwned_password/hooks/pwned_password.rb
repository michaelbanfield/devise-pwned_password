# frozen_string_literal: true

Warden::Manager.after_set_user except: :fetch do |user, auth, opts|
  password = auth.request.params.fetch(opts[:scope], {}).fetch(:password, nil)
  password && auth.authenticated?(opts[:scope]) && user.respond_to?(:password_pwned?) && user.password_pwned?(password)
end
