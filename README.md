# Canoe
If you are a C/C++ programmer, writing `Makefile`, `CMakeLists.txt` or `SConstruct` may have been a pain for you. Even though `cmake` and `scons` are more human-friendly than legacy `make`, writing building scripts is still a mental torture because we simply forget all the syntax once the scripts are finished.

Such mental torture drives me to write `canoe`, a C/C++ project management tool inspired by `cargo` for Rust. Rustaceans simply type `cargo new`, `cargo build` and `cargo run` to create, build and run a Rust project. Now C/C++ programmers may type `canoe new`, `canoe build` and `canoe run` to create, build and run a C/C++ project without any scripting! Moreover, `canoe make` generates a `Makefile` for you for compatibility with legacy projects and machines!

# Functionality and limitations
- Building the whole project without forcing users to write any building scripts
- Automatically analyze which files should be recompiled
- Capable to interact with `make`-based C/C++ projects
- Conventions over file naming should be followed
- Unlike `make`, which is a universal building tool, `canoe` is specialized for C/C++.
# Prerequisite
To use beginless and endless range, `canoe` needs Ruby 2.7.1 or above

# Installation
`gem install canoe` to enjoy it!

# Uninstallation
`gem uninstall canoe`

# Conventions
The directory structure of a demo canoe project is as follow:
```
demo
   |----config.json
   |----obj
   |----src
   |     |----components
   |     |     |----dir1
   |     |     |     |----dir1.hpp
   |     |     |     |----dir1.cpp
   |     |     |----dir2
   |     |     |     |----dir2.hpp
   |     |     |     |----dir2.cpp
   |     |     |----tests
   |     |     |     |----tests.hpp
   |     |     |     |----tests.cpp
   |     |----main.cpp
   |----target
   |     |----demo
   |----tests
   |----third-party
```
`demo`: all commands except `canoe new` and `canoe version` should be executed under this directory.

`config`: This file configures compilation flags.

`obj`: compiled object files are stored here.

`src`: all source files are separated into components. `canoe add` may add extra components to this project.

`src/components/tests`: common functionalities for tests are implemented in this sub directory.

`target`: compiled executable binary or .so files are stored here.

`tests`: source files for executable test files are all in this directory

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
  |----config.json
  |----obj
  |----src
  |     |----components
  |     |     |----tests
  |     |     |     |----tests.hpp
  |     |     |     |----tests.cpp
  |     |----main.cpp
  |----target
  |----tests
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
  |     |     |----tests
  |     |     |     |----tests.hpp
  |     |     |     |----tests.cpp
  |     |----main.cpp
  |----target
  |----tests
  |----third-party
```

To use classes and functions in `engine`, we just need to include `engine/engine.hpp` in other source files(canoe adds `./src/components` to include path).

After some coding, we want to run this project to see how this demo works, so we just need to type `canoe run`, canoe would build this project and run the executable binary for you. And the project would be:
```
car
  |----config
  |----obj
  |     |----engine_engine.o
  |     |----main.o
  |     |----tests.o
  |----src
  |     |----components
  |     |     |----engine
  |     |     |     |----engine.hpp
  |     |     |     |----engine.cpp
  |     |     |----tests
  |     |     |     |----tests.hpp
  |     |     |     |----tests.cpp
  |     |----main.cpp
  |----target
  |     |----car
  |----tests
  |----third-party
```
Note that since we haven't added any code to `./src/components/tests/tests.cpp`, the `tests.o` object file is empty and of no use. It is compiled just because it is part of the project. 

Later if we decide to add one more helper component called `spark_plug` to component `engine`, we just need to type `canoe add engine/spark_plug`, and the project would be
```
car
  |----config
  |----obj
  |     |----engine_engine.o
  |     |----main.o
  |     |----tests.o  
  |----src
  |     |----components
  |     |     |----engine
  |     |     |     |----engine.hpp
  |     |     |     |----engine.cpp
  |     |     |     |----spark_plug
  |     |     |     |     |----spark_plug.hpp
  |     |     |     |     |----spark_plug.cpp
  |     |     |----tests
  |     |     |     |----tests.hpp
  |     |     |     |----tests.cpp
  |     |----main.cpp
  |----target
  |     |----car
  |----tests
  |----third-party
