class Coloring
  class << self
    COLORS = {
        30 => :black,
        31 => :red,
        32 => :green,
        33 => :yellow,
        34 => :blue,
        35 => :magenta,
        36 => :cyan,
        37 => :white
    }

    COLORS.each do |k, v|
      define_method v do |str|
        "\033[#{k}m#{str}\033[0m"
      end
    end
  end
end