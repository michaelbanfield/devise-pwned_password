# frozen_string_literal: true

require "devise"
require "devise/pwned_password/model"

module Devise
  mattr_accessor :min_password_matches, :min_password_matches_warn, :pwned_password_check_on_sign_in,
                 :pwned_password_open_timeout, :pwned_password_read_timeout
  @@min_password_matches = 1
  @@min_password_matches_warn = nil
  @@pwned_password_check_on_sign_in = true
  @@pwned_password_open_timeout = 5
  @@pwned_password_read_timeout = 5

  module PwnedPassword
  end
end

# Load default I18n
#
I18n.load_path.unshift File.join(File.dirname(__FILE__), *%w[pwned_password locales en.yml])

Devise.add_module :pwned_password, model: "devise_pwned_password/model"
