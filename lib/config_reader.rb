require "json"

##
# class ConfigReader
#   Just read a json file
class ConfigReader
  def self.extract_flags(file)
    abort_on_err("config file #{file} does not exsit") unless File.exist? file
    JSON.parse(File.read(file))
  end
end
