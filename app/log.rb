# frozen_string_literal: true

require "fileutils"

class Log
  def initialize(log_dir)
    @log_dir = log_dir
    FileUtils.mkdir_p(@log_dir)
  end

  def log(message)
    now = DateTime.now
    date_string = now.strftime("%Y_%m_%d")
    datetime_string = now.strftime("%d/%m/%Y %H:%M:%S")
    File.write(File.join(@log_dir, "#{date_string}.log"), "#{datetime_string} - #{message}\n", mode: "a")
  end
end
