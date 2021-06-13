require 'json'
require_relative 'util'

##
# class ConfigReader
#   Just read a json file
class ConfigReader
  include Canoe::Err
  def initialize(file)
    @config_file = file
  end

  def extract_flags
    abort_on_err("config file #{@config_file} does not exsit") unless File.exist? @config_file
    JSON.parse(File.read(@config_file))
  end
end
