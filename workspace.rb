require 'fileutils'
require_relative 'source_files'

class WorkSpace
    attr_reader :name, :cwd
    def self.help
        info = <<~INFO
            canoe is a C/C++ project manager, inspired by Rust cargo.
            usage:
                canoe new tada: create a project named tada in current directory
                
                canoe build: compile current project (execute this command in project directory)
                
                canoe run: compile and execute current project (execute this command in project directory)
                
                canoe clean: remove all generated object files and binary files
                
                canoe help: show this help message

                canoe add tada: add a folder named tada under workspace/components,
                                two files tada.hpp and tada.cpp would be craeted and intialized

            new project_name [mode]:
                create a new project with project_name.
                In this project, three directories src, target and third-party will be generated in project directory.
                in src, include and impl will be generated if [mode] is a lib, an extra main.cpp will be generated if [mode] is a bin

            build [options]:
                build current project, arguments in [options] will be passed to C++ compiler
            
            run [options]:
                build current project with no specific compilation flags, and run this project, passing [options] as command line arguments to the binary

            clean:
                remove all generated object files and binary files

            help:
                show this help message
            @author: XIONG Dicridon
        INFO
        puts info
    end


    def initialize(name, mode)
        @name = name
        @compiler = "clang++"
        @cwd = Dir.new(Dir.pwd)
        @workspace = "#{Dir.pwd}/#{@name}"
        @src = "#{@workspace}/src"
        @components = "#{@src}/components"
        @third = "#{@workspace}/third-party"
        @target = "#{@workspace}/target"
        @mode = mode
    end

    def new
        Dir.mkdir(@name)
        Dir.mkdir(@src)
        Dir.mkdir(@components)
        # Dir.mkdir("#{@workspace}/obj")
        create_main @src if @mode == :bin
        File.new("#{@workspace}/.canoe", "w")
        create_config @workspace

        Dir.mkdir(@third)
        Dir.mkdir(@target)
        puts "workspace #{@workspace} is created"
    end

    def build
        if @mode == :bin
            build_bin
        else
            build_lib
        end
    end

    def clean
        if @mode == :bin
            clean_bin
        else
            clean_lib
        end
    end

    def run(args)
        args = args.join " "
        puts "./target/#{name} #{args}"
        system "./target/#{name} #{args}"
    end

    def add(args)
        args.each{|i|
            dir = @components
            filenames = i.split("/")
            filenames.each {|filename|
                dir = dir + "/#{filename}"
                unless Dir.exist? dir
                    FileUtils.mkdir dir 
                    Dir.chdir(dir) {
                        puts "created " + Dir.pwd
                        create_working_files filename
                    }
                end
            }
       }
    end

private
    def open_file_and_write(filename, content)
        File.open(filename, "w") {|f|
            f.write(content)
        }
    end

    def create_config(path)
        open_file_and_write(
            "#{path}/config", 
            <<~CONFIG
                [[compiler]]
                clang++

                [[flags]]
                -O0

            CONFIG
        )
    end

    def create_main(path)
        open_file_and_write(
            "#{path}/main.cpp",
            <<~DOC
                #include <iostream>
                int main(int argc, char *argv[]) {
                    std::cout << "hello world!" << std::endl;
                }
            DOC
        )
    end

    def create_cpp(filename)
        open_file_and_write(
            "#{filename}.cpp", 
            <<~DOC
                #include "#{filename}.hpp"
            DOC
        )
    end

    def create_hpp(filename)
        open_file_and_write(
            "#{filename}.hpp",
            <<~DOC
                #ifndef __#{@name.upcase}__#{filename.upcase}__
                #define __#{@name.upcase}__#{filename.upcase}__

                #endif
            DOC
        )
    end

    def create_working_files(filename)
        create_cpp filename
        create_hpp filename
    end

    def compile(f)
        o = f[0...-3] + "o"
        puts "#{@compiler} -Icomponents -o #{o} -c #{f}"
        system "#{@compiler} -Icomponents -o #{o} -c #{f}"
    end

    def link(odir, objs)
        puts "#{@compiler} -o #{odir}/#{@name} #{objs.join(" ")}"
        system "#{@compiler} -o #{odir}/#{@name} #{objs.join(" ")}"
    end

    def build_bin
        Dir.chdir(@src) do
            mains = SourceFiles.get_in(".") do |f|
                f.end_with? ".cpp"
            end
            puts "mains are " + mains.to_s

            files = SourceFiles.get_all("./components") do |f|
                f.end_with? ".cpp"
            end
            puts "following files would be compiled"
            puts files + mains
            puts "compiling....."
            all = files + mains
            all.each do |f|
                compile f
            end

            objs = all.map {|f| f[0...-3] + "o"}
            link('../target', objs)
        end
    end

    def build_lib
        puts "build a lib"
    end

    def clean_bin
        Dir.chdir(@src) do
            mains = SourceFiles.get_in(".") do |f|
                f.end_with? ".o"
            end

            files = SourceFiles.get_all('./components') do |f|
                f.end_with? ".o"
            end
            all = mains + files
            puts "following files would be removed"
            puts files + mains
            all.each do |f|
                puts "rm -f #{f}"
                system "rm -f #{f}"
            end
        end

        puts "rm -f ./target/#{@name}"
        system "rm -f ./target/#{@name}"

    end

    def clean_lib
        puts "clean a lib"
    end

public
    def inspect 
        puts "name is #{@name}"
        puts "name is #{@workspace}"
    end
end