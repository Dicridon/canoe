module Canoe
  class WorkSpace
    def self.help
      info = <<~INFO
      canoe is a C/C++ project manager, inspired by Rust cargo.
      usage:
          canoe new tada: create a project named 'tada' in current directory
            
          canoe build: compile current project (execute this command in project directory)

          canoe test: build and run tests
      
          canoe generate: generate dependency relationships and store it in '.canoe.deps' file. Alias: update

          canoe update: udpate dependency relationships and store it in '.canoe.deps' file. 
              
          canoe run: compile and execute current project (execute this command in project directory)
            
          canoe clean: remove all generated object files and binary files
            
          canoe help: show this help message
      
          canoe add tada: add a folder named tada under workspace/components,
            
          canoe dep: show current dependency relationships of current project
            
          canoe verion: version information

          canoe make: generate a makefile for this project
      
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
          this command is needed because '.canoe.deps' is actually a cache of dependency relationships so that canoe doesn't have to analyze all the files when building a project.
          So when a file includes new headers or some headers are removed, users have to use 'canoe udpate'
          to update dependency relationships.
      
      build [all|test]:
          build current project, 'all' builds both target and tests, 'test' builds tests only

      test [tests]:
          build and run tests
          [tests]: 'all' for all tests, or a name of a test for a single test
        
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

      make: 
          generate a Makefile for this project
      
      @author: written by XIONG Ziwei, ICT, CAS
      @contact: noahxiong@outlook.com
    INFO
      puts info
    end
  end
end
