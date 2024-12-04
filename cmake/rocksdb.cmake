# RocksDB:
# https://github.com/facebook/rocksdb/blob/main/CMakeLists.txt

include(FetchContent)
FetchContent_Declare(
    rocksdb
    GIT_REPOSITORY https://github.com/facebook/rocksdb.git
    GIT_TAG v7.6.0
    GIT_SHALLOW TRUE
)

FetchContent_GetProperties(rocksdb)

if(NOT rocksdb_POPULATED)
    set(WITH_LIBURING OFF CACHE INTERNAL "")
    set(WITH_SNAPPY ON CACHE INTERNAL "")
    set(WITH_LZ4 OFF CACHE INTERNAL "")
    set(WITH_GFLAGS OFF CACHE INTERNAL "")
    set(WITH_JEMALLOC OFF CACHE INTERNAL "")
    
    set(FAIL_ON_WARNINGS OFF CACHE INTERNAL "")
    set(USE_RTTI 1 CACHE INTERNAL "")
    set(FORCE_SSE42 OFF CACHE INTERNAL "")
    
    set(PORTABLE ON CACHE INTERNAL "")
    set(BUILD_SHARED OFF CACHE INTERNAL "")

    set(WITH_JNI OFF CACHE INTERNAL "")
    set(WITH_CORE_TOOLS OFF CACHE INTERNAL "")
    set(WITH_TOOLS OFF CACHE INTERNAL "")
    set(WITH_TESTS OFF CACHE INTERNAL "")
    set(WITH_ALL_TESTS OFF CACHE INTERNAL "")
    set(WITH_BENCHMARK_TOOLS OFF CACHE INTERNAL "")
    
    set(CMAKE_ENABLE_SHARED OFF CACHE INTERNAL "")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-implicit-fallthrough")

    FetchContent_Populate(rocksdb)
    add_subdirectory(${rocksdb_SOURCE_DIR} ${rocksdb_BINARY_DIR} EXCLUDE_FROM_ALL)
endif()

include_directories(${rocksdb_SOURCE_DIR}/include)
