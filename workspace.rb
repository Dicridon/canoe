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

                canoe generate: generate dependency relationship and store it in '.canoe.deps'
                
                canoe run: compile and execute current project (execute this command in project directory)
                
                canoe clean: remove all generated object files and binary files
                
                canoe help: show this help message

                canoe add tada: add a folder named tada under workspace/components,
                                two files tada.hpp and tada.cpp would be craeted and intialized
                
                canoe verion: version information

            new project_name [mode]:
                create a new project with project_name.
                In this project, four directories obj, src, target and third-party will be generated in project directory.
                in src, directory 'components' will be generated if [mode] is '--lib', an extra main.cpp will be generated if [mode] is '--bin'

            generate: 
                generate dependence relationship for each file, this may accelarate
                `canoe buid` command. It's recommanded to execute this command everytime
                headers are added or removed from any file.

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

            @author: written by XIONG Ziwei, ICT, CAS
            @contact: noahxiong@outlook.com
        INFO
        puts info
    end


    def initialize(name, mode, src_suffix='cpp', hdr_suffix='hpp')
        @name = name
        @compiler = Compiler.new 'clang++', '-Isrc/components'
        @cwd = Dir.new(Dir.pwd)
        @workspace = "#{Dir.pwd}/#{@name}"
        @src = "#{@workspace}/src"
        @components = "#{@src}/components"
        @obj = "#{@workspace}/obj"
        @third = "#{@workspace}/third-party"
        @target = "#{@workspace}/target"
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
        DefaultFiles.create_main(@src, @source_suffix) if @mode == :bin
        File.new("#{@workspace}/.canoe", "w")
        DefaultFiles.create_config @workspace
        DefaultFiles.create_emacs_dir_local @workspace

        Dir.mkdir(@third)
        Dir.mkdir(@target)
        puts "workspace #{@workspace} is created"
    end

    # args are commandline parameters passed to `canoe build`    
    def build(args)
        deps = File.exist?('.canoe.deps') ? 
                           DepAnalyzer.read_from(@deps) :
                           DepAnalyzer.new('./src').build_to_file(['./src', './src/components'], @deps)
        target = "./target/#{@name}"
        build_time = File.exist?(target) ? File.mtime(target) : Time.new(0)
        files = DepAnalyzer.compiling_filter(deps, build_time, @source_suffix, @header_suffix)
        puts "build got files: #{files}"
        if files.empty?
            puts "nothing to do, all up to date"
            return
        end
        self.send "build_#{@mode.to_s}", files, args 
    end

    def generate
        DepAnalyzer.new('./src').build_to_file ['./src', './src/components'], @deps
    end

    def clean
        self.send "clean_#{@mode.to_s}"
    end

    def run(args)
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

private
    def create_working_files(prefix, filename)
        DefaultFiles.create_cpp filename
        DefaultFiles.create_hpp @name, prefix, filename
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
            puts "flags to compiler #{compiler_flags}"
            @compiler = Compiler.new compiler_name, compiler_flags.join(" ")
        end
    end

    def compile(f, o)
        @compiler.compile f, o
    end

    def link(odir, objs)
        status = system "#{@compiler} -o #{odir}/#{@name} #{objs.join(" ")}"
        unless status
            puts "compilation failed"
            return
        end
        @compiler.link "#{odir}/#{@name}", objs
    end

    def build_bin(files, args)
        build_compiler_from_config args
        comps = files.select {|f| f.start_with? @components_prefix}
        srcs = files - comps
        srcs.each do |f|
            puts "compiling #{f}"
            fname = f.split("/")[1]
            o = @obj_prefix + fname.delete_suffix(File.extname(fname)) + '.o'
            compile f, o
        end
        comps.each do |f|
            puts "compiling #{f}"
            o = @obj_prefix + f.delete_suffix(File.extname(f))[@components_prefix.length..].gsub('/', '_') + '.o'
            compile f, o
        end
        link('./target', Dir.glob("obj/*.o")) unless files.empty?
    end

    def build_lib
        puts "build a lib"
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
