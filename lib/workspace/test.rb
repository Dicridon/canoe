class WorkSpace
  public

  def test(args)
    if args.empty?
      test_all
      return
    end

    args.each do |arg|
      case arg
      when "all"
        test_all
      else
        test_single arg
      end
    end
  end

  private

  def test_all
    puts "tests all"
  end

  def test_single(name)
    puts "#{@tests}/bin/test_#{name}"
    # system "./#{@tests}/bin/test_#{name}"
  end

  ##
  # how to build:
  # each test file tests one or more components, indicated by included headers
  # find corresponding object file in ../obj and link them to test file
  # TODO
  def build_test
    build
    deps = DepAnalyzer.new("./tests").build_to_file(["./src", "./src/components", "./tests", "./tests/common"], "./tests/.canoe.deps")
    puts deps
  end
end
