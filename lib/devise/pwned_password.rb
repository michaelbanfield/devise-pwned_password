require 'devise'
require 'devise/pwned_password/model'

module Devise
  module PwnedPassword
  end
end

Devise.add_module :pwned_password, model: "devise_pwned_password/model"