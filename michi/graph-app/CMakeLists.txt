
cmake_minimum_required(VERSION 3.30.2)
project(graphapp VERSION 0.0.1)

set(CMAKE_C_STANDARD 99)
SET(CMAKE_C_FLAGS "-Wall -Wextra")
set(CMAKE_EXPORT_COMPILE_COMMANDS ON) # compile_commands.json

add_subdirectory(./dependencies/raylib/)

add_executable(graphapp
    main.c
    graph.c
)

target_include_directories(graphapp PUBLIC
    ./dependencies/raylib/src/
)

target_link_libraries(graphapp
    PRIVATE raylib
)
