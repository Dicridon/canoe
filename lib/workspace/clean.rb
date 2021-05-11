module Canoe
  class WorkSpace
    # valid options: none, 'all', 'target', 'tests'
    def clean(args)
      options = {[] => 'all', ['all'] => 'all', ['target'] => 'target', ['tests'] => 'tests', ['obj'] => 'obj'}
      if options.include?(args)
        send "clean_#{options[args]}"
      else
        abort_on_err "Unkown subcommand #{args.join(' ').red}"
      end
    end

    private

    def clean_all
      clean_target
      clean_obj
    end

    def clean_target
      puts 'rm ./target/* -rf'
      system 'rm ./target/* -rf'
    end

    def clean_obj
      puts 'rm ./obj/* -rf'
      system 'rm ./obj/* -rf'
    end

    def clean_tests
      puts 'rm ./obj/test_* -rf'
      system 'rm ./obj/test_* -rf'
      puts 'rm ./target/test_* -rf'
      system 'rm ./target/test_* -rf'
    end
  end
end 
