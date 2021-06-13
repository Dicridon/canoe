require 'json'
module Canoe
  class WorkSpace
    def src_to_obj(src)
      @obj_prefix + File.basename(src, ".*") + ".o"
    end

    def comp_to_obj(comp)
      @obj_prefix + comp.delete_suffix(File.extname(comp))[@components_prefix.length..].gsub("/", "_") + ".o"
    end

    # the if else order is important because tests are regarded as sources
    def file_to_obj(file)
      if file.start_with?(@components_prefix)
        comp_to_obj file
      else
        src_to_obj file
      end
    end

    def hdr_of_src(file)
      file.gsub(".#{@source_suffix}", ".#{@header_suffix}")
    end

    # args are commandline parameters passed to `canoe build`,
    # could be 'all', 'test', 'target', 'base' or empty
    def build(arg = 'target')
      build_compiler_from_config
      send "build_#{arg}"
    end

    private

    def build_flags(flags, config)
      config.values.each do |v|
        case v
        when String
          flags << v
        when Array
          v.each do |o|
            flags << o
          end
        else
          abort_on_err "unknown options in config.json, #{v}"
        end
      end
    end

    def build_compiler_from_config
      flags = ConfigReader.new('config.json').extract_flags
      compiler_name = flags['compiler'] ? flags['compiler'] : 'clang++'

      abort_on_err "compiler #{compiler_name} not found" unless system "which #{compiler_name} > /dev/null"
      compiler_flags = ['-Isrc/components']
      linker_flags = []

      c_flags, l_flags = flags['flags']['compile'], flags['flags']['link']
      build_flags(compiler_flags, c_flags)
      build_flags(linker_flags, l_flags)

      @compiler = Compiler.new compiler_name, compiler_flags, linker_flags
    end

    def compile(f, o)
      @compiler.compile f, o
    end

    def link_exectutable(odir, objs)
      puts "#{"[100%]".green} linking"
      @compiler.link_executable "#{odir}/#{@name}", objs
    end

    def link_shared(odir, objs)
      puts "#{"[100%]".green} linking"
      @compiler.link_shared "#{odir}/lib#{@name}", objs
    end

    def build_bin(files)
      if build_common(files) &&
         link_exectutable(@target_short, Dir.glob("obj/*.o").reject { |f| f.start_with? 'obj/test_' })
        puts "BUILDING SUCCEEDED".green
        return true
      else
        puts "building target FAILED".red
        return false
      end
    end

    def build_lib(files)
      @compiler.append_compiling_flag "-fPIC"
      if build_common(files) &&
         link_shared(@target_short, Dir.glob("obj/*.o").reject { |f| f.start_with? 'obj/test_'})
        puts "BUILDING SUCCEEDED".green
      else
        puts "building target FAILED".red
      end
    end

    def build_common(files)
      all = SourceFiles.get_all(@src_short) { |f| f.end_with? @source_suffix }
      stepper = Stepper.new all.size, files.size
      flag = true

      files.each do |f|
        progress = stepper.progress_as_str.green
        printf "#{progress.green} compiling #{f.yellow}: "
        o = file_to_obj(f)
        flag = false unless compile f, o
        stepper.step
      end
      flag
    end

    def build_all
      build_target
      build_test
    end

    def get_deps(dep_file, source_dir, include_dirs)
      File.exist?(dep_file) ? DepAnalyzer.read_from(dep_file) :
        DepAnalyzer.new(source_dir, @source_suffix, @header_suffix).build_to_file(include_dirs, dep_file)
    end

    def target_deps
      get_deps @deps, @src_short, [@src_short, @components_short]
    end

    # contain only headers
    # sources in ./src/components are not included
    def tests_deps
      get_deps @test_deps, @tests_short, [@src_short, @components_short]
    end

    def build_target
      puts "#{'[BUILDING TARGET]'.magenta}..."
      target = "#{@target}/#{@name}"
      build_time = File.exist?(target) ? File.mtime(target) : Time.new(0)
      files = DepAnalyzer.compiling_filter target_deps, build_time, @source_suffix, @header_suffix 

      if files.empty? && File.exist?(target)
        puts "nothing to do, all up to date"
        return true
      end

      self.send "build_#{@mode.to_s}", files
    end

    # generate a compile_commands.json file
    def build_base
      deps = target_deps.merge tests_deps
      database = CompilationDatabase.new
      deps.each_key do |k|
        next if k.end_with? @header_suffix
        c = @compiler.name.end_with?('++') ? 'c++' : 'c'

        arg =  [c] + @compiler.compiling_flags_as_str.split + [k] + [file_to_obj(k)] + ['-c', '-o']
        database.add_command_object(@workspace, arg, k)
      end
      File.open('compile_commands.json', 'w') do |f|
        f.puts database.pretty_to_s
      end
    end
  end

  class CompilationDatabase
    attr_reader :database
    def initialize
      @database = []
    end

    def add_command_object(dir, arguments, file)
      temp = {             
        "arguments" => arguments,
        "directory" => dir,
        "file" => file
      }
      @database << temp
    end

    def to_s
      @database.to_s
    end

    def pretty_to_s
      JSON.pretty_generate(@database)
    end

    def to_json
      @database.to_json
    end
  end
end
