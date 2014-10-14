# Cucumber::Eclipse::Steps

    This is a Cucumber formatter gem that outputs the step definitions and steps
    such that the cucumber.eclipse.steps.json Eclipse plugin can know where
    the steps are defined.

## Installation

Add this line to your application's Gemfile:

    gem 'cucumber-eclipse-steps'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cucumber-eclipse-steps

## Usage

    The 'cucumber' command can load a formatter if the -f option uses its
    class name.  Therefore to use this formatter, the command would be thus:

      cucumber -f Cucumber::Eclipse::Steps::Json <other-args>

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
