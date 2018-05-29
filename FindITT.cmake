# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt or https://cmake.org/licensing for details.

#.rst:
# FindITT
# ---------
#
# Find Instrumentation and Tracing Technology (ITT) API include dirs and libraries
#
# Use this module by invoking find_package with the form
#
# ::
#
#   find_package(ITT
#     [REQUIRED]         # Fail with error if ITT is not found
#     )
#
# This module finds headers and libraries
# Results are reported in variables
#
# ::
#
#   ITT_FOUND            - True if headers and requested libraries were found
#   ITT_INCLUDE_DIRS     - ITT include directories
#   ITT_LIBRARIES        - ITT libraries to be linked
#
# This module reads hints about search locations from variables
#
# ::
#
#   SEAPI_ROOT                 - Preferred installation path for Intel� Single Event API (Intel� SEAPI)
#                                (https://github.com/intel/IntelSEAPI)
#   ITT_ROOT                   - Preferred installation path for standalone ITT library
#   INTEL_LIBITTNOTIFY32/
#   INTEL_LIBITTNOTIFY64       - Full path to the ITT library (32/64 .lib/.a)
#   VTUNE_AMPLIFIER_<YEAR>_DIR - VTune Amplifier XE installation path (set by amplxe-vars.sh/bat script)
#                                See [ITT_NO_VTUNE_PATH] description below
#
# Other variables one may set to control this module are
#
# ::
#
#   ITT_NO_VTUNE_PATH    - Set [ITT_NO_VTUNE_PATH] to [OFF] if you don't want to search package on VTune path
#   ITT_DEBUG            - Set to ON to enable debug output from FindITT.
#                          Please enable this before filing any bug report.
#
# Example to find ITT headers and libraries
#
# ::
#
#   find_package(ITT)
#   if (ITT_FOUND)
#     include_directories(${ITT_INCLUDE_DIRS})
#     add_executable(foo foo.cc)
#     target_link_libraries(foo ${ITT_LIBRARIES})
#   endif()

unset (_itt_INC_DIR_HINT)
unset (_itt_LIB_DIR_HINT)

set (_itt_ARC "")
if (${CMAKE_CXX_COMPILER_ARCHITECTURE_ID} MATCHES "x86")
	set (_itt_ARC "64")
elseif (${CMAKE_CXX_COMPILER_ARCHITECTURE_ID} MATCHES "x64")
	set (_itt_ARC "64")
endif()

if ("x${_itt_ARC}" STREQUAL "x")
	if (CMAKE_SIZEOF_VOID_P EQUAL 8)
		set (_itt_ARC "64")
	else()
		set (_itt_ARC "32")
	endif()
endif()

list (APPEND _itt_INC_DIR_HINT
	$ENV{ITT_ROOT}
	$ENV{SEAPI_ROOT}/ittnotify
)

set (_itt_LIBITTNOTIFY $ENV{INTEL_LIBITTNOTIFY${_itt_ARC}})
if (_itt_LIBITTNOTIFY)
	get_filename_component (_itt_LIB_DIR_HINT ${_itt_LIBITTNOTIFY} DIRECTORY)
	get_filename_component (_itt_INC_DIR_HINT ${_itt_LIB_DIR_HINT} DIRECTORY)
endif()

list (APPEND _itt_INC_DIR_HINT
	${_itt_INC_DIR_HINT}/ittnotify
)

if (NOT ITT_NO_VTUNE_PATH)
	execute_process (COMMAND "${CMAKE_COMMAND}" "-E" "environment"
		OUTPUT_VARIABLE _itt_ENV_LIST
	)

	string (REGEX MATCH "VTUNE_AMPLIFIER_[0-9]+_DIR"
		_itt_VTUNE_DIR ${_itt_ENV_LIST}
	)
endif()

if (_itt_VTUNE_DIR)
	list (APPEND _itt_INC_DIR_HINT $ENV{${_itt_VTUNE_DIR}})
endif()

if (ITT_DEBUG)
	message(STATUS "[ ${CMAKE_CURRENT_LIST_FILE}:${CMAKE_CURRENT_LIST_LINE} ] "
					"_itt_INC_DIR_HINT = ${_itt_INC_DIR_HINT}")
endif()

find_path (ITT_INCLUDE_DIR
	NAMES ittnotify.h
		HINTS
			${_itt_INC_DIR_HINT}
		PATH_SUFFIXES
			include
)

if (ITT_DEBUG)
	message(STATUS "[ ${CMAKE_CURRENT_LIST_FILE}:${CMAKE_CURRENT_LIST_LINE} ] "
	               "ITT_INCLUDE_DIR = ${ITT_INCLUDE_DIR}")
endif()

if (ITT_DEBUG)
	message(STATUS "[ ${CMAKE_CURRENT_LIST_FILE}:${CMAKE_CURRENT_LIST_LINE} ] "
	               "_itt_ARC = ${_itt_ARC}")
endif()

if (ITT_INCLUDE_DIR)
	get_filename_component (_itt_INC_DIR_HINT ${ITT_INCLUDE_DIR} DIRECTORY)
	list (APPEND _itt_LIB_DIR_HINT ${_itt_INC_DIR_HINT})
endif()

list (APPEND _itt_LIB_DIR_HINT
	$ENV{ITT_ROOT}
	$ENV{SEAPI_ROOT}
)

if (ITT_DEBUG)
	message (STATUS "[ ${CMAKE_CURRENT_LIST_FILE}:${CMAKE_CURRENT_LIST_LINE} ] "
	               "_itt_LIB_DIR_HINT = ${_itt_LIB_DIR_HINT}")
endif()

find_library (ITT_LIBRARY
	NAMES
		libittnotify
		libittnotify${_itt_ARC}
		ittnotify
		ittnotify${_itt_ARC}
	HINTS
		${_itt_LIB_DIR_HINT}
	PATH_SUFFIXES
		lib${_itt_ARC}
		lib
		bin
)

if (ITT_DEBUG)
	message(STATUS "[ ${CMAKE_CURRENT_LIST_FILE}:${CMAKE_CURRENT_LIST_LINE} ] "
	               "ITT_LIBRARY = ${ITT_LIBRARY}")
endif()

# handle the QUIETLY and REQUIRED arguments and set MFX_FOUND to TRUE if
# all listed variables are TRUE
include (${CMAKE_ROOT}/Modules/FindPackageHandleStandardArgs.cmake)
FIND_PACKAGE_HANDLE_STANDARD_ARGS (ITT
	REQUIRED_VARS ITT_INCLUDE_DIR ITT_LIBRARY
)

mark_as_advanced(ITT_INCLUDE_DIR ITT_LIBRARY)

if (ITT_FOUND)
	set (ITT_INCLUDE_DIRS ${ITT_INCLUDE_DIR})
	set (ITT_LIBRARIES  ${ITT_LIBRARY})
endif()