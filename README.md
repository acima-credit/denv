# DEnv [![Build Status](https://travis-ci.org/acima-credit/denv.svg?branch=master)](https://travis-ci.org/acima-credit/denv)

Loads environment variables from `.env` files and network services into `ENV`.

DEnv is heavily inspired by [dotenv](https://github.com/bkeepers/dotenv)
and tries to follow its lead when dealing with `.env` files.
Where it departs is that it connects to network services like [Consul](https://www.consul.io/)
to obtain environment variables.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'denv'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install denv

## Usage

Whenever you are ready to load your environment variables (e.g. `config/application.rb` in Rails):

```ruby
DEnv.from_file! '../.env'
```

This will look for a `.env` file in the parent directory and update the `ENV` with the variables defined in that file.

### What if you want to check the changes first?

```ruby
DEnv.from_file('../.env').changes
# => {'A' => '1', 'B' => 2 }
DEnv.env!
# Now your environment has those two variables
```

### What if I have multiple files?

You can list all the files you need to use and `DEnv` will load them in the same order.
This allows for one file to override the values in the other.

```ruby
DEnv.from_file('../.env').changes
# => {'A' => '1', 'B' => 2 }
DEnv.from_file('../.local.env').changes
# => {'A' => '1', 'B' => 3, 'C' => 4 }
DEnv.env!
# Now your environment has those three variables
```

### What if I like one-liners?

You can do that too:

```ruby
DEnv.from_file('../.env').from_file('../.local.env').env!
# Or alternatively
DEnv.from_file('../.env').from_file!('../.local.env')
```

### Can I make it reload?

Yes, you can! This will reload from known sources and update ENV:

 ```ruby
DEnv.reload.env!
# or alternatively
DEnv.reload!
```

### Can I call the same source multiple times?

Yes, you can! It will only make sense if you do something with the new envs in the mean time but it is very doable.

 ```ruby
DEnv.from_file('../.env').from_file!('../.local.env')
# do something with that custom env set
SomethingVeryClever.run!
# and then bring back the original env set
DEnv.from_file!('../.env')
SomethingUtterlyClever.run!
```

### What if I'm really clever?

Yes, you can use the newly found environment variables for the next step. Something like:

```ruby
DEnv.from_file('../.env').from_file!('../.local.env')
DEnv.from_consul!(ENV['CONSUL_URL'], ENV['CONSUL_PATH'])
```

You might be pushing it but if that is your thing, go ahead!

### Can I make it reload periodically!

Sure you can! You will need something like [concurrent-ruby](https://github.com/ruby-concurrency/concurrent-ruby)
and do something like this:

```ruby
require 'concurrent'
Concurrent::TimerTask.new(execution_interval: 5, timeout_interval: 5) do
  DEnv.reload!
end
```

Or you can use our little ext (not loaded by default):

```ruby
# reload ENV every 30 seconds
require 'denv/periodical'
DEnv.reload_periodically! 30
```

### What about consul?

You can connect to [Consul](https://www.consul.io/) and grab all the key/value pairs in one folder like so:

```ruby
url  = 'https://consul.some-domain.com/'
path = 'service/some_app/vars/'
DEnv.from_consul!(url, path)
# Or if you need authentication:
options = { user: 'some_user', password: 'some_password' }
DEnv.from_consul!(url, path, options)
```
Please note the pattern that the `url` has an ending `/` and  that the `path` does not start with a `/`
or has the `v1/kv/` prefix.

### What about using Rails credentials?

You can use `#from_credentials` like so:
```ruby
# from your Rails app
credentials = Rails.application.credentials[:your_source_here] # => { :ONE => '1', :TWO => '2' }
DEnv.from_credentials(credentials)
DEnv.env!
# or
DEnv.from_credentials!(credentials)
```

### What about loading secrets from a directory?

You can use `#from_secrets_dir` like so:
```ruby
# from your Rails app
DEnv.from_secrets_dir(pathname)
DEnv.env!
# or
DEnv.from_secrets_dir!(pathname)
```

and it will construct a key/value store where the names of the files in the specified directory will correspond to the
keys, and the values will be the contents of the files.  The format of the call is the same as loading a file, except
it will use the directory contents as the items in a key/value hash.

#### Reloading is supported with Rails credentials

```ruby
# from your Rails app
credentials_location = :development
credentials = Rails.application.credentials[credentials_location] # => { :ONE => '1', :TWO => '2' }
DEnv.from_credentials!(credentials, credentials_location: credentials_location)

# after you have edited your credentials.yml.enc

DEnv.reload.env!
# or
DEnv.reload!
```
Please note:
  - By not setting the credentials_location you will not be able to reload
  - `#reload` after using `#from_credentials` outside of a Rails app will raise
      a Runtime error

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests.
You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.
To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`,
which will create a git tag for the version, push git commits and tags, and push the `.gem` file
to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/acima-credit/denv.
This project is intended to be a safe, welcoming space for collaboration, and contributors are expected
to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

