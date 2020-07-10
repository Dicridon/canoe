require_relative 'coloring'
module Err
  def warn_on_err(err)
    puts <<~ERR
           #{Coloring.yellow("Waring: ")}
               #{err}
           try 'canoe help' for more information
         ERR
  end

  def abort_on_err(err)
    abort <<~ERR
            #{Coloring.red("Fatal: ")}
                #{err}
            try 'canoe help' for more information
         ERR
  end

  module_function :warn_on_err, :abort_on_err
end