Gem::Specification.new do |s|
  s.name = "canoe"
  s.version = "0.3.3.5"
  s.summary = "a C/C++ project management and building tool"
  s.description = <<~DES
    Canoe offers project management and building facilities to C/C++ projects.

    If you are tired of writing Makefile, CMakeList and even SConstruct, please let Canoe help you wipe them out.

    Similar to Cargo for Rust, Canoe offers commands such as new, build, run, etc. to help you generate a C/C++ project and build it automatically.

    Different from tools like Scons and Blade, Canoe requires users to write NO building scripts, Canoe would analyze dependencies and build like our old friend 'make' if a few conventions over file names are followed.

  DES
  s.authors = ["XIONG Ziwei"]
  s.email = "noahxiong@outlook.com"
  s.homepage = "https://github.com/Dicridon/canoe"
  s.files = Dir.glob("lib/*.rb") + Dir.glob("lib/workspace/*.rb")
  s.executables << "canoe"
  s.license = "MIT"
  s.required_ruby_version = ">= 2.7.1"
end
