# frozen_string_literal: true

require "test_helper"

class Devise::PwnedPassword::Test < ActiveSupport::TestCase
  test "should deny validation for a pwned password" do
    user = User.create email: "example@example.org", password: "password", password_confirmation: "password"
    assert_not user.valid?, "User with pwned password shoud not be valid."
  end
  test "should accept validation for a password not in the dataset" do
    # This test will be unavoidably flaky
    password = "fddkasnsdddghjt"
    user = User.create email: "example@example.org", password: password, password_confirmation: password
    assert user.valid?, "User with password not in the dataset should be valid."
  end
end
