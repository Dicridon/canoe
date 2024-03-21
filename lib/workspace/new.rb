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
      Dir.mkdir(@obj)
      add_gitignore @obj
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
      add_gitignore @target      
      Dir.mkdir(@tests)
      Dir.chdir(@workspace) do
        issue_command 'git init'
        issue_command 'canoe add tests'
        DefaultFiles.create_clang_format @workspace
      end
      puts "workspace #{@workspace.blue} is created"
    end

    private

    def add_gitignore(dir)
      Dir.chdir(dir) do
        File.open('.gitignore', 'w') do |f|
          f.write "*\n!.gitignore\n"
        end
      end
    end
  end
end
