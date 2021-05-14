module Canoe
  class WorkSpace
    # valid options: none, 'all', 'target', 'tests'
    def clean(arg = 'all')
      send "clean_#{arg}"
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
