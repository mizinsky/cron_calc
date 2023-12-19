# frozen_string_literal: true

require_relative 'cron_calc/version'
require 'time'

# The CronCalc is gem-wrapper module for the Parser class
module CronCalc
  class Error < StandardError; end

  def self.new(cron_string)
    Parser.new(cron_string)
  end

  # The Parser class provides functionality to parse and calculate occurrences
  # of cron jobs within a given time period. It interprets cron strings and
  # calculates when cron jobs will occur
  class Parser
    attr_reader :cron_string, :cron_parts

    RANGE = {
      minutes: 0..59,
      hours: 0..23,
      days: 1..31,
      months: 1..12
    }.freeze

    def initialize(cron_string)
      @cron_string = cron_string

      raise 'Cron expression is not supported or invalid' unless cron_string_valid?

      @cron_parts = split_cron_string
    end

    def in(period)
      occurrences(period)
    end

    def next(count = 1, period_start = Time.now, max_years = 5)
      period_end = period_start + (60 * 60 * 24 * 365 * max_years)
      period = period_start..period_end
      occurrences(period, count)
    end

    def last(count = 1, period_end = Time.now, max_years = 5)
      period_start = period_end - (60 * 60 * 24 * 365 * max_years)
      period = period_start..period_end
      occurrences(period, count, reverse: true)
    end

    private

    def occurrences(period, count = nil, reverse: false)
      time_combinations = generate_time_combinations(period, reverse).lazy

      time_combinations.each_with_object([]) do |(year, month, day, hour, minute), occ|
        break occ if count && occ.length == count

        time = Time.new(year, month, day, hour, minute)
        occ << time if Date.valid_date?(year, month, day) && period.include?(time)
      end
    end

    def generate_time_combinations(period, reverse)
      minutes, hours, days, months = parse_cron_expression
      years = (period.min.year..period.max.year).to_a

      combinations = years.product(months, days, hours, minutes)
      reverse ? combinations.reverse : combinations
    end

    def split_cron_string
      splitted = cron_string.split

      {
        minutes: splitted[0],
        hours: splitted[1],
        days: splitted[2],
        months: splitted[3]
      }
    end

    def parse_cron_expression
      %i[minutes hours days months].map { |unit| parse_cron_part(unit) }
    end

    # rubocop:disable Metrics
    def parse_cron_part(time_unit)
      range = RANGE[time_unit]
      part = cron_parts[time_unit]

      case part
      when '*'
        range.to_a
      when /,/
        part.split(',').map(&:to_i)
      when /-/
        (part.split('-').first.to_i..part.split('-').last.to_i).to_a
      when %r{/}
        range.step(part.split('/').last.to_i).to_a
      else
        [part.to_i]
      end
    end
    # rubocop:enable Metrics

    def cron_string_valid?
      # rubocop:disable Layout/LineLength
      regex = %r{\A(\*|([0-5]?\d)(,([0-5]?\d))*|(\*/\d+)|(\d+-\d+)) (\*|([01]?\d|2[0-3])(,([01]?\d|2[0-3]))*|(\*/\d+)|(\d+-\d+)) (\*|([12]?\d|3[01])(,([12]?\d|3[01]))*|(\*/\d+)|(\d+-\d+)) (\*|([1-9]|1[0-2])(,([1-9]|1[0-2]))*|(\*/\d+)|(\d+-\d+)) \*\z}
      # rubocop:enable Layout/LineLength
      cron_string.match?(regex)
    end
  end
end
