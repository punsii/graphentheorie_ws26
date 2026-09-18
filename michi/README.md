# Graph App Prototype.

Prototype program to build graphs in code and visualize them.  
Written in C99. Might change language later.

## Dependencies/Requirements
- raylib (in `./graph-app/dependencies/raylib/`).
- CMake 3.x

## Building
```bash
cd ./graph-app/
cmake -B build -S . -DCMAKE_BUILD_TYPE=Debug # Rlease for release build.
cmake --build build
```

## Running
```bash
./build/graphapp
```



