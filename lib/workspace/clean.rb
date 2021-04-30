module Canoe
  class WorkSpace
    def clean
      self.send "clean_#{@mode.to_s}"
    end

    private

    def clean_obj
      puts "rm -f ./obj/*.o"
      system "rm -f ./obj/*.o"
    end

    def clean_target
      puts "rm -f ./target/*"
      system "rm -f ./target/*"
    end

    def clean_bin
      clean_obj
      clean_target
    end

    def clean_lib
      clean_obj
      clean_target
    end
  end
end 
