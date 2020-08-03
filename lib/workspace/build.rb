class WorkSpace
  # args are commandline parameters passed to `canoe build`, 
  # could be 'all', 'test', 'target' or empty
  def build(args)
    case args[0]
    when "all"
      build_all
    when "test"
      build_test
    else
      build_target
    end
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
    Dir.chdir(@workspace) do
      flags = ConfigReader.extract_flags "config.json"
      compiler_name = flags['compiler'] ? flags['compiler'] : "clang++"
      abort_on_err "compiler #{compiler_name} not found" unless File.exists?("/usr/bin/#{compiler_name}")
      compiler_flags = ['-Isrc/components']
      linker_flags = []

      c_flags, l_flags = flags['flags']['compile'], flags['flags']['link']
      build_flags(compiler_flags, c_flags)
      build_flags(linker_flags, l_flags)

      @compiler = Compiler.new compiler_name, compiler_flags, linker_flags
    end
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
    # return if files.empty?
    build_compiler_from_config
    if build_common(files) && link_exectutable('./target', Dir.glob("obj/*.o"))
        puts "BUILDING SUCCEEDED".green
    else 
      puts "building FAILED".red
    end
  end

  def build_lib(files)
    # return if files.empty?
    build_compiler_from_config
    @compiler.append_compiling_flag '-fPIC'
    if build_common(files) && link_shared('./target', Dir.glob("obj/*.o"))
      puts "BUILDING SUCCEEDED".green
    else 
      puts "building FAILED".red
    end
  end

  def build_common(files)
    all = SourceFiles.get_all('./src') {|f| f.end_with? @source_suffix}
    total = all.size.to_f
    compiled = total - files.size
    comps = files.select {|f| f.start_with? @components_prefix}
    srcs = files - comps
    flag = true;
    
    srcs.each do |f|
      progress = (compiled / total).round(2) * 100
      printf "[#{progress.to_i}%%]".green + " compiling #{f}: "
      fname = f.split("/")[-1]
      o = @obj_prefix + File.basename(fname, ".*") + '.o'
      flag = false unless compile f, o 
      compiled += 1
    end

    comps.each do |f|
      progress = (compiled / total).round(2) * 100
      printf "[#{progress.to_i}%%]".green + " compiling #{f}: "
      o = @obj_prefix + f.delete_suffix(File.extname(f))[@components_prefix.length..]
                         .gsub('/', '_') + '.o'
      flag = false unless compile f, o
      compiled += 1
    end
    flag
  end

  def build_all
    build_target
    build_test
  end

  def build_target
    deps = File.exist?(@deps) ? 
           DepAnalyzer.read_from(@deps) :
           DepAnalyzer.new('./src').build_to_file(['./src', './src/components'], @deps)
    target = "./target/#{@name}"
    build_time = File.exist?(target) ? File.mtime(target) : Time.new(0)
    files = DepAnalyzer.compiling_filter(deps, build_time, @source_suffix, @header_suffix)

    if files.empty? && File.exist?(target)
      puts "nothing to do, all up to date"
      return
    end

    self.send "build_#{@mode.to_s}", files
  end
end