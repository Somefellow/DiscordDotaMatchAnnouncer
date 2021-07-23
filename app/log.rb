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
    open(File.join(@log_dir, "#{date_string}.log"), "a") do |f|
      f.puts("#{datetime_string} - #{message}")
    end
  end
end
