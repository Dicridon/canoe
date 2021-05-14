# If the project has circular dependency, this command would fail
module Canoe
  ##
  # CanoeMakefile is used to offer makefile generation utilities
  class CanoeMakefile
    include WorkSpaceUtil
    def initialize(workspace)
      @workspace = workspace
      @all_names = []
      @common_variables = {}
      @src_variables = {}
      @hdr_variables = {}
      @obj_variables = {}
      @config = {}
    end

    def configure(config)
      @config = config
    end

    def make!(deps)
      File.open('Makefile', 'w') do |f|
        if cxx?(get_compiler)
          make_cxx(f, deps)
        else
          make_c(f, deps)
        end
      end
    end

    private

    def get_compiler
      @config['compiler']
    end

    def get_header_suffix
      @workspace.header_suffix
    end

    def get_source_suffix
      @workspace.source_suffix
    end

    def get_compiling_flags
      flags = @config['flags']['compile'].values.join ' '
      flags + ' -I./src/components'
    end

    def get_ldflags
      @config['flags']['link'].values.select { |v| v.start_with?('-L') }.join ' '
    end

    def get_ldlibs
      (@config['flags']['link'].values - (get_ldflags.split)).join ' '
    end

    def cxx?(name)
      return get_compiler.end_with? '++'
    end

    def make_cxx(makefile, deps)
      make_common(makefile, 'CXX', deps)
    end

    def make_c(makefile, deps)
      make_common(makefile, 'CC', deps)
    end

    def make_common(makefile, compiler_prefix, deps)
      make_compiling_info(makefile, compiler_prefix)
      define_variables(makefile, deps)
      make_rules(makefile, deps)
    end

    def make_compiling_info(makefile, compiler_prefix)
      makefile.puts("#{compiler_prefix}=#{get_compiler}")
      makefile.puts("#{compiler_prefix}FLAGS=#{get_compiling_flags}")
      makefile.puts("LDFLAGS=#{get_ldflags}")
      makefile.puts("LDLIBS=#{get_ldlibs}")
      makefile.puts ''
    end

    def define_variables(makefile, deps)
      define_dirs(makefile)
      src_files = deps.keys.select { |f| f.end_with? get_source_suffix }
      
      generate_all_names(src_files)
      define_srcs(makefile, src_files)
      makefile.puts ''
      define_hdrs(makefile, src_files)
      makefile.puts ''
      define_objs(makefile, src_files)
      makefile.puts ''
      define_tests(makefile, src_files)
      makefile.puts ''
    end

    def extract_name(name, _)
      File.basename(file_to_obj(name), '.*')
    end

    def generate_all_names(files)
      files.each do |f|
        name = extract_name(f, @workspace.components_prefix).upcase
        @all_names << name
        @src_variables[name] = f
        @hdr_variables[name] = f.gsub @workspace.source_suffix, @workspace.header_suffix
        @obj_variables[name] = file_to_obj(f)
      end
    end

    def define_dirs(makefile)
      makefile.puts("TARGET_DIR=./target")
      if @workspace.mode == :bin
        makefile.puts("TARGET=$(TARGET_DIR)/#{@workspace.name}")
      else
        makefile.puts("TARGET=$(TARGET_DIR)/lib#{@workspace.name.downcase}.so")
      end
      # note the ending slash
      makefile.puts("OBJ_DIR=#{@workspace.obj_prefix[..-2]}")
      makefile.puts("SRC_DIR=#{@workspace.src_prefix[..-2]}")
      makefile.puts("COMPONENTS_DIR=#{@workspace.components_prefix[..-2]}")
      makefile.puts ""
    end

    def define_srcs(makefile, files)
      @src_variables.each do |k, v|
        makefile.puts("SRC_#{k}=#{v}")
      end
    end

    def define_hdrs(makefile, files)
      @hdr_variables.each do |k, v|
        next if k == "MAIN"
        makefile.puts("HDR_#{k}=#{v}") if File.exist? v
      end
    end

    def define_objs(makefile, files)
      @obj_variables.each do |k, v|
        makefile.puts("OBJ_#{k}=#{v}")
      end
      objs = @obj_variables.keys.map { |k| "$(OBJ_#{k})" }
      bin_objs = objs.reject { |o| o.start_with? '$(OBJ_TEST'}
      test_objs = objs - bin_objs
      makefile.puts ''
      makefile.puts("OUT_OBJS=#{bin_objs.join ' '}")
      makefile.puts("TEST_OBJS=#{test_objs.join ' '}")
    end

    def define_tests(makefile, files)
      test_files = files.select { |f| File.basename(f, '.*').start_with? 'test_'}
      test_files.each do |f|
        basename = File.basename(f, '.*')
        test = "#{@workspace.target_short}/#{basename}"
        makefile.puts("#{basename.upcase}=#{test}")
      end
      tests = test_files.map do |f|
        "$(#{File.basename(f, '.*').upcase})"
      end
      makefile.puts("TESTS=#{tests.join ' '}")
    end

    def get_all_dep_name(file_name, deps)
      dep = deps[file_name]
      if dep.empty?
        []
      else
        tmp = dep.map { |n| extract_name(n, @workspace.components_prefix).upcase }
        dep.each do |d|
          tmp += get_all_dep_name(d, deps)
        end
        tmp
      end
    end

    def emit_dependencies(makefile, name, deps)
      as_str = deps.map do |n|
        if n == name
          ["$(SRC_#{n})"] + ["$(HDR_#{n})"] * (name == "MAIN" ? 0 : 1)
        else
          "$(#{n}_DEP)"
        end
      end.flatten.join " "
      makefile.puts("#{name}_DEP=#{as_str}")
    end

    def make_dependencies(makefile, deps)
      dep_variables = Hash[@all_names.map { |n| [n, []] }]
      reference = Hash[@all_names.map { |n| [n, []] }]
      @all_names.each do |n|
        dep_variables[n] = ([n] + get_all_dep_name(@src_variables[n], deps)).uniq
        reference[n] = ([n] + get_all_dep_name(@src_variables[n], deps)).uniq
      end

      # deduplication
      dep_variables.each do |k, v|
        v.each do |n|
          next if n == k
          v = v - reference[n] + [n] if v.include? n
        end
        dep_variables[k] = v
      end

      dep_variables.each do |k, v|
        emit_dependencies(makefile, k, v)
      end
    end

    def make_obj_rules(makefile, deps)
      cmplr = cxx?(get_compiler) ? 'CXX' : 'CC'

      @all_names.each do |n|
        makefile.puts("$(OBJ_#{n}): $(#{n}_DEP)\n\t$(#{cmplr}) $(#{cmplr}FLAGS) -o $@ -c $(SRC_#{n})\n\n")
      end
    end

    def make_out_rules(makefile, deps)
      cmplr = cxx?(get_compiler) ? 'CXX' : 'CC'
      if @workspace.mode == :bin
        makefile.puts("out: $(OUT_OBJS)\n\t$(#{cmplr}) $(#{cmplr}FLAGS) -o $(TARGET) $(OUT_OBJS) $(LDFLAGS) $(LDLIBS)")
      else
        makefile.puts("out: $(OUT_OBJS)\n\t$(#{cmplr}) $(#{cmplr}FLAGS) -shared -o $(TARGET) $(OUT_OBJS) -fPIC $(LDFLAGS) $(LDLIBS)")
      end
      makefile.puts ''
      makefile.puts("test: $(TESTS)")
      makefile.puts ''
      makefile.puts("all: out test")
    end

    def make_tests_rules(makefile, deps)
      cmplr = cxx?(get_compiler) ? 'CXX' : 'CC'
      @all_names.each do |n|
        next unless n.start_with? 'TEST_'
        filename = "#{@workspace.tests_short}/#{n.downcase}.#{@workspace.source_suffix}"
        objs = ["$(OBJ_#{n})"] + extract_one_file_obj(filename, deps).map do |o|
          "$(OBJ_#{File.basename(o, '.*').upcase})"
        end

        makefile.puts("$(#{n}): #{objs.join ' '}\n\t$(#{cmplr}) $(#{cmplr}FLAGS) -o $@ $^ $(LDFLAGS) $(LDLIBS)")
        makefile.puts ''
      end
    end

    def make_clean(makefile)
      clean = <<~DOC
            .PHONY: clean
            clean: 
            \trm ./target/*
            \trm ./obj/*.o
            DOC
      makefile.puts(clean)
    end

    def make_rules(makefile, deps)
      make_dependencies makefile, deps
      makefile.puts ''
      make_out_rules makefile, deps
      makefile.puts ''
      make_obj_rules makefile, deps
      make_tests_rules makefile, deps
      makefile.puts ''
      make_clean makefile
    end
  end

  class WorkSpace
    def make
      config = ConfigReader.extract_flags "config.json"

      deps = target_deps.merge tests_deps

      makefile = CanoeMakefile.new self
      makefile.configure config
      makefile.make! deps
    end
  end
end
