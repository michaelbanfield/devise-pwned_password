# frozen_string_literal: true

require "devise"
require "devise/pwned_password/model"

module Devise
  mattr_accessor :min_password_matches
  @@min_password_matches = 1

  module PwnedPassword
  end
end

Devise.add_module :pwned_password, model: "devise_pwned_password/model"
