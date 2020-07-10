require 'fileutils'
require 'open3'
require_relative 'source_files'
require_relative 'compiler'
require_relative 'config_reader'
require_relative 'default_files'
require_relative 'err'
require_relative 'dependence'

class WorkSpace
  include Err
  attr_reader :name, :cwd
  def self.help
    info = <<~INFO
            canoe is a C/C++ project manager, inspired by Rust cargo.
            usage:
                canoe new tada: create a project named 'tada' in current directory
                
                canoe build: compile current project (execute this command in project directory)

                canoe generate: generate dependency relationships and store it in '.canoe.deps' file. Alias: update

                canoe update: udpate dependency relationships and store it in '.canoe.deps' file. 
                
                canoe run: compile and execute current project (execute this command in project directory)
                
                canoe clean: remove all generated object files and binary files
                
                canoe help: show this help message

                canoe add tada: add a folder named tada under workspace/components,
                
                canoe dep: show current dependency relationships of current project
                
                canoe verion: version information

            new project_name [mode] [suffixes]:
                create a new project with project_name.
                In this project, four directories obj, src, target and third-party will be generated in project directory.
                in src, directory 'components' will be generated if [mode] is '--lib', an extra main.cpp will be generated if [mode] is '--bin'

                [mode]: --lib for a library and --bin for executable binaries
                [suffixes]: should be in 'source_suffix:header_suffix" format, notice the ':' between two suffixes
            add component_name:
                add a folder named tada under workspace/components.
                two files tada.hpp and tada.cpp would be craeted and intialized. File suffix may differ according users' specifications.
                if component_name is a path separated by '/', then canoe would create folders and corresponding files recursively.

            generate: 
                generate dependence relationship for each file, this may accelarate
                `canoe buid` command. It's recommanded to execute this command everytime
                headers are added or removed from any file.
            
            update:
                this command is needed because '.canoe.deps' is actually a cache of dependency relationships so that
                canoe doesn't have to analyze all the files when building a project.
                So when a file includes new headers or some headers are removed, users have to use 'canoe udpate'
                to update dependency relationships.

            build [options]:
                build current project, arguments in [options] will be passed to C++ compiler
            
            run [options]:
                build current project with no specific compilation flags, and run this project, passing [options] as command line arguments to the binary

            clean:
                remove all generated object files and binary files

            help:
                show this help message

            verion: 
                display version information

            dep:
                display file dependencies in a better readable way

            @author: written by XIONG Ziwei, ICT, CAS
            @contact: noahxiong@outlook.com
        INFO
    puts info
  end


  def initialize(name, mode, src_suffix='cpp', hdr_suffix='hpp')
    @name = name
    @compiler = Compiler.new 'clang++', ['-Isrc/components']
    @cwd = Dir.new(Dir.pwd)
    @workspace = "#{Dir.pwd}/#{@name}"
    @src = "#{@workspace}/src"
    @components = "#{@src}/components"
    @obj = "#{@workspace}/obj"
    @third = "#{@workspace}/third-party"
    @target = "#{@workspace}/target"
    @tests = "#{@workspace}/tests"
    @mode = mode
    @deps = '.canoe.deps'

    @src_prefix = './src/'
    @components_prefix = './src/components/'
    @obj_prefix = './obj/'

    @source_suffix = src_suffix
    @header_suffix = hdr_suffix
  end

  def new
    Dir.mkdir(@name)
    Dir.mkdir(@src)
    Dir.mkdir(@components)
    Dir.mkdir("#{@workspace}/obj")
    if @mode == :bin
      DefaultFiles.create_main(@src, @source_suffix) 
    else
      DefaultFiles.create_lib_header(@src, @name, @header_suffix)
    end
    File.new("#{@workspace}/.canoe", "w")
    DefaultFiles.create_config @workspace, @source_suffix, @header_suffix
    # DefaultFiles.create_emacs_dir_local @workspace

    Dir.mkdir(@third)
    Dir.mkdir(@target)
    Dir.chdir(@workspace) do
      system "git init"
    end
    puts "workspace #{@workspace} is created"
  end

  # args are commandline parameters passed to `canoe build`    
  def build(args)
    deps = File.exist?(@deps) ? 
             DepAnalyzer.read_from(@deps) :
             DepAnalyzer.new('./src').build_to_file(['./src', './src/components'], @deps)
    target = "./target/#{@name}"
    build_time = File.exist?(target) ? File.mtime(target) : Time.new(0)
    files = DepAnalyzer.compiling_filter(deps, build_time, @source_suffix, @header_suffix)

    if files.empty?
      puts "nothing to do, all up to date"
      return
    end
    
    self.send "build_#{@mode.to_s}", files, args 
  end

  def generate
    DepAnalyzer.new('./src', @source_suffix, @header_suffix)
               .build_to_file ['./src', './src/components'], @deps
  end

  def update
    generate
  end

  def clean
    self.send "clean_#{@mode.to_s}"
  end

  def run(args)
    return if @mode == :lib
    build []
    args = args.join " "
    puts "./target/#{@name} #{args}"
    exec "./target/#{@name} #{args}"
  end

  def add(args)
    args.each do |i|
      dir = @components
      filenames = i.split("/")
      prefix = []
      filenames.each do |filename|
        dir += "/#{filename}"
        prefix << filename
        unless Dir.exist? dir
          FileUtils.mkdir dir 
          Dir.chdir(dir) do
            puts "created " + Dir.pwd
            create_working_files prefix.join('__'), filename
          end
        end
      end
    end
  end

  def dep
    deps = DepAnalyzer.read_from(@deps) if File.exist?(@deps)
    deps.each do |k, v|
      unless v.empty?
        puts "#{k} depends on: "
        v.each {|f| puts "    #{f}"}
        puts ""
      end
    end
  end

  def test(args)
    args.each do |arg|
      case arg
      when "all"
        test_all
      else
        test_single arg        
      end
    end
  end
  
  private
  def create_working_files(prefix, filename)
    DefaultFiles.create_cpp filename, @source_suffix, @header_suffix
    DefaultFiles.create_hpp @name, prefix, filename, @header_suffix
  end

  def build_compiler_from_config(args)
    Dir.chdir(@workspace) do
      flags = ConfigReader.extract_flags "config.json"
      compiler_name = flags['compiler'] ? flags['compiler'] : "clang++"
      abort_on_err "compiler #{compiler_name} not found" unless File.exists?("/usr/bin/#{compiler_name}")
      compiler_flags = ['-Isrc/components'] + args
      
      if opts = flags['flags'] 
        opts.each do |k, v|
          case v
          when String
            compiler_flags << v
          when Array
            v.each do |o|
              compiler_flags << o
            end
          else
            abort_on_err "unknown options in config.json, #{v}"
          end
        end
      end

      @compiler = Compiler.new compiler_name, compiler_flags
    end
  end

  def compile(f, o)
    @compiler.compile f, o
  end

  def link_exectutable(odir, objs)
    puts "[100%] linking"
    @compiler.link_executable "#{odir}/#{@name}", objs
  end

  def link_shared(odir, objs)
    puts "[100%] linking"
    @compiler.link_shared "#{odir}/lib#{@name}", objs
  end

  def build_bin(files, args)
    return if files.empty?
    build_compiler_from_config args
    if build_common(files, args)
      link_exectutable('./target', Dir.glob("obj/*.o"))
      puts "canoe: building succeeded"
    else 
      puts "canoe: building failed"
    end
  end

  def build_lib(files, args)
    return if files.empty?
    build_compiler_from_config args
    @compiler.append_compiling_flag '-fPIC'
    if (build_common files, args)
      link_shared('./target', Dir.glob("obj/*.o"))
      puts "canoe: building succeeded"
    else 
      puts "canoe: building failed"
    end
  end

  def build_common(files, args)
    compiled, total = 0.0, files.size + 1
    comps = files.select {|f| f.start_with? @components_prefix}
    srcs = files - comps
    flag = true;
    srcs.each do |f|
      progress = (compiled / total).round(2) * 100
      printf "[#{progress.to_i}%%] compiling #{f}: "
      fname = f.split("/")[-1]
      o = @obj_prefix + fname.delete_suffix(File.extname(fname)) + '.o'
      flag = false unless compile f, o 
      compiled += 1
    end
    
    comps.each do |f|
      progress = (compiled / total).round(2) * 100
      printf "[#{progress.to_i}%%] compiling #{f}: "
      o = @obj_prefix + f.delete_suffix(File.extname(f))[@components_prefix.length..]
                         .gsub('/', '_') + '.o'
      flag = false unless compile f, o
      compiled += 1
    end
    flag
  end

  def clean_obj
    puts "rm -f ./obj/*.o"
    system "rm -f ./obj/*.o"
  end

  def clean_target
    puts "rm -f ./target/*"
    system "rm -f ./target/*"
  end

  def clean_bin
    clean_obj
    clean_target
  end

  def clean_lib
    clean_obj
    clean_target
  end

  public
  def inspect 
    puts "name is #{@name}"
    puts "name is #{@workspace}"
  end
end
