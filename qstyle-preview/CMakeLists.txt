cmake_minimum_required(VERSION 3.16)
project(TenshiSTEPQStylePreview LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Build against whichever Qt the style plugins were built against (prefer Qt6).
find_package(QT NAMES Qt6 Qt5 COMPONENTS Widgets REQUIRED)
find_package(Qt${QT_VERSION_MAJOR} COMPONENTS Widgets REQUIRED)

add_executable(styletest main.cpp)
target_link_libraries(styletest PRIVATE Qt${QT_VERSION_MAJOR}::Widgets)
