# Devise::PwnedPassword
Devise extension that checks user passwords against the PwnedPasswords dataset https://haveibeenpwned.com/Passwords

Based on

https://github.com/HCLarsen/devise-uncommon_password

Recently the HaveIBeenPwned API has moved to a authenticated/paid [model](https://www.troyhunt.com/authentication-and-the-have-i-been-pwned-api/) , this does not effect the PwnedPasswords API, no payment or authentication is required.


## Usage
Add the :pwned_password module to your existing Devise model.

```ruby
class AdminUser < ApplicationRecord
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable, :pwned_password
end
```

Users will receive the following error message if they use a password from the
PwnedPasswords dataset:

```
Password has previously appeared in a data breach and should never be used. Please choose something harder to guess.
```

You can customize this error message by modifying the `devise` YAML file.

```yml
# config/locales/devise.en.yml
en:
  errors:
    messages:
      pwned_password: "has previously appeared in a data breach and should never be used. If you've ever used it anywhere before, change it immediately!"
```

You can optionally warn existing users when they sign in if they are using a password from the PwnedPasswords dataset. The default message is:

```
Your password has previously appeared in a data breach and should never be used. We strongly recommend you change your password.
```

You can customize this message by modifying the `devise` YAML file.

```yml
# config/locales/devise.en.yml
en:
  devise:
    sessions:
      warn_pwned: "Your password has previously appeared in a data breach and should never be used. We strongly recommend you change your password everywhere you have used it."
```

By default passwords are rejected if they appear at all in the data set.
Optionally, you can add the following snippet to `config/initializers/devise.rb`
if you want the error message to be displayed only when the password is present
a certain number of times in the data set:

```ruby
# Minimum number of times a pwned password must exist in the data set in order
# to be reject.
config.min_password_matches = 10
```

By default the value set above is used to reject passwords and warn users.
Optionally, you can add the following snippet to `config/initializers/devise.rb`
if you want to use different thresholds for rejecting the password and warning
the user (for example you may only want to reject passwords that are common but
warn if the password occurs at all in the list):

```ruby
# Minimum number of times a pwned password must exist in the data set in order
# to warn the user.
config.min_password_matches_warn = 1
```

By default responses from the PwnedPasswords API are timed out after 5 seconds
to reduce potential latency problems.
Optionally, you can add the following snippet to `config/initializers/devise.rb`
to control the timeout settings:

```ruby
config.pwned_password_open_timeout = 1
config.pwned_password_read_timeout = 2
```

### Disabling in test environments

Because calling a remote API can slow down tests, and requiring non-pwned passwords can make test fixtures needlessly complex (dynamically generated passwords), you probably want to disable the `pwned_password` check in your tests. You can disable the `pwned_password` check for the test environments by adding this to your `config/initializers/devise.rb` file:

```ruby
config.pwned_password_check_enabled = !Rails.env.test?
```

If there are any tests that required the check to be enabled (such as tests for specifically testing the flow/behavior for what should happen when a user does try to use, or already have, a pwned password), you can temporarily set `Devise.pwned_password_check_enabled = true` for the duration of the test (just be sure to reset it back at the end).

To make it easier to turn this check on or off, a `with_pwned_password_check` (and complimentary `without_pwned_password_check`) method is provided:

```ruby
  it "doesn't let you change your password to a compromised password" do
    fill_in 'user_password', with: 'Password'
    with_pwned_password_check do
      click_button 'Save changes'
    end
  end
```

To use these helpers, add to your `test/test_helper.rb` or `spec/spec_helper.rb`:

```ruby
require 'devise/pwned_password/test_helpers'
```

If using RSpec, that's all you need to do: It will automaticaly include the helper methods and reset `pwned_password_check_enabled` to false before every example.

If using Minitest, you also need to add:
```ruby
  include ::Devise::PwnedPassword::TestHelpers::InstanceMethods
```


## Installation
Add this line to your application's Gemfile:

```ruby
gem 'devise-pwned_password'
```

And then execute:
```bash
$ bundle install
```

Optionally, if you also want to warn existing users when they sign in, override `after_sign_in_path_for`
```ruby
def after_sign_in_path_for(resource)
  set_flash_message! :alert, :warn_pwned if resource.respond_to?(:pwned?) && resource.pwned?
  super
end
```

This should generally be added in ```app/controllers/application_controller.rb``` for a rails app. For an Active Admin application the following monkey patch is needed.

```ruby
# config/initializers/active_admin_devise_sessions_controller.rb
class ActiveAdmin::Devise::SessionsController
  def after_sign_in_path_for(resource)
      set_flash_message! :alert, :warn_pwned if resource.respond_to?(:pwned?) && resource.pwned?
      super
  end
end
```

To prevent the default call to the HaveIBeenPwned API on user sign in, add the following to `config/initializers/devise.rb`:

```ruby
config.pwned_password_check_on_sign_in = false
```

## Considerations

A few things to consider/understand when using this gem:

* User passwords are hashed using SHA-1 and then truncated to 5 characters,
  implementing the k-Anonymity model described in
  https://haveibeenpwned.com/API/v2#SearchingPwnedPasswordsByRange
  Neither the clear-text password nor the full password hash is ever transmitted
  to a third party. More implementation details and important caveats can be
  found in https://blog.cloudflare.com/validating-leaked-passwords-with-k-anonymity/

* This puts an external API in the request path of users signing up to your
  application. This could potentially add some latency to this operation. The
  gem is designed to fail silently if the PwnedPasswords service is unavailable.

## Contributing

To contribute

* Check the [issue tracker](https://github.com/michaelbanfield/devise-pwned_password/issues) and [pull requests](https://github.com/michaelbanfield/devise-pwned_password/pulls) for anything similar
* Fork the repository
* Make your changes
* Run bin/test to make sure the unit tests still run
* Send a pull request

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
