# CronCalc

**CronCalc**: A Ruby gem for calculating CRON job occurrences. With this gem, you can easily determine when a cron job will occur by providing a cron expression. Key features include the ability to **calculate occurrences**:
- **Within a specified period**: Find out all the times your cron job will run during a particular timeframe.
- **After a given date**: Determine the next set of occurrences after a specific starting point.
- **Before a given date**: Discover when your cron job ran or would have run before a certain date.

This tool can be used for scheduling, forecasting, and analyzing tasks in systems that use cron for job scheduling. You can also read the [article about CronCalc here](https://medium.com/@mizinsky/calculate-your-cron-occurrences-with-ease-adf4219933fa).

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

Calculates cron job occurrences within a given time period.\
**Parameters:**
- `period` - a Range object defining the start and end times for the calculation.\


```ruby
    period = Time.new(2024, 1, 1, 0, 0)..Time.new(2024, 1, 4, 0, 0)
    cron_calc.in(period)

    # => [2024-01-01 05:05:00 +0100, 2024-01-02 05:05:00 +0100, 2024-01-03 05:05:00 +0100]
```

### Using `#next`

Calculates the next 'n' occurrences of the cron job from a given start time.\
**Parameters:**
- `count` - (optional, Integer) The number of occurrences to calculate. Defaults to 1.
- `after:` - (optional, Time, keyword argument) The start time from which to calculate occurrences. If not provided, defaults to the current time (Time.now).
- `max_years` - (optional, Integer, keyword argument) The maximum number of years to search for future occurrences. Defaults to 5.

```ruby
    cron_calc.next
    # => [2023-12-20 05:05:00 +0100]

    cron_calc.next(3)
    # => [2023-12-20 05:05:00 +0100, 2023-12-21 05:05:00 +0100, 2023-12-22 05:05:00 +0100]

    cron_calc.next(2, after: Time.new(2024, 1, 1, 0, 0))
    # => [2024-01-01 05:05:00 +0100, 2024-01-02 05:05:00 +0100]
```

### Using `#last`

Calculates the last 'n' occurrences of the cron job until a given end time.\
**Parameters:**
- `count` - (optional, Integer) The number of occurrences to calculate. Defaults to 1.
- `before:` - (optional, Time, keyword argument) The end time from which to calculate past occurrences. If not provided, defaults to the current time (Time.now).
- `max_years` - (optional, Integer, keyword argument) The maximum number of years to search backward for past occurrences. Defaults to 5.

```ruby
    cron_calc.last
    # => [2023-12-19 05:05:00 +0100]

    cron_calc.last(4, before: Time.new(2024, 1, 1, 0, 0))
    # => [2023-12-31 05:05:00 +0100, 2023-12-30 05:05:00 +0100, 2023-12-29 05:05:00 +0100, 2023-12-28 05:05:00 +0100]
```

### Other examples

```ruby
    # You can omit the count parameter
    CronCalc.new('5 5 */5 * SUN').last(before: Time.new(2020, 1, 1, 0, 0))
    # => [2019-12-01 05:05:00 +0100]

    # You can combine ',' and '-'
    CronCalc.new('5 5 5-7,10 FEB *').next(5)
    # => [2024-02-05 05:05:00 +0100, 2024-02-06 05:05:00 +0100, 2024-02-07 05:05:00 +0100, 2024-02-10 05:05:00 +0100, 2025-02-05 05:05:00 +0100]

    # You can use predefined definitions like @daily, @monthly, etc.
    CronCalc.new('@monthly').next(3, after: Time.new(2024, 1, 1, 0, 0))
    # => [2024-01-01 00:00:00 +0100, 2024-02-01 00:00:00 +0100, 2024-03-01 00:00:00 +0100]

    # I want to know when the next 10 Friday the 13ths will be!
    CronCalc.new('0 0 13 * FRI').next(10)
    # => 
    # [2024-09-13 00:00:00 +0200,
    #  2024-12-13 00:00:00 +0100,
    #  2025-06-13 00:00:00 +0200,
    #  2026-02-13 00:00:00 +0100,
    #  2026-03-13 00:00:00 +0100,
    #  2026-11-13 00:00:00 +0100,
    #  2027-08-13 00:00:00 +0200,
    #  2028-10-13 00:00:00 +0200]

```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/mizinsky/cron_calc.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
