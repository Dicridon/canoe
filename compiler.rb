class Compiler
    attr_reader :name, :flags
    def initialize(name, flags)
        @name = name
        @flags = flags
    end

    def flags_as_str
        flags.join " "
    end

    def append_flag(flag)
        @flags << flag
    end

    def compile(src, out)
        puts "#{name} -o #{out} #{flags} -c #{src}"
        system "#{name} -o #{out} #{flags} -c #{src}"
    end

    def link(out, objs)
        puts "#{name} -o #{out} #{objs.join(" ")}"
        system "#{name} -o #{out} #{objs.join(" ")}"
    end

    def inspect
        puts "compiler name: #{name}"
        puts "compiler flags: #{flags}"
    end
end