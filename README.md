# Devise::PwnedPassword
Devise extension that checks user passwords against the PwnedPasswords dataset https://haveibeenpwned.com/Passwords

Based on

https://github.com/HCLarsen/devise-uncommon_password


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

By default responses from the PwnedPasswords API are timed out after 5 seconds
to reduce potential latency problems.
Optionally, you can add the following snippet to `config/initializers/devise.rb`
to control the timeout settings:

```ruby
config.pwned_password_open_timeout = 1
config.pwned_password_read_timeout = 2
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