```
surely we would add one more line such as `#include "spark_plug/spark_plug.hpp"` to our `engine.hpp` or `engine.cpp`, so we need `canoe update` to update dependency relationships, then we could just `canoe run` again to see the output of our project.

# Test
After having fun with `canoe` for a while, we want to do some serious work and tests are important, thus we decide to add some tests to our project. We decide to test component `engine` to see if this module works fine.

So we **manually** add a file called `test_engine.cpp` in `./tests` directory. Every test file should begin with `test_`. Of course we need to include `engine/engine.hpp` in `test_engine.cpp`. Our project now would be:
```
car
  |----config
  |----obj
  |     |----engine_engine.o
  |     |----main.o
  |     |----tests.o  
  |----src
  |     |----components
  |     |     |----engine
  |     |     |     |----engine.hpp
  |     |     |     |----engine.cpp
  |     |     |     |----spark_plug
  |     |     |     |     |----spark_plug.hpp
  |     |     |     |     |----spark_plug.cpp
  |     |     |----tests
  |     |     |     |----tests.hpp
  |     |     |     |----tests.cpp
  |     |----main.cpp
  |----target
  |     |----car
  |----tests
  |     |----test_engine.cpp
  |----third-party
```
Then we type `canoe test engine`, `canoe` will start looking for an executable file named `test_engine` in `./target` and execute it if found. If the executable is missing, `canoe` analyzes dependency of `test_engine.cpp` and build it, then execute the test. After this, the project would be:

```
car
  |----config
  |----obj
  |     |----engine_engine.o
  |     |----main.o
  |     |----tests.o  
  |----src
  |     |----components
  |     |     |----engine
  |     |     |     |----engine.hpp
  |     |     |     |----engine.cpp
  |     |     |     |----spark_plug
  |     |     |     |     |----spark_plug.hpp
  |     |     |     |     |----spark_plug.cpp
  |     |     |----tests
  |     |     |     |----tests.hpp
  |     |     |     |----tests.cpp
  |     |----main.cpp
  |----target
  |     |----car
  |     |----test_engine
  |----tests
  |     |----test_engine.cpp
  |----third-party
```

When there are a lot of tests, we may use `canoe test` to run all tests. 

