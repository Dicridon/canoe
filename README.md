# Canoe
canoe is a C/C++ project management tool, inspired by Cargo for Rust.

## Conventions
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

`config`: This files configures compilation flags.

`obj`: compiled object files are stored here.

`src`: all source files are seperated into components. `canoe add` may add extra components to this project.

`target`: compiled executable binary or .so files are stored here.

`third-party`: external libraries are stored here.

## Format of config file
a config file looks like below
```
[[name]]
values

[[another-name]]
value1 value2 value3
value4 value5 value6 value7
```

### Why not json
tired of curly-braces

### Why not toml
don't want external gems

### Why this format
[[ looks great, while don't want any other redundent symbols

## Example
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



## Change log
- v0.2: 
    - new feature: 
        - TODO: canoe now behaves like `make`: only modified files would be compiled!
- v0.1: basic commands `canoe new`, `canoe build`, `canoe clean`, `canoe run`, `canoe add` are available for building executable binary project. 
    - Roadmap
        - third-party libs management should be added
        - canoe should compile only modified files, instead of recompiling the whole project
        - allow user to specify their desired project layout
