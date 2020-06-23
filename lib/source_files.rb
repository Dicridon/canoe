class SourceFiles
  class << self
    def get_all(dir, &block)
      @files = []
      get_all_helper(dir, &block) 
      @files
    end

    def get_in(dir, &block)
      @files = []
      Dir.each_child(dir) do |f|
        file = "#{dir}/#{f}"
        if File.file? file
          if block_given?
            @files << "#{file}" if yield(f)
          else
            @files << "#{file}"
          end
        end 
      end
      
      @files
    end

    private
    def get_all_helper(dir, &block)
      Dir.each_child(dir) do |f|
        file = "#{dir}/#{f}"
        if File.file? file
          if block_given?
            @files << "#{file}" if yield(f)
          else
            @files << "#{file}"
          end
        else
          get_all_helper("#{file}", &block)
        end
      end
    end
  end
end

