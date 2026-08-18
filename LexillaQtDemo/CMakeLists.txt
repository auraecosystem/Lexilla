cmake_minimum_required(VERSION 3.16)
project(LexillaQtDemo LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Widgets Core)
# For Qt5, replace the line above with:
# find_package(Qt5 REQUIRED COMPONENTS Widgets Core)

qt_standard_project_setup()

qt_add_executable(LexillaQtDemo
    main.cpp
    MainWindow.h
    MainWindow.cpp
)

target_link_libraries(LexillaQtDemo PRIVATE 
    Qt6::Widgets 
    Qt6::Core
)

if(UNIX AND NOT APPLE)
    target_link_libraries(LexillaQtDemo PRIVATE ${CMAKE_DL_LIBS})
endif()
