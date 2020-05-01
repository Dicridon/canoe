require_relative 'source_files'

class DepAnalyzer
    def self.read_from(filename)
        File.open(filename, "r") do |f|
            ret = Hash.new []
            f.each_line do |line|
                entry = line.split(': ')
                ret[entry[0]] = entry[1].split
            end            
            ret
        end
    end

    # if header files included are not modified
    # but corresponding cpp files are, this
    # file needs no recompiling

    def self.compiling_filter(deps, time)
        files = [] 
        deps.each do |k, v|
            next if k.end_with? '.hpp'
            if file_modified_after(k, time)
                files << k
                next
            end
            v.each do |f|
                if mark(f, time, deps) || mark(f.sub('.hpp', '.cpp'), time, deps)
                    files << k
                    break
                end
            end
        end
        files
    end

private
    def self.mark(file, time, deps)
        return false unless File.exists? file
        if file_modified_after(file, time)
            return true
        else
            deps[file].each do |f|
                return true if mark(f, time, deps)
            end
        end
        false
    end

    def self.file_modified_after(file, time) 
        File.mtime(file) > time
    end

public
    def initialize(dir)
        @dir = dir
        @deps = Hash.new []
    end

    def build_dependence(include_path)
        files = SourceFiles.get_all(@dir) do |f|
            f.end_with? "pp"
        end

        @deps = Hash.new []
        files.each do |fname|
            @deps[fname] = get_all_headers include_path, fname
        end

        @deps
    end

    def build_to_file(include_path, filename)
        build_dependence include_path
        File.open(filename, "w") do |f|
            @deps.each do |k, v|
                f.write "#{k}: #{v.join(" ")}\n"
            end
        end
        @deps
    end


private
    def get_all_headers(include_path, file)
        File.open(file, "r") do |f|
            ret = []
            if file.end_with?('.cpp')
                header = file.sub('.cpp', '.hpp')
                ret += [header] if File.exists?(header)
            end
            f.each_line do |line|
                if mat = line.match(/include "(.+\.hpp)"/)
                    include_path.each do |path|
                        dep = "#{path}/#{mat[1]}"
                        ret += [dep] if File.exists? dep
                    end
                end
            end
            ret.uniq
        end
    end
end