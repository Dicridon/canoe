# Canoe
canoe is a C/C++ project management tool, inspired by Cargo for Rust.

## Conventions
The directory structure of a demo canoe project is as follow:
demo
   |----config
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
`demo`: All commands except `canoe new` should be executed under this directory.

`src`: all source files are seperated into components. `canoe add` may add extra components to this project.

`target`: compiled executable binary or .so files are stored here.

`third-party`: external libraries are stored here.

## Example
Say we are developing a car project. so we type `canoe new car` to create it.

We will have a project like below:
car
  |----config
  |----src
  |     |----components
  |     |----main.cpp
  |----target
  |----third-party

now we want to add a component `engine` to this project, so we type `canoe add engine`, and our project would be:
car
  |----config
  |----src
  |     |----components
  |     |     |----engine
  |     |     |     |----engine.hpp
  |     |     |     |----engine.cpp
  |     |----main.cpp
  |----target
  |----third-party

to use classes and funcitons in `eninge`, we just need to include `engine/engine.hpp` in other source files(canoe adds ./components to include path).

after some coding, we want to run this project for a test, so we just need to type `canoe build && canoe run`, canoe would build this project and run the executable binary for you. 

## Change log
- v0.1: basic commands `canoe new`, `canoe build`, `canoe clean`, `canoe run`, `canoe add` are available for building executable binary project. 
    - Roadmap
        - third-party libs management should be added
        - canoe should compile only modified files, instead of recompiling the whole project
        - allow user to specify their desired project layout