##
# class SourceFiles
#   A simple class to assist collect all files or some files in a directory.
class SourceFiles
  class << self
    def get_all(dir, &block)
      @files = []
      get_all_helper(dir, &block)
      @files
    end

    def get_in(dir)
      @files = []
      Dir.each_child(dir) do |f|
        file = "#{dir}/#{f}"
        if File.file? file
          if block_given?
            @files << file.to_s if yield(f)
          else
            @files << file.to_s
          end
        end
      end

      @files
    end

    private

    def get_all_helper(dir, &block)
      Dir.each_child(dir) do |f|
        file = "#{dir}/#{f}"
        # we don't handle symlinks
        if File.file? file
          if block_given?
            @files << "#{file}" if yield(f)
          else
            @files << "#{file}"
          end
        elsif File.directory? file
          get_all_helper("#{file}", &block)
        end
      end
    end
  end
end
