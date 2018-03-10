# frozen_string_literal: true

require "net/http"
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
        validate :not_pwned_password, if: :password_required?
      end

      module ClassMethods
        Devise::Models.config(self, :min_password_matches)
        Devise::Models.config(self, :pwned_password_open_timeout)
        Devise::Models.config(self, :pwned_password_read_timeout)
      end

      def pwned?
        @pwned ||= false
      end

      # Returns true if password is present in the PwnedPasswords dataset
      # Implement retry behaviour described here https://haveibeenpwned.com/API/v2#RateLimiting
      def password_pwned?(password)
        @pwned = false
        hash = Digest::SHA1.hexdigest(password.to_s).upcase
        prefix, suffix = hash.slice!(0..4), hash

        userAgent = "devise_pwned_password"

        uri = URI.parse("https://api.pwnedpasswords.com/range/#{prefix}")

        begin
          Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: self.class.pwned_password_open_timeout, read_timeout: self.class.pwned_password_read_timeout) do |http|
            request = Net::HTTP::Get.new(uri.request_uri, "User-Agent" => userAgent)
            response = http.request request
            return false unless response.is_a?(Net::HTTPSuccess)
            @pwned = usage_count(response.read_body, suffix) >= self.class.min_password_matches
            return @pwned
          end
        rescue StandardError
          return false
        end

        false
      end

      private

        def usage_count(response, suffix)
          count = 0
          response.each_line do |line|
            if line.start_with? suffix
              count = line.strip.split(":").last.to_i
              break
            end
          end
          count
        end

        def not_pwned_password
          # This deliberately fails silently on 500's etc. Most apps wont want to tie the ability to sign up customers to the availability of a third party API
          if password_pwned?(password)
            errors.add(:password, :pwned_password)
          end
        end
    end
  end
end
