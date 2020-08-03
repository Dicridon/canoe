class WorkSpace
  def generate
    DepAnalyzer.new('./src', @source_suffix, @header_suffix)
               .build_to_file ['./src', './src/components'], @deps
  end
end
