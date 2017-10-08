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


Users will receive the following error message if they use a password from the PwnedPasswords dataset

```
This password has previously appeared in a data breach and should never be used. Please choose something harder to guess.
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


## Considerations

A few things to consider/understand when using this gem

* User passwords are sent as a SHA1 hash to the API described here https://haveibeenpwned.com/API/v2#PwnedPasswords , this does mean that the owner of that API could be recording these hash's, and potentially cracking them. For most applications this is pretty low risk as there is no link to the user's account. If this is an unacceptable risk for your application you will be better off downloading the raw dataset and hosting it yourself.
* This puts an external API in the request path of users signing up to your application. This could potentially add some latency to this operation, especially as the haveibeenpwned API throttles fairly aggressively. If your application does get throttled this plugin will retry for a maximum of 30 seconds and then fail silently, so at worst users wait a bit longer when signing up.

## Contributing

To contribute

* Check the [issue tracker](https://github.com/michaelbanfield/devise-pwned_password/issues) and [pull requests](https://github.com/michaelbanfield/devise-pwned_password/pulls) for anything similar
* Fork the repository
* Make your changes
* Run bin/test to make sure the unit tests still run
* Send a pull requests

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
