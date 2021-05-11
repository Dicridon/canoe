module Canoe
  class WorkSpace
    def generate
      DepAnalyzer.new(@src_short, @source_suffix, @header_suffix)
                 .build_to_file [@src_short, @components_short], @deps
      DepAnalyzer.new(@tests_short, @source_suffix, @header_suffix)
                 .build_to_file [@src_short, @components_short], @test_deps
    end
  end
end
