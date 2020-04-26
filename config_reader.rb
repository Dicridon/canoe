class ConfigReader
    def self.extract_flags(file)
        File.open(file, "r") do |f|
            content = f.read.split
            names = []
            s = [] 
            content.each_with_index do |c, i|
                if c.start_with? "[["
                    names << c
                    s << i
                end
            end
            e = s + [content.size]
            flags = []
            s.each_with_index do |c, i|
                res = [names[i].match(/\[\[(.+)\]\]/)[1],
                       content[(c+1)...e[i+1]]].flatten
                flags << res
            end
            flags
        end
    end
end