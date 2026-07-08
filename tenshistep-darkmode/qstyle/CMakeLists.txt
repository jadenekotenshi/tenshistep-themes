cmake_minimum_required(VERSION 3.16)
project(TenshiSTEPDarkmodeStyle LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

# Build against whichever Qt is present (prefer Qt6).
find_package(QT NAMES Qt6 Qt5 COMPONENTS Widgets REQUIRED)
find_package(Qt${QT_VERSION_MAJOR} COMPONENTS Widgets REQUIRED)

add_library(tenshistepdarkmodestyle MODULE
    tenshistepstyle.cpp
    tenshistepstyleplugin.cpp
    tenshistepstyle.h
)
target_link_libraries(tenshistepdarkmodestyle PRIVATE Qt${QT_VERSION_MAJOR}::Widgets)

# Discover the Qt plugins directory and install into its styles/ subfolder.
get_target_property(_qmake Qt${QT_VERSION_MAJOR}::qmake IMPORTED_LOCATION)
if(_qmake)
    execute_process(COMMAND "${_qmake}" -query QT_INSTALL_PLUGINS
                    OUTPUT_VARIABLE QT_PLUGINS_DIR OUTPUT_STRIP_TRAILING_WHITESPACE)
endif()
if(NOT QT_PLUGINS_DIR)
    set(QT_PLUGINS_DIR "${CMAKE_INSTALL_PREFIX}/lib/qt${QT_VERSION_MAJOR}/plugins")
endif()

message(STATUS "TenshiSTEP style will install to: ${QT_PLUGINS_DIR}/styles")
install(TARGETS tenshistepdarkmodestyle LIBRARY DESTINATION "${QT_PLUGINS_DIR}/styles")
