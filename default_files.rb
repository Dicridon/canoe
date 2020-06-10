class DefaultFiles
    def self.open_file_and_write(filename, content)
        File.open(filename, "w") {|f|
            f.write(content)
        }
    end

    def self.create_config(path)
        open_file_and_write(
            "#{path}/config.json", 
            <<~CONFIG
                {
                    "compiler": "clang++",
                    "header-suffix": "hpp",
                    "source-suffix": "cpp",
                    "flags": {
                        "opt": "-O2",
                        "debug": "-g",
                        "std": "-std=c++17"
                    }
                }
            CONFIG
        )
    end

    def self.create_main(path, suffix='cpp')
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

    def self.create_emacs_dir_local(path)
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

    def self.create_cpp(filename, src_sfx='cpp', hdr_sfx='hpp')
        open_file_and_write(
            "#{filename}.#{src_sfx}", 
            <<~DOC
                #include "#{filename}.#{hdr_sfx}"
            DOC
        )
    end

    def self.create_hpp(workspace, prefix, filename, hdr_sfx='hpp')
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
