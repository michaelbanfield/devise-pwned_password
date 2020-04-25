# frozen_string_literal: true

require "test_helper"

class Devise::PwnedPassword::Test < ActiveSupport::TestCase
  def setup
    User.min_password_matches = 1
    User.min_password_matches_warn = nil
    Devise.pwned_password_check_enabled = true
  end

  class WhenPwned < Devise::PwnedPassword::Test
    test "should deny validation and set pwned_count" do
      user = pwned_password_user
      assert_not user.valid?
      assert_match /\Ahas appeared in a data breach \d{7,} times\z/, user.errors[:password].first
      assert user.pwned_count > 0
    end

    test "when pwned_count < min_password_matches, is considered valid" do
      user = pwned_password_user
      User.min_password_matches = 999_999_999
      assert user.valid?
      assert user.pwned_count > 0
    end

    test "when pwned_password_check_enabled = false, is considered valid" do
      user = pwned_password_user
      Devise.pwned_password_check_enabled = false
      assert user.valid?
      assert_equal 0, user.pwned_count
    end
  end

  class WhenNotPwned < Devise::PwnedPassword::Test
    test "should accept validation and set pwned_count" do
      user = valid_password_user
      assert user.valid?
      assert_equal 0, user.pwned_count
    end

    test "when password changed to a pwned password: should add error if pwned_count > min_password_matches_warn || pwned_count > min_password_matches" do
      user = valid_password_user

      # *not* pwned_count > min_password_matches_warn
      password = "password"
      user.update password: password, password_confirmation: password
      User.min_password_matches_warn = 999_999_999
      assert user.valid?
      assert_not user.pwned_count > User.min_password_matches_warn

      # pwned_count > min_password_matches_warn
      User.min_password_matches_warn = 1
      User.min_password_matches      = 999_999_999
      assert_not user.valid?
      assert user.pwned_count > User.min_password_matches_warn
    end
  end

  def pwned_password_user
    password = "password"
    user = User.create email: "example@example.org", password: password, password_confirmation: password
    assert user.errors.size > 0
    user
  end

  def valid_password_user
    password = "fddkasnsdddghjt"
    user = User.create email: "example@example.org", password: password, password_confirmation: password
    assert_equal 0, user.errors.size
    user
  end
end
