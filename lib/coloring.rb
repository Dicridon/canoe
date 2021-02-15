##
# gem Colorize is a great tool, but I don't want add dependencies to Canoe
class String
  def self.define_coloring_methods
    colors = {
      30 => :black,
      31 => :red,
      32 => :green,
      33 => :yellow,
      34 => :blue,
      35 => :magenta,
      36 => :cyan,
      37 => :white,
    }
    colors.each do |k, v|
      define_method v do
        "\033[#{k}m#{self}\033[0m"
      end
    end
  end

  define_coloring_methods
end
