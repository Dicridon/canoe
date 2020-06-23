class Compiler
  attr_reader :name, :flags
  def initialize(name, flgs)
    @name = name
    @flags = flgs
  end

  def flags_as_str
    flags.join " "
  end

  def append_flag(flag)
    @flags << flag
  end

  def compile(src, out)
    puts "#{name} -o #{out} #{flags_as_str} -c #{src}"
    system "#{name} -o #{out} #{flags_as_str} -c #{src}"
  end

  def link(out, objs)
    libs = flags.select {|f| f.start_with?('-l')}
    puts "#{name} -o #{out} #{objs.join(" ")} #{libs.join(" ")}"
    system "#{name} -o #{out} #{objs.join(" ")} #{libs.join(" ")}"
  end

  def inspect
    puts "compiler name: #{name.inspect}"
    puts "compiler flags: #{flags.inspect}"
  end
end
