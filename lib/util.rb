require_relative 'coloring'

module Canoe
  class Stepper
    def initialize(total, togo)
      @total = total.to_f
      @togo = togo.to_f
    end

    def progress_as_str
      progress = ((@total - @togo) / @total).round(2) * 100
      "[#{progress.to_i}%%]"
    end

    def step
      @togo -= 1 if @togo.positive?
    end
  end
  
  ##
  # wrapping workspace related functionality to expose to other modules
  module WorkSpaceUtil
    def get_current_workspace
      abort_on_err 'not in a canoe workspace' unless File.exist? '.canoe'
      config = ConfigReader.extract_flags('config.json')

      src_sfx = config['source-suffix'] || 'cpp'
      hdr_sfx = config['header-suffix'] || 'hpp'

      name = Dir.pwd.split('/')[-1]
      mode = File.exist?("src/main.#{src_sfx}") ? :bin : :lib

      WorkSpace.new(name, mode, src_sfx, hdr_sfx)
    end

    def src_to_obj(src)
      get_current_workspace.src_to_obj(src)
    end

    def comp_to_obj(comp)
      get_current_workspace.comp_to_obj(comp)
    end

    def file_to_obj(file)
      get_current_workspace.file_to_obj(file)
    end

    def extract_one_file(file, deps)
      get_current_workspace.extract_one_file(file, deps)
    end

    def extract_one_file_obj(file, deps)
      get_current_workspace.extract_one_file_obj(file, deps)
    end
  end

  module SystemCommand
    def issue_command(cmd_str)
      puts cmd_str
      system cmd_str
    end
  end
  
  module Err
    def warn_on_err(err)
      puts <<~ERR
           #{'Waring: '.yellow}
               #{err}
           try 'canoe help' for more information
         ERR
    end

    def abort_on_err(err)
      abort <<~ERR
            #{'Fatal: '.red}
                #{err}
            try 'canoe help' for more information
          ERR
    end
  end
end
