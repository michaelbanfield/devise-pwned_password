require 'test_helper'

class SignUpTest < ActionDispatch::IntegrationTest
  test "using a valid password" do
    sign_up_user password: valid_password
    assert_content 'You have signed up successfully.'
  end

  test 'submitting password whose length < minimum password length' do
    sign_up_user password: '123456'
    assert_content '8 characters minimum'
  end

  test "using a pwned password" do
    sign_up_user password: pwned_password
    assert_content /has appeared in a data breach \d{7,} times/
  end
end

class SignInTest < ActionDispatch::IntegrationTest
  test 'signing in with a valid password' do
    user = valid_password_user
    sign_in_user user, password: valid_password

    assert_css '.notice', text: 'Signed in successfully.'
  end

  test 'signing in with a pwned password' do
    user = pwned_password_user
    sign_in_user user, password: pwned_password

    # Shows warning but doesn't prevent them from signing in
    assert_css '.notice', text: 'Signed in successfully.'
    assert_css '.alert', text: 'We strongly recommend you change your password.'
  end
end

class ChangePasswordTest < ActionDispatch::IntegrationTest
  test 'changing to a valid password' do
    user = valid_password_user
    sign_in_user user, password: valid_password
    change_password current: valid_password, new: "#{valid_password}2"
    assert_content 'has been updated successfully'
  end

  test 'changing to a pwned password' do
    user = valid_password_user
    sign_in_user user, password: valid_password
    change_password current: valid_password, new: pwned_password
    assert_content /has appeared in a data breach \d{7,} times/
  end
end
