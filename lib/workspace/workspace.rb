require "fileutils"
require_relative "../source_files"
require_relative "../compiler"
require_relative "../config_reader"
require_relative "../default_files"
require_relative "../err"
require_relative "../dependence"
require_relative "../coloring"

class WorkSpace
  include Err
  attr_reader :name, :cwd, :src_prefix, :components_prefix, :obj_prefix, :source_suffix, :header_suffix, :mode

  def initialize(name, mode, src_suffix = "cpp", hdr_suffix = "hpp")
    @name = name
    @compiler = Compiler.new "clang++", ["-Isrc/components"], []
    @cwd = Dir.new(Dir.pwd)
    @workspace = "#{Dir.pwd}/#{@name}"
    @src = "#{@workspace}/src"
    @components = "#{@src}/components"
    @obj = "#{@workspace}/obj"
    @third = "#{@workspace}/third-party"
    @target = "#{@workspace}/target"
    @tests = "#{@workspace}/tests"
    @mode = mode
    @deps = ".canoe.deps"

    @src_prefix = "./src/"
    @components_prefix = "./src/components/"
    @obj_prefix = "./obj/"

    @source_suffix = src_suffix
    @header_suffix = hdr_suffix
  end

  def inspect
    puts "name is #{@name}"
    puts "name is #{@workspace}"
  end
end

require_relative "help"
require_relative "version"
require_relative "new"
require_relative "add"
require_relative "build"
require_relative "generate"
require_relative "run"
require_relative "dep"
require_relative "clean"
require_relative "update"
require_relative "test"
require_relative "make"
