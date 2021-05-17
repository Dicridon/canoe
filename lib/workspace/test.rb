module Canoe
  class WorkSpace
    def test(args)
      if args.empty?
        test_all
        return
      end

      args.each do |arg|
        case arg
        when 'all'
          test_all
        else
          test_single arg
        end
      end
    end
    
    # extract one test file's dependency
    def extract_one_file(file, deps)
      ret = deps[file]

      deps[file].each do |f|
        dep = extract_one_file(f, deps)
        dep.each do |d|
          ret << d unless ret.include?(d)
        end
      end
      ret.map { |f| f.gsub(".#{@header_suffix}", ".#{@source_suffix}") }
    end

    def extract_one_file_obj(file, deps)
      extract_one_file(file, deps).map do |f|
        file_to_obj(f)
      end
    end

    private

    def test_all
      build_test
      fetch_all_test_files.each do |f|
        test_single File.basename(f, '.*')['test_'.length..]
      end
    end

    def test_single(name)
      bin = "#{@target_short}/test_#{name}"
      file = "#{@tests_short}/test_#{name}.#{@source_suffix}"
      abort_on_err "Can not find source file #{file.red} for test #{name.red}" unless File.exist?(file)
      build_compiler_from_config
      build_one_test(file, fetch_all_deps) unless File.exist?(bin)

      issue_command bin
    end

    def fetch_all_test_files
      Dir.glob("#{@tests_short}/*.#{@source_suffix}").filter do |f|
        File.basename(f).start_with? 'test_'
      end
    end

    def fetch_all_deps
      target_deps.merge(tests_deps)
    end

    def test_build_time
      fetch_all_test_files.map do |f|
        obj = "#{@target_short}/#{File.basename(f, '.*')}"
        File.exist?(obj) ? File.mtime(obj) : Time.new(0)
      end.min
    end

    # @deps is the dependency hash for tests
    # cyclic dependency is not handled
    # compiler should first be built
    def compile_one_test(test_file, deps)
      extract_one_file(test_file, deps).each do |f|
        o = file_to_obj(f)
        next if File.exist?(o) && File.mtime(o) > File.mtime(f)

        compile(f, o)
      end
      compile(test_file, file_to_obj(test_file))
    end

    def link_one_test(test_file, deps)
      target = "#{@target_short}/#{File.basename(test_file, '.*')}"
      @compiler.link_executable target, extract_one_file_obj(test_file, deps) + [file_to_obj(test_file)]
    end

    def build_one_test(test_file, deps)
      compile_one_test(test_file, deps)
      link_one_test(test_file, deps)
    end

    def compile_all_tests(deps)
      files = DepAnalyzer.compiling_filter(deps, test_build_time, @source_suffix, @header_suffix).select do |f|
        File.basename(f).start_with?('test_')
      end

      stepper = Stepper.new fetch_all_test_files.size, files.size

      files.each do |f|
        printf "#{stepper.progress_as_str.green} compiling #{f} "
        compile_one_test(f, deps)
        stepper.step
      end
    end

    def link_all_tests(deps)
      all_files = fetch_all_test_files

      stepper = Stepper.new all_files.size, all_files.size
      fetch_all_test_files.each do |f|
        printf "#{stepper.progress_as_str.green} linking #{File.basename(f, '.*').yellow}: "
        link_one_test(f, deps)
        stepper.step
      end
    end

    def build_test
      puts "#{'[COMPILING TESTS]'.magenta}..."
      return unless test_build_time

      puts @compiler.compiling_flags_as_str
      puts @compiler.linking_flags_as_str


      total_deps = fetch_all_deps
      compile_all_tests(total_deps)
      puts "#{'[100%]'.green} compiling done, starts linking..."
      puts "#{'[LINKING TESTS]'.magenta}..."
      # compilation and link are separated because they may be separated
      # by unexpected interrupt like C-c, C-d, etc.
      # thus unditionally link all tests
      link_all_tests(total_deps)
      puts "#{'[100%]'.green} linking done"
    end
  end
end
