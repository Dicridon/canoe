class WorkSpace
  def self.version
    puts <<~VER
           canoe v0.3.1.1
           For features in this version, please visit https://github.com/Dicridon/canoe
           Currently, canoe can do below:
               - project creation
               - project auto build and run (works like Cargo for Rust)
               - project structure management
           by XIONG Ziwei
         VER
  end
end
