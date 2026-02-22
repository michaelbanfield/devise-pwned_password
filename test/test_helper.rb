# frozen_string_literal: true

Bundler.require :development

require File.expand_path("../../test/dummy/config/environment.rb", __FILE__)
ActiveRecord::Migrator.migrations_paths = [File.expand_path("../../test/dummy/db/migrate", __FILE__)]
require "rails/test_help"

require 'minitest/mock'
require 'capybara/dsl'

# Filter out Minitest backtrace while allowing backtrace from other libraries
# to be shown.
Minitest.backtrace_filter = Minitest::BacktraceFilter.new

Rails::TestUnitReporter.executable = "bin/test"

# Load fixtures from the engine
if ActiveSupport::TestCase.respond_to?(:fixture_path=)
  ActiveSupport::TestCase.fixture_path = File.expand_path("../fixtures", __FILE__)
  ActionDispatch::IntegrationTest.fixture_path = ActiveSupport::TestCase.fixture_path
  ActiveSupport::TestCase.file_fixture_path = ActiveSupport::TestCase.fixture_path + "/files"
  ActiveSupport::TestCase.fixtures :all
end

class ActiveSupport::TestCase
  def setup
    super
    User.min_password_matches = 1
    User.min_password_matches_warn = nil
    User.pwned_password_check_on_sign_in = true
  end
end

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

# Stub network calls to the Pwned Passwords service so tests
# don't rely on external connectivity. Any password equal to
# 'password' will be treated as pwned with a high count while
# others will be considered safe.
module Pwned
  class Password
    def pwned_count
      @pwned_count ||= (password == 'password' ? 1_000_000 : 0)
    end
    def pwned?
      pwned_count > 0
    end
  end
end
