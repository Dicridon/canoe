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
        next unless File.file?(file)

        add = true
        add = yield(f) if block_given?
        @files << file.to_s if add
      end

      @files
    end

    private

    def get_all_helper(dir, &block)
      Dir.each_child(dir) do |f|
        file = "#{dir}/#{f}"
        # we don't handle symlinks
        if File.file? file
          add = true
          add = yield(f) if block_given?
          @files << file if add
        elsif File.directory? file
          get_all_helper(file, &block)
        end
      end
    end
  end
end
