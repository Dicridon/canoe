##
# class Compiler
#   Storing compiler name in String and flags as an array
class Compiler
  attr_reader :name, :flags
  ##
  # @name: String
  # @flgs: Array of String
  def initialize(name, flgs)
    @name = name
    @linking_flags = flgs.filter {|f| f.start_with? "-l"}
    @compiling_flags = flgs - @linking_flags
  end

  def compiling_flags_as_str
    @compiling_flags.join " "
  end

  def linking_flags_as_str
    @linking_flags.join " "
  end


  def append_compiling_flag(flag)
    @compiling_flags << flag
  end

  def append_linking_flag(flag)
    @linking_flags << flag
  end

  def compile(src, out)
    puts "#{name} -o #{out} #{compiling_flags_as_str} -c #{src}"
    system "#{name} -o #{out} #{compiling_flags_as_str} -c #{src}"
  end

  def link_executable(out, objs)
    puts "#{name} -o #{out} #{objs.join(" ")} #{linking_flags_as_str}"
    system "#{name} -o #{out} #{objs.join(" ")} #{linking_flags_as_str}"
  end

  def link_shared(out, objs)
    puts "#{name} -shared -o #{out}.so #{objs.join(" ")} #{linking_flags_as_str}"
    system "#{name} -shared -o #{out}.so #{objs.join(" ")} #{linking_flags_as_str}"
  end
  
  def inspect
    puts "compiler name: #{name.inspect}"
    puts "compiler flags: #{flags.inspect}"
  end
end
