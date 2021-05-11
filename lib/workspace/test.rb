module Canoe
  class WorkSpace
    def test(args)
      if args.empty?
        test_all
        return
      end

      args.each do |arg|
        case arg
        when "all"
          test_all
        else
          test_single arg
        end
      end
    end

    private

    def test_all
      puts "tests all"
    end

    def test_single(name)
      puts "#{@tests}/bin/test_#{name}"
      # system "./#{@tests}/bin/test_#{name}"
    end

    def get_all_test_files
      Dir.glob("#{@tests_short}/*.#{@source_suffix}").filter do |f|
        File.basename(f).start_with? 'test_'
      end
    end

    def test_build_time
      get_all_test_files.map do |f|
        obj = @target_short + '/' + File.basename(f, '.*')
        File.exist?(obj) ? File.mtime(obj) : Time.new(0)
      end.min
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

    # @deps is the dependency hash for tests
    # cyclic dependency is not handled
    def compile_each_test(test_file, deps)
      extract_one_file(test_file, deps).each do |f|
        o = file_to_obj(f)
        next if File.exist?(o) && File.mtime(o) > File.mtime(f)

        compile(obj, f)
      end
      compile(test_file, file_to_obj(test_file))
    end

    def link_all_test(deps)
      get_all_test_files.each do |f|
        target = "#{@target_short}/#{File.basename(f, '.*')}"
        obj = file_to_obj(f)
        @compiler.link_executable target, extract_one_file_obj(f, deps) + [obj]
      end
    end


    # TODO: display should be updated
    def build_test
      puts 'building tests...'
      total_deps = target_deps.merge(tests_deps)
      build_time = test_build_time
      files = DepAnalyzer.compiling_filter(total_deps, build_time, @source_suffix, @header_suffix).select do |f|
        File.basename(f).start_with?('test_')
      end

      files.each do |f|
        compile_each_test(f, total_deps)
      end

      # compilation and link are separated because they may be separated
      # by unexpected interrupt like C-c, C-d, etc.
      # thus unditionally link all tests
      link_all_test(total_deps)
    end
  end
end