# Interaction with Make
Since `v0.3.1`, `canoe` understands how to generate `Makefile`. We may freely choose any two commands among `canoe build`, `canoe clean`, `make` and `make clean` to build our projects once `Makefile` is generated via command `canoe make`. (Eventually my schoolmates won't complain about they have to install `Ruby` even when the servers have no access to the Internet :). `make` and `make test` do the same things as `canoe build` and `canoe build test` and `make` together with `make test` is equivalent to `canoe build all`

Another reason pushing me to write `canoe make` is that single-thread compilation of C++ code is far too slow while `canoe` is a single thread building tool. Using `make` gets me rid of those tedious details in multithread programming and also prevents me to write more bugs. Since now `canoe` is able to interact with `make`, my personal expectation of `canoe` would be that: we create `canoe` projects and let `canoe` to manage dependency for us just like `cargo` for `Rust`, so we need to write no building scripts. When it comes to building, we use `canoe make` to generate `Makefile`s and use `make` for fast building.

I intended to write a `canoe cmake` for `CMake` users, but considering that `CMake` projects eventually invoke `make`, I decided to implement `canoe make` only.

# Interaction with compilation database
Some language servers require a `compile_commands.json` file to support syntax analysis and code completion. If you also use `eglot + clangd` like me, you may wish `canoe` could generate one for you. Since `v0.3.2.2`, `canoe` contains a command `canoe build base` to generate a `compile_commands.json` file. Alternatively, you may generate a `Makefile` via `canoe make` and then use `compile_commands.json` generating tool [bear](https://github.com/rizsotto/Bear) for generation. My personal recommendation would be using `canoe build base` because `bear` requires a `make clean` to purge all compiled objects before running it while  `canoe build base` does not.

# Let's write it together
I'm practicing `Ruby` with this tool, a lot of optimizations can be further conducted and my code style is not quite in the `Ruby` way. Plus, compared with `cargo`, `canoe` has only the basic building functionalities. So if you are interested in `canoe`, please join me and let's enhance `canoe` together! Send me an email at `noahxiong@outlook.com` if you'd like to join!

# Misc

## Why the project layout
One may feel uncomfortable with the separation of `./src/components/tests` from `./tests`, since they are all testing related, why not put them together? 

I choose this layout because the dependency analyzer I implemented works for source files all in one directory, while I separate `./tests` and `./src/components` to allow multiple files containing `main` function, thus for tests, sources files are in different directories. This layout allows me to directly use the analyzer without any modification.

## General workflow of using `canoe`
I usually first `canoe new` to create a project and `canoe add` to add all components I need.  After finishing one component, I create a test file for it and `canoe test` to test it.
After all components are finished, I finish the `main.cpp` and use `canoe make` to generate a `Makefile` for fast compilation. 

Sometimes I need to implement several versions of the project and compile several different executable files for experiments, so I make use of tests. I simply create several test files such as `test_v1.cpp`, `test_v2.cpp`, then use `canoe test v1` and `canoe test v2` to run different experiments.

Please remember, we have to `canoe update` when new components are added because the dependency cache `.canoe.deps` should be updated.

# Change log
- v0.3.3.1
  - buf fixes:
    - `canoe test` may fail due to `multiple definition` errors. It's caused by wrong dependency analysis. Now fixed.
- v0.3.3
  - bug fixes:
    - `canoe build` aborts when symlinks are in the working directories, now fixed. Note `canoe` does not access any symlinks.
    - `canoe build` may fail when building a `canoe` project pulled from Github whose `obj` and `target` directories are not tracked (broken project structure). Now `canoe new` automatically add `.gitignore` file under the two directories so that project structure is reserved.
    - `canoe run/test` does not display error message if running process crashes, now fixed
  - changes:
    - usage of `canoe test` changes, for details, please read the help message.
- v0.3.2.4
  - bug fixes:
    - `canoe test` recompiles test files when headers are modified
- v0.3.2.3
  - bug fixes:
    - `canoe test` does not rebuild the executable when source files are modified, now fixed
    - `canoe test` does not apply all compiling flags when only one test is compiled, now fixed
- v0.3.2.2:
  - new features:
    - command `canoe build base` is available for `compile_commands.json` generation.
  - bug fixes:
    - `canoe run` does not run the executable when every object is up-to-date, now fixed
- v0.3.2:
  - new features
    - command `canoe test` is finally here! Now `canoe build test`, `canoe test` will do the testing things for you
  - bug fixes:
    - `canoe run` runs only when building succeeds or target exists
  - RoadMap:
    - `canoe borrow` is a little complex because conflicts need to be resolved, I'm still considering it
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
      - canoe shall be able to handle interactions between different canoe projects, so different canoe projects would be able to freely share components among each other. This functionality would be offered by command `canoe borrow`
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
      - third-party library dependency analyze is **NOT** added, if you really need external library not presented as `.so` files, you may add dependency relationship in `.canoe.deps` file.
  - Roadmap
    - third-party dependency analyze should be added
    - (optional) allow users to specify their desired project layouts

- v0.1: basic commands `canoe new`, `canoe build`, `canoe clean`, `canoe run`, `canoe add` are available for building executable binary project. 
  - Roadmap
      - third-party libs management should be added
      - canoe should compile only modified files, instead of recompiling the whole project
      - allow user to specify their desired project layout
