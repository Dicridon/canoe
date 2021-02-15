require_relative "source_files"
require_relative "err"

##
# class DepAnalyzer
#   This class is the key component of canoe, which offers file dependency analysis functionality.
#     A DepAnalyzer takes a directory as input, sources files and corresponding header files in this
#     directory should have same name, e.g. test.cpp and test.hpp.
#     DepAnalyzer would read every source file and recursively process user header files included in this source file to
#     find out all user header files this source file depends on.
#     Based on dependencies built in previous stage, DepAnalyzer determines which files should be recompiled and return
#     these files to caller.
#
#     Dependencies could be written to a file to avoid wasting time parsing all files, Depanalyzer would read from
#     this file to construct dependencies. But if sources files included new headers or included headers are revmoed,
#     Depanalyzer should rebuild the whole dependencies.
class DepAnalyzer
  include Err
  def self.read_from(filename)
    File.open(filename, "r") do |f|
      ret = Hash.new []
      f.each_with_index do |line, i|
        entry = line.split(": ")
        Err.abort_on_err("Bad .canoe.deps format, line #{i + 1}") unless entry.length == 2
        ret[entry[0]] = entry[1].split
      end
      ret
    end
  end

  def self.compiling_filter(deps, build_time, src_sfx = "cpp", hdr_sfx = "hpp")
    files = []
    @processed = {}
    @recompiles = {}
    deps.keys.each do |k|
      @processed[k] = false
      @recompiles[k] = false
    end
    deps.each do |k, v|
      next if k.end_with? ".#{hdr_sfx}"
      if should_recompile?(k, build_time)
        files << k
        @processed[k] = true
        @recompiles[k] = true
        next
      end
      v.each do |f|
        if mark(f, build_time, deps) || mark(f.sub(".#{hdr_sfx}", ".#{src_sfx}"), build_time, deps)
          files << k
          @processed[k] = true
          @recompiles[k] = true
          break
        end
      end
    end
    files
  end

  private

  def self.mark(file, build_time, deps)
    ret = false
    return false unless File.exists? file
    if should_recompile?(file, build_time)
      return true
    else
      deps[file].each do |f|
        if @processed[f]
          ret |= @recompiles[f]
          next
        end
        @processed[f] = true
        if mark(f, build_time, deps)
          @recompiles[f] = true
          return true
        end
      end
    end
    ret
  end

  def self.should_recompile?(file, build_time)
    judge = build_time
    if build_time == Time.new(0)
      objfile = if file.start_with?("./src/components")
          "./obj/" + file.delete_suffix(File.extname(file))["./src/components/".length..].gsub("/", "_") + ".o"
        else
          "./obj/#{File.basename(file, ".*")}.o"
        end
      return true unless File.exists? objfile
      judge = File.mtime(objfile)
    end
    File.mtime(file) > judge
  end

  public

  def initialize(dir, src_sfx = "cpp", hdr_sfx = "hpp")
    @dir = dir
    @deps = Hash.new []
    @source_suffix = src_sfx
    @header_suffix = hdr_sfx
  end

  def build_dependence(include_path)
    files = SourceFiles.get_all(@dir) do |f|
      f.end_with?(".#{@source_suffix}") || f.end_with?(".#{@header_suffix}")
    end

    @deps = Hash.new []
    files.each do |fname|
      @deps[fname] = get_all_headers include_path, fname, @header_suffix
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

  def get_all_headers(include_path, file, suffix = "hpp")
    File.open(file, "r") do |f|
      ret = []
      if file.end_with?(".#{@source_suffix}")
        header = file.sub(".#{@source_suffix}", ".#{@header_suffix}")
        ret += [header] if File.exists?(header)
      end

      f.each_line do |line|
        if mat = line.match(/include "(.+\.#{suffix})"/)
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
