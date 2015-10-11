# Yamen (衙门)

Yamen is a simple rule-based decision engine that aims to:

- Easy to create a rule.
- Easy to define a rule decision.
- Error messages when user define a rule decision.
- Error messages for each evaluated rule that failed.

## Usage

Define a rule:

``` ruby
module SimpleRule
  class Number < Yamen::Rule
    parameter :operation, Yamen::StringType, enum:
      %w(larger_than larger_than_or_equal_to smaller_than smaller_than_or_equal_to)
    parameter :value, Yamen::FloatType

    def decision(fact)
      return [false, %("#{fact}" is not a numeric)] unless fact.is_a?(Numeric)

      result = case operation
               when 'larger_than'
                 fact > value
               when 'larger_than_or_equal_to'
                 fact >= value
               when 'smaller_than'
                 fact < value
               when 'smaller_than_or_equal_to'
                 fact <= value
               end

      result ? [true, nil] : [false, %(#{fact} is not #{operation} #{value})]
    end
  end
end
```

Initialize and use a Yamen engine:

``` ruby
governor = Yamen::BooleanGovernor.new(SimpleRule)
governor.read <<-RULE
  {
    "rule": "Number",
    "params": {
      "operation": "larger_than_or_equal_to",
      "value": "99.99"
    }
  }
RULE

decision = governor.decision(100)
decision[0] # => true

decision = governor.decision(99)
decision[0] # => false
decision[1] # => 99 is not larger_than_or_equal_to 99.99
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'yamen'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install yamen

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/zhuochun/yamen. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

