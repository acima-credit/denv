# DEnv

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
  
### What if I'm really clever?
  
Yes, you can use the newly found environment variables for the next step. Something like:
 
```ruby
DEnv.from_file('../.env').from_file!('../.local.env')
DEnv.from_consul!(ENV['CONSUL_URL'], ENV['CONSUL_PATH'])
```

You might be pushing it but if that is your thing, go ahead! 

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

