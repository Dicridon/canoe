require 'json'

class ConfigReader
  def self.extract_flags(file)
    abort_on_err("config file #{file} does not exsit") unless File.exists? file
    JSON.parse(File.read(file))
  end
end
