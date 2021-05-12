module Canoe
  class WorkSpace
    # valid options: none, 'all', 'target', 'tests'
    def clean(args)
      options = {
        [] => 'all', ['all'] => 'all',
        ['target'] => 'target', ['tests'] => 'tests', ['obj'] => 'obj'
      }
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
      issue_command 'rm ./target/* -rf'
    end

    def clean_obj
      issue_command 'rm ./obj/* -rf'
    end

    def clean_tests
      issue_command 'rm ./obj/test_* -rf'
      issue_command 'rm ./target/test_* -rf'
    end
  end
end
