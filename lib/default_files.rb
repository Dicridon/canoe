##
# class DefaultFiles
#   A singleton class to generate header and souce files.
#   TODO: consider using class source_file.rb in Pareater
class DefaultFiles
  class << self
    def open_file_and_write(filename, content)
      File.open(filename, "w") {|f|
        f.write(content)
      }
    end

    def create_config(path, src_sfx='cpp', hdr_sfx='hpp')
      open_file_and_write(
        "#{path}/config.json", 
        <<~CONFIG
          {
              "compiler": "clang++",
              "header-suffix": "#{hdr_sfx}",
              "source-suffix": "#{src_sfx}",
              "flags": {
                  "opt": "-O2",
                  "debug": "-g",
                  "std": "-std=c++17"
              }
          }
        CONFIG
      )
    end

    def create_main(path, suffix='cpp')
      open_file_and_write(
        "#{path}/main.#{suffix}",
        <<~DOC
          #include <iostream>
          int main(int argc, char *argv[]) {
              std::cout << "hello world!" << std::endl;
          }
        DOC
      )
    end

    def create_lib_header(path, lib_name, suffix='hpp')
      open_file_and_write(
        "#{path}/#{lib_name}.#{suffix}",
        <<~DOC
          #ifndef __#{lib_name.upcase}__
          #define __#{lib_name.upcase}__
         
          #endif
        DOC
      )
    end

    def create_emacs_dir_local(path)
      open_file_and_write(
        "#{path}/.dir-locals.el",
        <<~DOC
          ((nil . ((company-clang-arguments . ("-I./src/components/"
                                               "-I./components/"))))
           (nil . ((company-c-headers-path-user . ("./src/components/"
                                   "./components/")))))
        DOC
      )
    end

    def create_cpp(filename, src_sfx='cpp', hdr_sfx='hpp')
      open_file_and_write(
        "#{filename}.#{src_sfx}", 
        <<~DOC
          #include "#{filename}.#{hdr_sfx}"
        DOC
      )
    end

    def create_hpp(workspace, prefix, filename, hdr_sfx='hpp')
      open_file_and_write(
        "#{filename}.#{hdr_sfx}",
        <<~DOC
          #ifndef __#{workspace.upcase}__#{prefix.upcase}__#{filename.upcase}__
          #define __#{workspace.upcase}__#{prefix.upcase}__#{filename.upcase}__
          
          #endif
        DOC
      )
    end
  end
end
