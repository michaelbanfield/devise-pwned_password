# Configure capybara for integration testing
require 'capybara/rails'
require 'capybara/minitest'
Capybara.default_driver   = :rack_test
Capybara.default_selector = :css

class ActionDispatch::IntegrationTest
  include Capybara::DSL
  include Capybara::Minitest::Assertions
  include Rails.application.routes.url_helpers
  include Warden::Test::Helpers

  def setup
    super
  end

  def teardown
    Capybara.reset_sessions!
    Capybara.use_default_driver
  end

  def sign_up_user(password:)
    visit new_user_registration_path

    #puts page.html
    fill_in 'Email', with: 'new_user@test.com'
    fill_in 'Password',              with: password
    fill_in 'Password confirmation', with: password

    click_button 'Sign up'
  end

  def sign_in_user(user, password:)
    visit new_user_session_path
    assert_equal current_path, '/users/sign_in'

    fill_in 'Email',    with: user.email
    fill_in 'Password', with: password

    click_button 'Log in'
    user
  end

  def change_password(current:, new:)
    visit edit_user_registration_path

    #puts page.html
    fill_in 'Current password',      with: current
    fill_in 'Password',              with: new
    fill_in 'Password confirmation', with: new

    click_button 'Update'
  end
end
