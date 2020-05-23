require 'fileutils'
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


    def initialize(name, mode)
        @name = name
        @compiler = Compiler.new 'clang++', '-Isrc/components'
        @cwd = Dir.new(Dir.pwd)
        @workspace = "#{Dir.pwd}/#{@name}"
        @src = "#{@workspace}/src"
        @components = "#{@src}/components"
        @third = "#{@workspace}/third-party"
        @target = "#{@workspace}/target"
        @mode = mode
        @deps = '.canoe.deps'
    end

    def new
        Dir.mkdir(@name)
        Dir.mkdir(@src)
        Dir.mkdir(@components)
        Dir.mkdir("#{@workspace}/obj")
        DefaultFiles.create_main @src if @mode == :bin
        File.new("#{@workspace}/.canoe", "w")
        DefaultFiles.create_config @workspace
        DefaultFiles.create_emacs_dir_local @workspace

        Dir.mkdir(@third)
        Dir.mkdir(@target)
        puts "workspace #{@workspace} is created"
    end

    def build(args)
        deps = File.exist?('.canoe.deps') ? 
                           DepAnalyzer.read_from(@deps) :
                           DepAnalyzer.new('./src').build_to_file(['./src', './src/components'], @deps)
        target = "./target/#{@name}"
        build_time = File.exist?(target) ? File.mtime(target) : Time.new(0)
        files = DepAnalyzer.compiling_filter(deps, build_time)
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
        system "./target/#{@name} #{args}"
    end

    def add(args)
        args.each do |i|
            dir = @components
            filenames = i.split("/")
            filenames.each do |filename|
                dir = dir + "/#{filename}"
                unless Dir.exist? dir
                    FileUtils.mkdir dir 
                    Dir.chdir(dir) do
                        puts "created " + Dir.pwd
                        create_working_files filename
                    end
                end
            end
        end
    end

private
    def create_working_files(filename)
        DefaultFiles.create_cpp filename
        DefaultFiles.create_hpp @name, filename
    end

    def build_compiler_from_config(args)
        Dir.chdir(@workspace) do
            flags = ConfigReader.extract_flags "config"
            compiler_name = ""
            compiler_flags = ["-Isrc/components"] + args
            flags.each do |pair|
                case pair[0]
                when "compiler"
                    compiler_name = pair[1]
                    abort_on_err "compiler #{compiler_name} not found in /usr/bin" unless File.exist? "/usr/bin/#{compiler_name}"
                when /.+-flags/
                    compiler_flags << pair[1..]
                else
                    puts "unknown options #{pair[0]}"
                end
            end
            @compiler = Compiler.new compiler_name, compiler_flags.join(" ")
        end
    end

    def compile(f, o)
        @compiler.compile f, o
    end

    def link(odir, objs)
        system "#{@compiler} -o #{odir}/#{@name} #{objs.join(" ")}"
        @compiler.link "#{odir}/#{@name}", objs
    end

    def build_bin(files, args)
        build_compiler_from_config args
        files.each do |f|
            o = "./obj/" + f.split("/")[-1][0...-3] + "o"
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
