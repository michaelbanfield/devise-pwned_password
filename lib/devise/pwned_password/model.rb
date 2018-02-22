require 'net/http'

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
        validate :not_pwned_password
      end

      module ClassMethods
        Devise::Models.config(self, :min_password_matches)
      end

      private

      def usage_count(response, suffix)
        count = 0
        response.each_line do |line|
          if line.start_with? suffix
            count = line.strip.split(':').last.to_i
            break
          end
        end
        count
      end

      # Returns true if password is present in the PwnedPasswords dataset
      # Implement retry behaviour described here https://haveibeenpwned.com/API/v2#RateLimiting
      def is_password_pwned(password)
        hash = Digest::SHA1.hexdigest(password).upcase
        prefix, suffix = hash.slice!(0..4), hash

        userAgent = "devise_pwned_password"

        uri = URI.parse("https://api.pwnedpasswords.com/range/#{prefix}")

        Net::HTTP.start(uri.host, uri.port, :use_ssl => true) do |http|
          request = Net::HTTP::Get.new(uri.request_uri, {'User-Agent' => userAgent})
          response = http.request request
          return usage_count(response.read_body, suffix) > self.class.min_password_matches
        end

        return false
      end

      def not_pwned_password
        
        #This deliberately fails silently on 500's etc. Most apps wont want to tie the ability to sign up customers to the availability of a third party API
        if is_password_pwned(password)
          # Error message taken from https://haveibeenpwned.com/Passwords
          errors.add(:password, "This password has previously appeared in a data breach and should never be used. Please choose something harder to guess.")
        end
      end
    end
  end
end