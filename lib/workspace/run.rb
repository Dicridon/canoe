class WorkSpace
  def run(args)
    return if @mode == :lib
    build []
    args = args.join " "
    puts "./target/#{@name} #{args}"
    exec "./target/#{@name} #{args}"
  end
end