# frozen_string_literal: true

require 'date'

class Util
  # Calculate seconds for a given month
  def self.seconds_of_month(year, month)
    raise ArgumentError if month > 12

    month_start = DateTime.new(year, month, 1, 0) # 24h clock ,  start of month
    month_end = if month == 12
                  DateTime.new(year + 1, 1, 1, 0) # jan 1st of following year
                else
                  DateTime.new(year, month + 1, 1) # start of next month
                end
    days = month_end -  month_start
    # puts "%i-%i has %i days (%s-%s)" % [year, month, days, month_start, month_end ]
    days * 24 * 60 * 60 # convert month in second --- no check for leap seconds
  end

  # Calculate percentage of duration in seconds per month.
  def self.percentage_of_month(duration, year, month)
    (duration / seconds_of_month(year, month)) * 100
  end

  def self.month_fraction
    percentage_of_month(Time.now - Time.local(Time.now.year, Time.now.month), Time.now.year, Time.now.month) / 100
  end
end
