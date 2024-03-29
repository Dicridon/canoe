module Canoe
  class WorkSpace
    def test(args)
      if args.empty?
        test_all
        return
      end
      # we don't handle spaces
      test_single(args[0], args[1..].join(" "))
    end

    # extract all files the file depends on, including headers
    def extract_one_file(file, deps)
      ret = []
      holder = deps[file] + deps[file].map { |f| f.gsub(".#{@header_suffix}", ".#{@source_suffix}") }
      extract_one_file_helper(file, deps, holder, ret)

      ret = ret + ret.map{ |f| f.gsub(".#{@header_suffix}", ".#{@source_suffix}") }
      ret.uniq
    end

    def extract_one_file_obj(file, deps)
      ret = extract_one_file(file, deps).map do |f|
        file_to_obj(f)
      end
      ret.uniq
    end

    def extract_one_file_header(file, deps)
      ret = extract_one_file(file, deps).map do |f|
        f.gsub(".#{@source_suffix}", ".#{@header_suffix}")
      end
      ret.uniq
    end

    def extract_one_file_source(file, deps)
      ret = extract_one_file(file, deps).map do |f|
        f.gsub(".#{@header_suffix}", ".#{@source_suffix}")
      end
      ret.uniq
    end

    private

    # extract one test file's dependency
    def extract_one_file_helper(file, deps, ref, ret)
      begin
        ref.each do |f|
          ret << f unless ret.include?(f)
          dep = extract_one_file_helper(f, deps, deps[f], ret)
          dep.each do |d|
            ret << d unless ret.include?(d)
          end
        end
      rescue SystemStackError
        puts "#{"Fatal: ".red}file #{file} is circularly included"
        exit false
      end
    end

    def test_all
      build_test
      fetch_all_test_files.each do |f|
        test_single File.basename(f, '.*')['test_'.length..]
      end
    end

    def test_single(name, args = "")
      puts "[COMPILING TEST #{name}]".magenta
      rebuild = false
      bin = "#{@target_short}/test_#{name}"

      rebuild ||= !File.exist?(bin)

      file = "#{@tests_short}/test_#{name}.#{@source_suffix}"
      abort_on_err "No test file exists for #{name}" unless File.exist?(file)
      rebuild ||= File.mtime(bin) < File.mtime(file)

      deps = fetch_all_deps

      extract_one_file(file, deps).each do |f|
        rebuild ||= File.mtime(bin) < File.mtime(f) || File.mtime(bin) < File.mtime(hdr_of_src(f))
      end

      cmd = "#{bin} #{args}"
      build_compiler_from_config
      if rebuild
        run_command cmd if build_one_test(file, deps)
      else
        puts "nothing to compile, all up to date"
        puts "[RELINKING...]".magenta
        run_command cmd if link_one_test(file, deps)
      end
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

    def link_one_test(test_file, deps)
      target = "#{@target_short}/#{File.basename(test_file, '.*')}"
      @compiler.link_executable target, [file_to_obj(test_file)] + extract_one_file_obj(test_file, deps)
    end

    def build_one_test(test_file, deps, indent = "")
      files = DepAnalyzer.compiling_filter(target_deps, Time.new(0), @source_suffix, @header_suffix)
                .intersection(extract_one_file_source(test_file, deps)) << test_file
      flag = true

      stepper = Stepper.new(files.size, files.size)

      files.each do |f|
        o = file_to_obj(f)
        printf "#{indent}#{stepper.progress_as_str.green} compiling #{f.yellow}: "
        flag &= compile f, o
        stepper.step
      end
      abort_on_err("Compiling errors encountered") unless flag;

      printf "#{indent}#{stepper.progress_as_str.green} compiling finished\n"
      puts "#{indent}[100%]".green + " linking"
      link_one_test(test_file, deps)
    end

    def compile_all_tests(deps)
      files = DepAnalyzer.compiling_filter(deps, test_build_time, @source_suffix, @header_suffix).select do |f|
        File.basename(f).start_with?('test_')
      end

      stepper = Stepper.new fetch_all_test_files.size, files.size

      files.each do |f|
        printf "#{stepper.progress_as_str.green} building #{File.basename(f, "." + @source_suffix).yellow}:\n"
        build_one_test(f, deps, "    ")
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
      build_compiler_from_config
      puts "#{'[COMPILING TESTS]'.magenta}..."
      return unless test_build_time

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
