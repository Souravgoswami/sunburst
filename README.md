# Sunburst
Sunburst lets you run a command for a given time.
When the time expires, the program will be SIGKILLed.
Sunburst will then report the total CPU time and last known memory usage
of the program.

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'sunburst'
```

And then execute:

```
$ bundle install
```

Or install it yourself as:
```
$ gem install sunburst
```

## Usage
Run sunbust -h for instruction.

```
Arguments:
    --time=N          Run the program for N seconds
    -h | --help       Show this help section
    --humanize        Human readable memory units

Example:
    sunburst echo hello world --time=0.05 --humanize
    sunburst "echo hello world" --time=0.05 --humanize
    sunburst "ruby -e 'while true do end'" --time=3 --humanize
    sunburst "ruby -e 'p :Hello'" --time=3 --humanize
```

If no time is specified, it will run until the command exits.

## Contributing
Bug reports and pull requests are welcome on GitHub at https://github.com/Souravgoswami/sunburst.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
