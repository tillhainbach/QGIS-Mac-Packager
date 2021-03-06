#!/bin/bash

DESC_openjpeg="Image manipulation library"

# version of your package
VERSION_openjpeg=2.3.1

LINK_openjpeg=libopenjp2.7.dylib

# dependencies of this recipe
DEPS_openjpeg=(
  png
  libtiff
  little_cms2
)

# url of the package
URL_openjpeg=https://github.com/uclouvain/openjpeg/archive/v${VERSION_openjpeg}.tar.gz

# md5 of the package
MD5_openjpeg=3b9941dc7a52f0376694adb15a72903f

# default build path
BUILD_openjpeg=$BUILD_PATH/openjpeg/$(get_directory $URL_openjpeg)

# default recipe path
RECIPE_openjpeg=$RECIPES_PATH/openjpeg

# function called for preparing source code if needed
# (you can apply patch etc here.)
function prebuild_openjpeg() {
  cd $BUILD_openjpeg

  # check marker
  if [ -f .patched ]; then
    return
  fi

  touch .patched
}

function shouldbuild_openjpeg() {
  # If lib is newer than the sourcecode skip build
  if [ ${STAGE_PATH}/lib/$LINK_openjpeg -nt $BUILD_openjpeg/.patched ]; then
    DO_BUILD=0
  fi
}

# function called to build the source code
function build_openjpeg() {
  try rsync -a $BUILD_openjpeg/ $BUILD_PATH/openjpeg/build-$ARCH/
  try cd $BUILD_PATH/openjpeg/build-$ARCH
  push_env

  try ${CMAKE} \
    -DBUILD_DOC=OFF \
    $BUILD_openjpeg
  check_file_configuration CMakeCache.txt

  try $NINJA
  try $NINJA install

  install_name_tool -id $STAGE_PATH/lib/$LINK_openjpeg $STAGE_PATH/lib/$LINK_openjpeg

  pop_env
}

# function called after all the compile have been done
function postbuild_openjpeg() {
  verify_binary lib/$LINK_openjpeg
}

# function to append information to config file
function add_config_info_openjpeg() {
  append_to_config_file "# openjpeg-${VERSION_openjpeg}: ${DESC_openjpeg}"
  append_to_config_file "export VERSION_openjpeg=${VERSION_openjpeg}"
  append_to_config_file "export LINK_openjpeg=${LINK_openjpeg}"
}