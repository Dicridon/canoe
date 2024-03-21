##
# class DefaultFiles
#   A singleton class to generate header and souce files.
#   TODO: consider using class source_file.rb in Pareater
class DefaultFiles
  class << self
    def open_file_and_write(filename, content)
      File.open(filename, 'w') do |f|
        f.write(content)
      end
    end

    def create_clang_format(path)
      open_file_and_write(
        "#{path}/.clang-format",
        <<~CLANG
          BasedOnStyle: LLVM
          IndentWidth: 4
          ColumnLimit: 86
          NamespaceIndentation: All
        CLANG
      )
    end

    def create_config(path, compiler = 'clang++', src_sfx = 'cpp', hdr_sfx = 'hpp')
      open_file_and_write(
        "#{path}/config.json",
        <<~CONFIG
          {
              "compiler": "#{compiler}",
              "header-suffix": "#{hdr_sfx}",
              "source-suffix": "#{src_sfx}",
              "flags": {
                  "compile": {
                      "opt": "-O2",
                      "debug": "-g"
                  },
                  "link": {

                  }
              }
          }
        CONFIG
      )
    end

    def create_main(path, suffix = 'cpp')
      header = suffix == 'c' ? 'stdio.h' : 'iostream'
      open_file_and_write(
        "#{path}/main.#{suffix}",
        <<~DOC
          #include <#{header}>
          int main(int argc, char *argv[]) {

          }
        DOC
      )
    end

    def create_lib_header(path, lib_name, suffix = 'hpp')
      open_file_and_write(
        "#{path}/#{lib_name}.#{suffix}",
        <<~DOC
          #ifndef __#{lib_name.upcase}__
          #define __#{lib_name.upcase}__

          #endif
        DOC
      )
    end

    def create_cpp(filename, src_sfx = 'cpp', hdr_sfx = 'hpp')
      open_file_and_write(
        "#{filename}.#{src_sfx}",
        <<~DOC
          #include "#{filename}.#{hdr_sfx}"
        DOC
      )
    end

    def create_hpp(workspace, prefix, filename, hdr_sfx = 'hpp')
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
