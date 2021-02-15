# Canoe
If you are a C/C++ programmer, writing `Makefile`, `CMakeLists.txt` or `SConstruct` may have been a pain for you. Even though `cmake` and `scons` are more human-friendly than legacy `make`, writing building scripts is still a mental torture because we simply forget all the syntaxes once the scripts are finished.

Such mental torture drives me to write `canoe`, a C/C++ project management tool inspired by `cargo` for Rust. Rustaceans simple type `cargo new`, `cargo build` and `cargo run` to create, build and run a Rust project. Now C/C++ programmers may type `canoe new`, `canoe build` and `canoe run` to create, build and run a C/C++ project without any scripting! Moreover, `canoe make` generates a `Makefile` for you for compatibility with legacy projects and machines!

# Functionality and limitations
- Building the whole project without forcing users to write building scripts
- Automatically analyze which files should be recompiled
- Capable to interact with `make` based C/C++ projects
- Conventions over file naming should be followed
- Unlike `make`, which is a universal building tool, `canoe` is specialized for C/C++.
# Prerequisite
Ruby 2.7.1 or above

# Installation
`gem intall canoe` to enjoy it!

# Uninstallation
`gem uninstall canoe`

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
`demo`: all commands except `canoe new` and `canoe version` should be executed under this directory.

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
    "compile": {
      "opt": "-O2",
      "debug": "-g",
      "std": "-std=c++17"
    },
    "link": {

    }
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

After some coding, we want to run this project for a test, so we just need to type `canoe run`, canoe would build this project and run the executable binary for you. And the project would be:
```
car
  |----config
  |----obj
  |     |----engin_engine.o
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
Later if we decide to add one more helper component called `spark_plug` to component `engine`, we just need to type `canoe add enging/spark_plug`, and the project would be
```
car
  |----config
  |----obj
  |     |----engin_engine.o
  |     |----main.o
  |----src
  |     |----components
  |     |     |----engine
  |     |     |     |----engine.hpp
  |     |     |     |----engine.cpp
  |     |     |     |----spark_plug
  |     |     |     |     |----spark_plug.hpp
  |     |     |     |     |----spark_plug.cpp
  |     |----main.cpp
  |----target
  |     |----car
  |----third-party
```
surely we would add one more line such as `#include "spark_plug/spark_plug.hpp"` to our `engine.hpp` or `engine.cpp`, so we need `canoe update` to update dependency relationships, then we could just `canoe run` again to see the output of our project.

# Interaction with Make
Since `v0.3.1`, `canoe` understands how to generate `Makefile`. We may freely choose any two commands among `canoe build`, `canoe clean`, `make` and `make clean` to build our projects once `Makefile` is generated via command `canoe make`. (Eventually my schoolmates won't complain about they have to install `Ruby` even when the servers have no access to the Internet :).

Another reason pushing me to write `canoe make` is that single-thread compilation of C++ code is far too slow while `canoe` is a single thread building tool. Using `make` gets me rid of those tedious details in multithread programming and also prevents me to write more bugs. Since now `canoe` is able to interact with `make`, my personal expectation of `canoe` would be that: we create `canoe` projects and let `canoe` to manage dependency for us just like `cargo` for `Rust`, so we need to write no building scripts. When it comes to building, we use `canoe make` to generate `Makefile`s and use `make` for fast building.

I intended to write a `canoe cmake` for `CMake` users, but considering that `CMake` projects eventually invoke `make`, I decided to implement `canoe make` only.

# Let's write it together
I'm practicing `Ruby` with this tool, a lot of optimizations can be further conducted and my code style is not quite in the `Ruby` way. Plus, compared with `cargo`, `canoe` has only the basic building functionalities. So if you are interested in `canoe`, please join me and let's enhance `canoe` together! Send me an email at `noahxiong@outlook.com` if you'd like to join!

# Change log
- v0.3.1:
  - new features
    - new command `canoe make` is provided to generate a Makefile for a canoe project, so now `canoe` projects are compatible with `Makefile` based projects
  - bug fixes: 
    - `version` command won't failed when executed outside a `canoe` project
  - unfixed bugs:
    - `run` command always run the executable even if recompilation fails. This bug will be fixed when the command `test` is finished
  - RoadMap
    - `canoe test` and `canoe borrow` will be available if I had enough spare time :)
- v0.2.4:
  - new features
    - canoe now build shared object files!
  - improvements
    - README is updated with more detailed tutorial
    - help message is updated too
  - RoadMap
    - in v0.3.0
      - canoe shall be able to handle interations between different canoe projects, so different canoe projects would be able to freely share components among each other. This funcionality would be offered by command `canoe borrow`
      - third-party dependency analyze would be enabled, in coordinance with command `canoe borrow`
      - allowing users to specify their desired project layouts doesn't make much sense, so I am giving up this option
    - in v0.4.0
      - I should prepare enough tests for canoe
- v0.2.3:
  - no functionality update
  - corrected some false gem information
- v0.2.2:
  - new command `dep` to see file dependencies
- v0.2.1:
  - canoe now is a ruby **gem**, I can finally get rid of those ugly Bash scripts!
  - new features
    - config file is now in json format, enjoy jsons!
    - users may specify desired file suffixes using option `--suffix=source_suffix:header_suffix`, please notice the `:` between two suffixes
  - Roadmap
    - third-party dependency analyze should be added
    - (optional) allow users to specify their desired project layouts
- v0.2: 
  - new command `generate`
    - this command would create a `.canoe.deps` file, and `canoe build` command later may selectively compile some modified files according to `.canoe.deps`
  - new features:
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
