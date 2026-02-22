# frozen_string_literal: true

require "test_helper"

class Devise::PwnedPassword::Test < ActiveSupport::TestCase
  class WhenPwned < Devise::PwnedPassword::Test
    test "should deny validation and set pwned_count" do
      user = User.create(email: "example@example.org", password: "password", password_confirmation: "password")
      user.save(validate: true)
      assert_not user.valid?
      assert_match /\Ahas appeared in a data breach \d{7,} times\z/, user.errors[:password].first
      assert user.pwned_count > 0
    end

    test "when pwned_count < min_password_matches, is considered valid" do
      User.min_password_matches = 999_999_999
      user = User.create(email: "example@example.org", password: "password", password_confirmation: "password")
      user.save(validate: true)
      assert user.valid?
      assert user.pwned_count > 0
    end
  end

  class WhenPwnedError < Devise::PwnedPassword::Test
    test "password_pwned? returns false when Pwned::Error is raised" do
      user = valid_password_user
      mock_password = Minitest::Mock.new
      mock_password.expect(:pwned_count, nil) { raise Pwned::Error, "network error" }
      Pwned::Password.stub :new, mock_password do
        assert_equal false, user.password_pwned?(valid_password)
      end
    end
  end

  class PwnedAccessor < Devise::PwnedPassword::Test
    test "pwned? is false before password_pwned? called" do
      user = User.new
      assert_equal false, user.pwned?
    end

    test "pwned? reflects result after password_pwned? called" do
      user = valid_password_user
      user.password_pwned?(pwned_password)
      assert user.pwned?
    end
  end

  class WhenNotPwned < Devise::PwnedPassword::Test
    test "should accept validation and set pwned_count" do
      user = valid_password_user
      assert user.valid?
      assert_equal user.pwned_count, 0
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
end
