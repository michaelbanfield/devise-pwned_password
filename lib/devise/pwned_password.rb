# frozen_string_literal: true

require "devise"
require "devise/pwned_password/model"

module Devise
  mattr_accessor :min_password_matches, :pwned_password_open_timeout, :pwned_password_read_timeout
  @@min_password_matches = 1
  @@pwned_password_open_timeout = 5
  @@pwned_password_read_timeout = 5

  module PwnedPassword
  end
end

Devise.add_module :pwned_password, model: "devise_pwned_password/model"
