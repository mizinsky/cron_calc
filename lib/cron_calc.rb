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
      months: 1..12,
      wdays: 0..6
    }.freeze

    WDAYS = {
      'SUN' => '0', 'MON' => '1', 'TUE' => '2', 'WED' => '3',
      'THU' => '4', 'FRI' => '5', 'SAT' => '6'
    }.freeze

    MONTHS = {
      'JAN' => '1', 'FEB' => '2', 'MAR' => '3', 'APR' => '4',
      'MAY' => '5', 'JUN' => '6', 'JUL' => '7', 'AUG' => '8',
      'SEP' => '9', 'OCT' => '10', 'NOV' => '11', 'DEC' => '12'
    }.freeze

    PREDEFINED_DEFINITIONS = {
      '@yearly' => '0 0 1 1 *', '@annually' => '0 0 1 1 *',
      '@monthly' => '0 0 1 * *',
      '@weekly' => '0 0 * * 0',
      '@daily' => '0 0 * * *', '@midnight' => '0 0 * * *',
      '@hourly' => '0 * * * *'
    }.freeze

    def initialize(cron_string)
      @cron_string = cron_string

      raise 'Cron expression is not supported or invalid' unless cron_string_valid?

      @cron_string = normalize_with(cron_string, PREDEFINED_DEFINITIONS) if @cron_string.start_with? '@'
      @cron_parts = split_cron_string
    end

    # Calculates cron job occurrences within a given time period.
    # @param period [Range] The time period for which to calculate cron job occurrences.
    # @return [Array<Time>] An array of Time instances representing each occurrence.
    def in(period)
      occurrences(period)
    end

    # Calculates the next 'n' occurrences of the cron job from a given start time.
    # @param count [Integer] The number of occurrences to calculate.
    # @param after [Time] The start time from which to calculate occurrences.
    # @param max_years [Integer] The maximum number of years to consider for the period.
    # @return [Array<Time>] An array of the next 'n' occurrences.
    def next(count = 1, after: Time.now, max_years: 5)
      occurrences(
        after..(after + (60 * 60 * 24 * 365 * max_years)),
        count
      )
    end

    # Calculates the last 'n' occurrences of the cron job until a given end time.
    # @param count [Integer] The number of past occurrences to calculate.
    # @param before [Time] The end time until which to calculate occurrences.
    # @param max_years [Integer] The maximum number of years to consider for the period.
    # @return [Array<Time>] An array of the last 'n' occurrences.
    def last(count = 1, before: Time.now, max_years: 5)
      occurrences(
        (before - (60 * 60 * 24 * 365 * max_years))..before,
        count,
        reverse: true
      )
    end

    private

    def occurrences(period, count = nil, reverse: false)
      time_combinations = generate_time_combinations(period, reverse).lazy
      wdays = parse_cron_part(:wdays)

      time_combinations.each_with_object([]) do |(year, month, day, hour, minute), occ|
        break occ if count && occ.length == count

        time = Time.new(year, month, day, hour, minute)
        occ << time if Date.valid_date?(year, month, day) && period.include?(time) && wdays.include?(time.wday)
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
        months: normalize_with(splitted[3], MONTHS),
        wdays: normalize_with(splitted[4], WDAYS)
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

    def normalize_with(string, mapping)
      mapping.inject(string) { |str, (k, v)| str.gsub(k, v) }
    end

    def cron_string_valid?
      # rubocop:disable Layout/LineLength
      regex = %r{\A(@yearly|@annually|@monthly|@weekly|@daily|@midnight|@hourly|(\*|([0-5]?\d)(,([0-5]?\d))*|(\*/\d+)|(\d+-\d+)) (\*|([01]?\d|2[0-3])(,([01]?\d|2[0-3]))*|(\*/\d+)|(\d+-\d+)) (\*|([12]?\d|3[01])(,([12]?\d|3[01]))*|(\*/\d+)|(\d+-\d+)) (\*|(JAN|FEB|MAR|APR|MAY|JUN|JUL|AUG|SEP|OCT|NOV|DEC|[1-9]|1[0-2])(,(JAN|FEB|MAR|APR|MAY|JUN|JUL|AUG|SEP|OCT|NOV|DEC|[1-9]|1[0-2])|-(JAN|FEB|MAR|APR|MAY|JUN|JUL|AUG|SEP|OCT|NOV|DEC))*|(\*/\d+)|(\d+-\d+)) (\*|(SUN|MON|TUE|WED|THU|FRI|SAT|[0-6])(,(SUN|MON|TUE|WED|THU|FRI|SAT|[0-6])|-(SUN|MON|TUE|WED|THU|FRI|SAT))*|(\*/[0-6]+)|([0-6]-[0-6])))\z}
      # rubocop:enable Layout/LineLength
      cron_string.match?(regex)
    end
  end
end
