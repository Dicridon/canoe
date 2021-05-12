# If the project has circular dependency, this command would fail
# TODO: add rules for tests
module Canoe
  class Makefile
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
    end

    def extract_name(name, prefix)
      if name.start_with?(prefix)
        name.delete_suffix(File.extname(name))[prefix.length..].gsub('/', '_')
      else
        File.basename(name.split('/')[-1], '.*')
      end
    end

    def generate_all_names(files)
      files.each do |f|
        name = extract_name(f, @workspace.components_prefix).upcase
        @all_names << name
        @src_variables[name] = f
        @hdr_variables[name] = f.gsub(@workspace.source_suffix, @workspace.header_suffix)
        @obj_variables[name] = @workspace.obj_prefix + extract_name(f, @workspace.components_prefix) + '.o'
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
        makefile.puts("HDR_#{k}=#{v}")
      end
    end

    def define_objs(makefile, files)
      @obj_variables.each do |k, v|
        makefile.puts("OBJ_#{k}=#{v}")
      end
      objs = @obj_variables.keys.map { |k| "$(OBJ_#{k})" }.join " "
      makefile.puts("OBJS=#{objs}")
      makefile.puts ""
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

    def make_rules(makefile, deps)
      make_dependencies(makefile, deps)
      makefile.puts ""
      makefile.puts("all: BIN\n")
      makefile.puts ""
      cmplr = cxx?(get_compiler) ? "CXX" : "CC"
      @all_names.each do |n|
        makefile.puts("$(OBJ_#{n}): $(#{n}_DEP)\n\t$(#{cmplr}) $(#{cmplr}FLAGS) -o $(OBJ_#{n}) -c $(SRC_#{n})")
        makefile.puts ""
      end

      if @workspace.mode == :bin
        makefile.puts("BIN: $(OBJS)\n\t$(#{cmplr}) $(#{cmplr}FLAGS) -o $(TARGET) $(wildcard ./obj/*.o) $(LDFLAGS) $(LDLIBS)")
      else
        makefile.puts("LIB: $(OBJS)\n\t$(#{cmplr}) $(#{cmplr}FLAGS) -shared -o $(TARGET) $(wildcard ./obj/*.o) -fPIC $(LDFLAGS) $(LDLIBS)")
      end
      makefile.puts ""

      clean = <<~DOC
      .PHONY: clean
      clean: 
      \trm $(TARGET)
      \trm ./obj/*.o
    DOC
      makefile.puts(clean)
    end
  end

  class WorkSpace
    def make
      config = ConfigReader.extract_flags "config.json"

      deps = File.exist?(@deps) ?
               DepAnalyzer.read_from(@deps) :
               DepAnalyzer.new("./src").build_to_file(["./src", "./src/components"], @deps)

      makefile = Makefile.new self
      makefile.configure config
      makefile.make! deps
    end
  end
end
