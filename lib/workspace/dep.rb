module Canoe
  class WorkSpace
    def dep
      deps = DepAnalyzer.read_from(@deps) if File.exist?(@deps)
      deps.each do |k, v|
        next if v.empty?

        puts "#{k.blue} depends on: "
        v.each { |f| puts "    #{f.blue}" }
        puts ''
      end
    end
  end
end
