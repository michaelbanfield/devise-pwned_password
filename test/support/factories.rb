module Factories
  def create_user(password:)
    user = User.create(email: "example@example.org", password: password, password_confirmation: password)
    user.save(validate: false)
    user
  end

  def pwned_password
    'password'
  end

  def pwned_password_user
    user = create_user(password: pwned_password)
    #puts %(user.errors.messages=#{(user.errors.messages).inspect})
    user
  end

  def valid_password
    'fddkasnsdddghjt'
  end

  def valid_password_user
    user = create_user(password: valid_password)
    assert_equal 0, user.errors.size
    user
  end
end

class ActiveSupport::TestCase
  include Factories
end
