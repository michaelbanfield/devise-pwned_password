# frozen_string_literal: true

Warden::Manager.after_set_user except: :fetch do |user, auth, opts|
  if user.class.respond_to?(:pwned_password_check_on_sign_in) && user.class.pwned_password_check_on_sign_in
    password = auth.request.params.fetch(opts[:scope], {}).fetch(:password, nil)
    password && auth.authenticated?(opts[:scope]) && user.respond_to?(:password_pwned?) && user.password_pwned?(password)
  end
end
