Gem::Specification.new do |s|
  s.name = 'canoe'
  s.version = '0.2.1'
  # s.date = '2020-6-23'
  s.summary = 'a C/C++ project management and build tool'
  s.description = <<~DES
        Tired of writing Makefile, CMakeList and even SConstruct? Let Canoe help you wipe them out.
        Similar to Cargo for Rust, Canoe offers commands such as new, build, run, etc. to help you generate a C/C++ project and build it automatically.
        No more Makefiles, Canoe would analyze dependencies and build like our old friend make if you follow a few conventions over file names
      DES
  s.authors = ["XIONG Ziwei"]
  s.email = 'noahxiong@outlook.com'
  s.homepage = 'https://github.com/Dicridon/canoe'
  s.files = Dir.glob 'lib/*.rb'
  s.executables << 'canoe'
  s.license = 'MIT'
end
