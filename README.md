# DockerCMakeModule

![GitHub top language](https://img.shields.io/github/languages/top/AronRubin/DockerCMakeModule)
![GitHub repo size](https://img.shields.io/github/repo-size/AronRubin/DockerCMakeModule)
![GitHub stars](https://img.shields.io/github/stars/AronRubin/DockerCMakeModule?style=social)
![GitHub forks](https://img.shields.io/github/forks/AronRubin/DockerCMakeModule?style=social)

The CMake module for Docker that should have already existed. This code is still a work in progress as it is a little unclear whether it

## Prerequisites

Before you begin, ensure you have a project with:
* Docker
* CMake >= 3.12

## Installing Docker CMake Module

This is just a single file cmake module with functions. Typically one would put it in a project's /cmake/modules directory, add that directory to the search path, and then include it. Feel free to include the functions in what ever manner conforms to your project's needs. Some don't use the modules subdirectory and that is fine.

```cmake
list(APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake/modules")

# a bunch of CMake directives later

include(Docker)
# now we can add docker targets
add_docker_target(eampletarget IMAGE outputimagename PATH_CONTEXT dir_of_context TAG postfix_tag_name)

```

## Using Docker CMake Module

### add_docker_target
Creates a cmake target to build an image from a Dockerfile or other context.
```cmake
add_docker_target(<target_name>
        [IMAGE <image_name>]
        [TAG <primary_tag>]
        [REPOSITORY <repository_prefix>]
        [NO_DEFAULT_IMAGE_NAME]
        [PATH_CONTEXT <path> | URL_CONTEXT <url>]
        [DOCKERFILE <filename>]
        [BUILD_ARGS <arg0> [<arg2>]...]
        [OTHER_OPTIONS <option0> [<option1>]...]
        [TAGS <tag0> [<tag1>]...]
        )
```
This command creates a target for a `docker build` and adds all of the supplied information as properties on the target.

#### IMAGE

The name for the container image. This will result in the name passed to the `-t` [tag](https://docs.docker.com/engine/reference/commandline/build/#tag-an-image--t) argument argument on the `docker build` command line.

#### TAG

The tag postfix for the container image. The supplied string will be appended to the image name after a colon `image:tag`. This will result in the fully tagged name passed to the `-t` [tag](https://docs.docker.com/engine/reference/commandline/build/#tag-an-image--t) argument on the `docker build` command line.

Docker's documentation indicates the tag will default to `latest` if none is supplied.

#### REPOSITORY

The registry or repository scope for the container image. The supplied string will be prepended with a `/` to the image name as `repository/image:tag`. This will result in the name passed to the `-t` [tag](https://docs.docker.com/engine/reference/commandline/build/#tag-an-image--t) argument on the `docker build` command line.

#### NO_DEFAULT_IMAGE_NAME
  
  Do not default the image name to the target name. If no image name is supplied, the `docker build` command line will have `-t` argument other than those from the `TAGS` property.
  
#### PATH_CONTEXT <path>
  
  [Docker PATH context](https://docs.docker.com/engine/reference/commandline/build/#build-with-path)
  
#### URL_CONTEXT <url>
  
  [Docker URL context](https://docs.docker.com/engine/reference/commandline/build/#build-with-url)
  
#### DOCKERFILE <filename>
  
  Specify a dockerfile for the build. If none is supplied, when using a PATH context this function will reference a Dockerfile in that path if one exists.
  
  [filename](https://docs.docker.com/engine/reference/commandline/build/#specify-a-dockerfile--f)
  
#### BUILD_ARGS <arg0> [<arg2>]...]
  
  Specify build-time variables.
  
  [Docker build args](https://docs.docker.com/engine/reference/commandline/build/#set-build-time-variables---build-arg)
  
#### OTHER_OPTIONS <option0> [<option1>]...]
  
  Not implemented in this version.
  
#### TAGS <tag0> [<tag1>]...]

  Specify additional tags to alias the built image to. The supplied tags are considered fully qualified and will be passed to the `docker build` commandline whole with `-t` [tag](https://docs.docker.com/engine/reference/commandline/build/#tag-an-image--t)
  
