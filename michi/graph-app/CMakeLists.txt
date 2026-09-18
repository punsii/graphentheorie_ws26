
cmake_minimum_required(VERSION 3.30.2)
project(raylibgame VERSION 0.0.1)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON) # compile_commands.json

add_subdirectory(./dependencies/raylib/)

add_executable(raygame
    main.c
)

target_include_directories(raygame PUBLIC
    ./dependencies/raylib/src/
)

target_link_libraries(raygame
    PRIVATE raylib
)
