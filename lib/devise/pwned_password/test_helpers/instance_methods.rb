# frozen_string_literal: true
# Based on https://github.com/paper-trail-gem/paper_trail/blob/master/lib/paper_trail/frameworks/rspec/helpers.rb

module Devise
  module PwnedPassword
    module TestHelpers
      module InstanceMethods
        # enable the check for specific blocks (at instance-level)
        def with_pwned_password_check
          was_enabled = ::Devise.pwned_password_check_enabled
          ::Devise.pwned_password_check_enabled = true
          yield
        ensure
          ::Devise.pwned_password_check_enabled = was_enabled
        end

        def without_pwned_password_check
          was_enabled = ::Devise.pwned_password_check_enabled
          ::Devise.pwned_password_check_enabled = false
          yield
        ensure
          ::Devise.pwned_password_check_enabled = was_enabled
        end
      end
    end
  end
end
