
find_program(DOCKER_EXECUTABLE docker)

function(add_docker_target target)
  set(options UPLOAD DELETE NO_DEFAULT_IMAGE_NAME)
  set(oneValueArgs USERNAME TAG REPOSITORY IMAGE PATH_CONTEXT URL_CONTEXT DOCKERFILE)
  set(multiValueArgs BUILD_ARGS OTHER_OPTIONS TAGS)
  cmake_parse_arguments(PARSE_ARGV 1 ADT "${options}" "${oneValueArgs}" "${multiValueArgs}")

  if("${DOCKER_EXECUTABLE}" STREQUAL "DOCKER_EXECUTABLE-NOTFOUND")
    message(FATAL_ERROR "add_docker_target called but Docker not found")
  endif()

  if(NOT target)
    message(FATAL_ERROR "add_docker_target called without TARGET specified")
  endif()
  set(ADT_TARGET ${target})

  if(NOT NO_DEFAULT_IMAGE_NAME AND NOT ADT_IMAGE)
    set(ADT_IMAGE ${target})
  endif()

  if(NOT ADT_TAG)
    message(WARN "add_docker_target called without TAG specified")
  endif()

  if(ADT_PATH_CONTEXT)
    if(IS_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/${ADT_PATH_CONTEXT})
      set(path_context ${CMAKE_CURRENT_SOURCE_DIR}/${ADT_PATH_CONTEXT})
    elseif(IS_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/${ADT_PATH_CONTEXT})
      set(path_context ${CMAKE_CURRENT_BINARY_DIR}/${ADT_PATH_CONTEXT})
    else()
      message(FATAL_ERROR "add_docker_target PATH_CONTEXT is not a directory")
    endif()
  endif()

  if(ADT_PATH_CONTEXT AND ADT_URL_CONTEXT)
    message(FATAL_ERROR "add_docker_target PATH_CONTEXT and URL_CONTEXT sepecified at the same time")
  endif()

  if(ADT_DOCKERFILE)
    set(dockerfile ${ADT_DOCKERFILE})
  elseif(ADT_PATH_CONTEXT)
    if(EXISTS ${path_context}/Dockerfile)
      set(dockerfile ${path_context}/Dockerfile)
    endif()
  endif()

  set(path_ctx "$<TARGET_GENEX_EVAL:${ADT_TARGET},$<TARGET_PROPERTY:${ADT_TARGET},PATH_CONTEXT>>")
  set(url_ctx "$<TARGET_GENEX_EVAL:${ADT_TARGET},$<TARGET_PROPERTY:${ADT_TARGET},URL_CONTEXT>>")
  set(repo_name "$<TARGET_GENEX_EVAL:${ADT_TARGET},$<TARGET_PROPERTY:${ADT_TARGET},REPOSITORY>>")
  set(image_name "$<TARGET_GENEX_EVAL:${ADT_TARGET},$<TARGET_PROPERTY:${ADT_TARGET},OUTPUT_NAME>>")
  set(tag "$<TARGET_GENEX_EVAL:${ADT_TARGET},$<TARGET_PROPERTY:${ADT_TARGET},TAG>>")
  set(tagged_name "$<$<BOOL:${repo_name}>:${repo_name}/>${image_name}:$<$<BOOL:${tag}>:${tag}>")
  set(other_tags "$<TARGET_GENEX_EVAL:${ADT_TARGET},$<TARGET_PROPERTY:${ADT_TARGET},TAGS>>")
  set(build_args "$<TARGET_GENEX_EVAL:${ADT_TARGET},$<TARGET_PROPERTY:${ADT_TARGET},BUILD_ARGS>>")

  add_custom_target(${ADT_TARGET} ALL
    COMMAND
        ${DOCKER_EXECUTABLE} build
        "$<$<BOOL:${build_args}>:--build-arg;$<JOIN:${build_args},;--build-arg;>>"
        "$<$<BOOL:${image_name}>:-t;${tagged_name}>"
        "$<$<BOOL:${other_tags}>:-t;$<JOIN:${other_tags},;-t;>>"
        "$<$<BOOL:${dockerfile}>:-f;${dockerfile}>"
        "$<IF:$<BOOL:${path_ctx}>,${path_ctx},${url_ctx}>"
    COMMAND_EXPAND_LISTS
    VERBATIM
  )

  if(ADT_PATH_CONTEXT)
    set_property(TARGET ${ADT_TARGET} PROPERTY PATH_CONTEXT ${path_context})
  endif()
  if(ADT_URL_CONTEXT)
    set_property(TARGET ${ADT_TARGET} PROPERTY URL_CONTEXT ${ADT_URL_CONTEXT})
  endif()
  if(ADT_REPOSITORY)
    set_property(TARGET ${ADT_TARGET} PROPERTY REPOSITORY ${ADT_REPOSITORY})
  endif()
  if(ADT_IMAGE)
    set_property(TARGET ${ADT_TARGET} PROPERTY OUTPUT_NAME ${ADT_IMAGE})
  endif()
  if(ADT_TAG)
    set_property(TARGET ${ADT_TARGET} PROPERTY TAG ${ADT_TAG})
  endif()
  if(ADT_TAGS)
    set_property(TARGET ${ADT_TARGET} PROPERTY TAGS ${ADT_TAGS})
  endif()
  foreach(arg IN LISTS ADT_BUILD_ARGS)
    set_property(TARGET ${ADT_TARGET} APPEND PROPERTY BUILD_ARGS ${arg})
  endforeach()
endfunction()

