module Canoe
  class WorkSpace
    def new
      begin
        Dir.mkdir(@name)
      rescue SystemCallError
        abort_on_err "workspace #{@name} already exsits"
      end
      Dir.mkdir(@src)
      Dir.mkdir(@components)
      Dir.mkdir("#{@workspace}/obj")
      if @mode == :bin
        DefaultFiles.create_main(@src, @source_suffix)
      else
        DefaultFiles.create_lib_header(@src, @name, @header_suffix)
      end
      File.new("#{@workspace}/.canoe", 'w')
      compiler = @source_suffix == 'c' ? 'clang' : 'clang++'
      DefaultFiles.create_config @workspace, compiler, @source_suffix, @header_suffix

      Dir.mkdir(@third)
      Dir.mkdir(@target)
      Dir.mkdir(@tests)
      Dir.chdir(@workspace) do
        system 'git init'
        system 'canoe add tests'
      end
      puts "workspace #{@workspace.blue} is created"
    end
  end
end
