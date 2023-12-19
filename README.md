# CronCalc

CronCalc: A Ruby gem for calculating and analyzing scheduled CRON job occurrences and timings within specified intervals.

## Installation

Install the gem by executing:

    $ gem install cron_calc

## Usage

After installing `cron_calc` you can initialize `CronCalc` with the CRON string.

```ruby
    require 'cron_calc'
    cron_calc = CronCalc.new('5 5 * * *')
```

Now, you can use one of three methods `#in`, `#next`, `#last` to determine cron job occurrencies within specified period.

### Using `#in`

Calculates cron job occurrences within a given time period.
@param period [Range] The time period for which to calculate cron job occurrences.
@return [Array<Time>] An array of Time instances representing each occurrence.

```ruby
    period = Time.new(2024, 1, 1, 0, 0)..Time.new(2024, 1, 4, 0, 0)
    cron_calc.in(period)

    # => [2024-01-01 05:05:00 +0100, 2024-01-02 05:05:00 +0100, 2024-01-03 05:05:00 +0100]
```

### Using `#next`

Calculates the next 'n' occurrences of the cron job from a given start time.
@param count [Integer] The number of occurrences to calculate. Defaults to `1`.
@param period_start [Time] The start time from which to calculate occurrences. Defaults to `Time.now`.
@param max_years [Integer] The maximum number of years to consider for the period. Defaults to `5`.
@return [Array<Time>] An array of the next 'n' occurrences.

```ruby
    cron_calc.next
    # => [2023-12-20 05:05:00 +0100]

    cron_calc.next(3)
    # => [2023-12-20 05:05:00 +0100, 2023-12-21 05:05:00 +0100, 2023-12-22 05:05:00 +0100]

    cron_calc.next(2, Time.new(2024, 1, 1, 0, 0))
    # => [2024-01-01 05:05:00 +0100, 2024-01-02 05:05:00 +0100]
```

### Using `#last`

Calculates the last 'n' occurrences of the cron job until a given end time.
@param count [Integer] The number of past occurrences to calculate.
@param period_end [Time] The end time until which to calculate occurrences.
@param max_years [Integer] The maximum number of years to consider for the period.
@return [Array<Time>] An array of the last 'n' occurrences.

```ruby
    cron_calc.last
    # => [2023-12-19 05:05:00 +0100]

    cron_calc.last(4, Time.new(2024, 1, 1, 0, 0))
    # => [2023-12-31 05:05:00 +0100, 2023-12-30 05:05:00 +0100, 2023-12-29 05:05:00 +0100, 2023-12-28 05:05:00 +0100]
```

## Unsupported features

- DOW (Day of Week) - always require *
- Named DOW and months (SUN-SAT, JAN-DEC)
- Joining characters , - /
- Predefined definitions (@yearly, @monthly, @weekly, @daily, @midnight, @hourly)

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/mizinsky/cron_calc.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
