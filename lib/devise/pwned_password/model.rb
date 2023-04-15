# frozen_string_literal: true

require "pwned"
require "devise/pwned_password/hooks/pwned_password"

module Devise
  module Models
    # The PwnedPassword module adds a new validation for Devise Models.
    # No modifications to routes or controllers needed.
    # Simply add :pwned_password to the list of included modules in your
    # devise module, and all new registrations will be blocked if they use
    # a password in this dataset https://haveibeenpwned.com/Passwords.
    module PwnedPassword
      extend ActiveSupport::Concern

      included do
        validate :not_pwned_password,
          if: (defined?(ActiveRecord) && ActiveRecord.gem_version >= Gem::Version.new("5.1.x")) ? :will_save_change_to_encrypted_password? : :encrypted_password_changed?
      end

      module ClassMethods
        Devise::Models.config(self, :min_password_matches)
        Devise::Models.config(self, :min_password_matches_warn)
        Devise::Models.config(self, :pwned_password_check_on_sign_in)
        Devise::Models.config(self, :pwned_password_open_timeout)
        Devise::Models.config(self, :pwned_password_read_timeout)
      end

      def pwned?
        @pwned ||= false
      end

      def pwned_count
        @pwned_count ||= 0
      end

      # Returns true if password is present in the PwnedPasswords dataset
      def password_pwned?(password)
        @pwned = false
        @pwned_count = 0

        options = {
          headers: { "User-Agent" => "devise_pwned_password" },
          read_timeout: self.class.pwned_password_read_timeout,
          open_timeout: self.class.pwned_password_open_timeout
        }
        pwned_password = Pwned::Password.new(password.to_s, options)
        begin
          @pwned_count = pwned_password.pwned_count
          @pwned = @pwned_count >= (
            if persisted?
              # If you do have a different warning threshold, that threshold will also be used
              # when a user changes their password so that they don't continue to be warned if they
              # choose another password that is in the pwned list but occurs with a frequency below
              # the main threshold that is used for *new* user registrations.
              self.class.min_password_matches_warn || self.class.min_password_matches
            else
                                                      self.class.min_password_matches
            end
          )
          return @pwned
        rescue Pwned::Error
          # This deliberately silently swallows errors and returns false (valid) if there was an error. Most apps won't want to tie the ability to sign up users to the availability of a third-party API.
          return false
        end

        false
      end

      private

        def not_pwned_password
          if password_pwned?(password)
            errors.add(:password, :pwned_password, count: @pwned_count)
          end
        end
    end
  end
end
