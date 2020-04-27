# frozen_string_literal: true
# Based on https://github.com/paper-trail-gem/paper_trail/blob/master/lib/paper_trail/frameworks/rspec.rb

require "rspec/core"

RSpec.configure do |config|
  config.include ::Devise::PwnedPassword::TestHelpers::InstanceMethods

  config.before(:each) do
    ::Devise.pwned_password_check_enabled = false
  end

  config.before(:each, pwned_password_check: true) do
    ::Devise.pwned_password_check_enabled = true
  end
end
