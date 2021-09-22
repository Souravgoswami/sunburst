# Sunburst
Sunburst lets you run a command for a given time.
When the time expires, the program will be SIGKILLed.
Sunburst will then report the total CPU time and last known memory usage
of the program.

For example:

```
$ sunburst "while : ; do echo hi ; sleep 1 ; done" --time=3
:: Running "while : ; do echo hi ; sleep 1 ; done" for 3.0 seconds
                      Logging Standard Output and Error
hi
hi
hi

    ------------------------------------------------------------------------
:: Total Execution Time: 3.00195 seconds
:: Total CPU Time: 0.0 seconds (00.00% exec time)
:: Memory Usage During Exit: 577536 bytes (0.007% system mem)
:: Avg. Memory Usage: 476655 (0.007% system mem)
:: Max Memory Usage: 577536 bytes (0.007% system mem)
:: Avg. CPU Usage: 00.00%
:: The Max CPU Usage Can't be Logged
:: Max Threads: 1
```

Or

```
$ sunburst "while : ; do : ; done" --time=3
:: Running "while : ; do : ; done" for 3.0 seconds
                      Logging Standard Output and Error

    ------------------------------------------------------------------------
:: Total Execution Time: 3.00195 seconds
:: Total CPU Time: 2.99 seconds (99.60% exec time)
:: Memory Usage During Exit: 356352 bytes (0.004% system mem)
:: Avg. Memory Usage: 356267 (0.004% system mem)
:: Max Memory Usage: 356352 bytes (0.004% system mem)
:: Avg. CPU Usage: 24.91%
:: Max CPU Usage: 25.00%
:: Max Threads: 1
```

Or Even

```
$ sunburst "while : ; do : ; done" --time=3 --progress --humanize
:: Running "while : ; do : ; done" for 3.0 seconds
                                                                       Logging Stats, Ignoring Standard Output and Error
:: Exec T: 03.00s | CPU T: 02.82s | Mem: 364.544 KB | Threads: 1 | State: R | CPU U: 25.00%
    ---------------------------------------------------------------------------------------------------------------------
:: Total Execution Time: 3.00195 seconds
:: Total CPU Time: 2.82 seconds (93.94% exec time)
:: Memory Usage During Exit: 364.544 KB (0.004% system mem)
:: Avg. Memory Usage: 364.304 KB (0.004% system mem)
:: Max Memory Usage: 364.544 KB (0.004% system mem)
:: Avg. CPU Usage: 23.55%
:: Max CPU Usage: 25.00%
:: Max Threads: 1
```

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
    -p | --progress   Show realtime stats of the process
    --humanize        Human readable memory units

Example:
    sunburst echo hello world --time=0.05 --humanize
    sunburst "echo hello world" --time=0.05 --humanize
    sunburst "ruby -e 'while true do end'" --time=3 --humanize
    sunburst "ruby -e 'p :Hello'" --time=3
    sunburst "while : ; do : ; done" --time=3 --humanize --progress
```

If no time is specified, it will run until the command exits.

## Contributing
Bug reports and pull requests are welcome on GitHub at https://github.com/Souravgoswami/sunburst.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
