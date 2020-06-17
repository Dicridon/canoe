# Canoe
canoe is a C/C++ project management tool, inspired by Cargo for Rust.

# Prequisite
Ruby 2.7.1 or above

# Installation
clone this repo:
`git clone https://github.com/Dicridon/canoe.git`
execute installation script
`./install.bash`

for autocomplete in commandline, 
`./scripts/canoe-completion.bash`
 
if you are using `zsh`, execute
`./scripts/canoe-completion.zsh`

# Uninstallation
simply remove `.canoe` and `canoe` in `/usr/local/bin`

# Conventions
The directory structure of a demo canoe project is as follow:
```
demo
   |----config
   |----obj
   |----src
   |     |----components
   |     |     |----dir1
   |     |           |----dir1.hpp
   |     |           |----dir1.cpp
   |     |     |----dir2
   |     |           |----dir2.hpp
   |     |           |----dir2.cpp
   |     |----main.cpp
   |----target
   |     |----demo
   |----third-party
```
`demo`: all commands except `canoe new` should be executed under this directory.

`config`: This file configures compilation flags.

`obj`: compiled object files are stored here.

`src`: all source files are seperated into components. `canoe add` may add extra components to this project.

`target`: compiled executable binary or .so files are stored here.

`third-party`: external libraries are stored here.

# Format of config file
a config file is a json file
```
{
  "compiler": "clang++",
  "header-suffix": "hpp",
  "source-suffix": "cpp",
  "flags": {
    "opt": "-O2",
    "debug": "-g",
    "std": "-std=c++17"
  }
}
```
`compiler` designates desired compiler

`header-suffix` and `source-suffix` designate desired source file suffix and header file suffix instead of 'cpp' and 'hpp' accordingly

`flags` are all the flags passed to the compiler, users may freely add new flags into this field and give them names, just like `opt` for `-O2`, so users may classify compile flags to avoid messing up flags

# Example
Say we are developing a car project. so we type `canoe new car` to create it. We will have a project like below:
```
car
  |----config
  |----obj
  |----src
  |     |----components
  |     |----main.cpp
  |----target
  |----third-party
```
Now we want to add a component `engine` to this project, so we type `canoe add engine`, and our project would be:
```
car
  |----config
  |----obj
  |----src
  |     |----components
  |     |     |----engine
  |     |     |     |----engine.hpp
  |     |     |     |----engine.cpp
  |     |----main.cpp
  |----target
  |----third-party
```

To use classes and funcitons in `eninge`, we just need to include `engine/engine.hpp` in other source files(canoe adds `./components` to include path).

After some coding, we want to run this project for a test, so we just need to type `canoe build && canoe run`, canoe would build this project and run the executable binary for you. And the project would be:
```
car
  |----config
  |----obj
  |     |----engine.o
  |     |----main.o
  |----src
  |     |----components
  |     |     |----engine
  |     |     |     |----engine.hpp
  |     |     |     |----engine.cpp
  |     |----main.cpp
  |----target
  |     |----car
  |----third-party
```



# Change log
- v0.2.2:
  - new command `dep` to see file dependencies
- v0.2.1:
  - new feature:
    - config file is now in json format, enjoy jsons!
    - users may specify desired file suffixes using option `--suffix=source_suffix:header_suffix`, please notice the `:` between two suffixes
  - Roadmap
    - third-party dependency analyze should be added
    - (optional) allow users to specify their desired project layouts
- v0.2: 
  - new command `generate`
    - this command would create a `.canoe.deps` file, and `canoe build` command later may selectively compile some modified files according to `.canoe.deps`
  - new feature: 
      - canoe now behaves like `make`: only modified files would be compiled!
      - you do not need to write anything like `Makefile`, canoe would analyze the dependency relationships of all files in one project and generate `.canoe.deps` to describe them.
      - third-party library dependency analyze is **NOT** added, if you realy need external library not presented as `.so` files, you may add dependency relationship in `.canoe.deps` file.
  - Roadmap
    - third-party dependency analyze should be added
    - (optional) allow users to specify their desired project layouts

- v0.1: basic commands `canoe new`, `canoe build`, `canoe clean`, `canoe run`, `canoe add` are available for building executable binary project. 
  - Roadmap
      - third-party libs management should be added
      - canoe should compile only modified files, instead of recompiling the whole project
      - allow user to specify their desired project layout
