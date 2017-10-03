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

      private


      # Returns true if password is present in the PwnedPasswords dataset
      # Implement retry behaviour described here https://haveibeenpwned.com/API/v2#RateLimiting
      def is_password_pwned(password)

        sha1Hash = Digest::SHA1.hexdigest password

        userAgent = "#{Rails.application.class.parent_name}-devise_pwned_password"

        uri = URI.parse("https://haveibeenpwned.com/api/v2/pwnedpassword/#{sha1Hash}")

        Net::HTTP.start(uri.host, uri.port, :use_ssl => true) do |http|
          request = Net::HTTP::Get.new(uri.request_uri, {'User-Agent' => userAgent})
          3.times {
            response = http.request request
            if response.code != '429'
              return response.code == '200'
            end

            retryAfter = response.get_fields('Retry-After')[0].to_i

            if retryAfter > 10
              #Exit early if the throttling is too high
              return false
            end

            sleep retryAfter
          } 
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