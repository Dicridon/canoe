class DefaultFiles
    def self.open_file_and_write(filename, content)
        File.open(filename, "w") {|f|
            f.write(content)
        }
    end

    def self.create_config(path)
        open_file_and_write(
            "#{path}/config", 
            <<~CONFIG
                [[compiler]]
                clang++

                [[opt-flags]]
                -O2

                [[debug-flags]]
                -g

                [[std-flags]]
                -std=c++17

            CONFIG
        )
    end

    def self.create_main(path)
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

    def self.create_cpp(filename)
        open_file_and_write(
            "#{filename}.cpp", 
            <<~DOC
                #include "#{filename}.hpp"
            DOC
        )
    end

    def self.create_hpp(workspace, filename)
        open_file_and_write(
            "#{filename}.hpp",
            <<~DOC
                #ifndef __#{workspace.upcase}__#{filename.upcase}__
                #define __#{workspace.upcase}__#{filename.upcase}__

                #endif
            DOC
        )
    end
end