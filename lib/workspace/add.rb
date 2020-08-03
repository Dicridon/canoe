class WorkSpace
  def add(args)
    args.each do |i|
      dir = @components
      filenames = i.split("/")
      prefix = []
      filenames.each do |filename|
        dir += "/#{filename}"
        prefix << filename
        unless Dir.exist? dir
          FileUtils.mkdir dir 
          Dir.chdir(dir) do
            puts "created " + Dir.pwd.blue
            create_working_files prefix.join('__'), filename
          end
        end
      end
    end
  end

private
  def create_working_files(prefix, filename)
    DefaultFiles.create_cpp filename, @source_suffix, @header_suffix
    DefaultFiles.create_hpp @name, prefix, filename, @header_suffix
  end
end