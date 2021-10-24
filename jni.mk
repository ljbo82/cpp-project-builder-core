# This file is part of gcc-project-builder.
# Copyright (C) 2021 Leandro José Britto de Oliveira
#
# gcc-project-builder is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#
# gcc-project-builder is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with gcc-project-builder.  If not, see <https://www.gnu.org/licenses/>

ifndef __include_jni_mk__
__include_jni_mk__ := 1

# ------------------------------------------------------------------------------
__jni_mk_dir__ := $(dir $(lastword $(MAKEFILE_LIST)))
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
ifneq ($(PROJ_TYPE),)
    ifneq ($(PROJ_TYPE), lib)
        $(error Invalid PROJ_TYPE: $(PROJ_TYPE))
    endif
else
    PROJ_TYPE := lib
endif
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
ifneq ($(LIB_TYPE),)
    ifneq ($(LIB_TYPE), shared)
        $(error Invalid LIB_TYPE: $(LIB_TYPE))
    endif
else
     LIB_TYPE  := shared
endif
# ------------------------------------------------------------------------------
include $(__jni_mk_dir__)/native_host.mk

ifeq ($(nativeOS),)
    $(error Could not detect native operating system)
else
    ifeq ($(nativeOS),windows)
        jdkOS := win32
    else ifeq ($(nativeOS),linux)
        jdkOS := linux
    else
        $(error Unsupported operating system: $(nativeOS))
    endif
endif
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
ifeq ($(JDK_HOME),)
    ifeq ($(shell sh -c "java -version > /dev/null 2>&1 && echo 1 || echo 0"),0)
        __preBuildError__ := Could not detect JDK_HOME
    else
        include $(__jni_mk_dir__)/functions.mk
        JDK_HOME := $(strip $(call fn_cut,$(shell java -XshowSettings:properties -version 2>&1 > /dev/null | grep 'java.home'),=,2))
    endif
endif
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
JAVA_PROJ_DIR       ?= ../java
JAVA_PROJ_BUILD_CMD ?= mvn package
JAVA_PROJ_CLEAN_CMD ?= mvn clean
JAVA_PROJ_JAR       ?= $(JAVA_PROJ_DIR)/target/$(PROJ_NAME)-$(PROJ_VERSION).jar
JAVA_PROJ_SRC_DIR   ?= $(JAVA_PROJ_DIR)/src/main
JNI_HEADERS_DIR     ?= $(JAVA_PROJ_DIR)/target/headers
PRE_BUILD_DEPS      += $(JAVA_PROJ_JAR)
CLEAN_DEPS          += jni-clean
INCLUDE_DIRS        += $(JDK_HOME)/include $(JDK_HOME)/include/$(jdkOS) $(JNI_HEADERS_DIR)

ifneq ($(wildcard $(JAVA_PROJ_DIR)/pom.xml),)
    javaSrcFiles := $(JAVA_PROJ_DIR)/pom.xml
endif
javaSrcFiles := $(strip $(javaSrcFiles) $(sort $(shell find $(JAVA_PROJ_SRC_DIR) -type f 2> /dev/null)))

include $(__jni_mk_dir__)/project.mk
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
.PHONY: jni-clean
jni-clean:
	$(v)cd $(JAVA_PROJ_DIR) && $(JAVA_PROJ_CLEAN_CMD)

$(JAVA_PROJ_JAR): $(javaSrcFiles)
	@printf "$(nl)[JAVA] $@\n"
	@mkdir -p $(distDir)
	$(v)cd $(JAVA_PROJ_DIR) && JAVA_HOME=$(JDK_HOME) $(JAVA_PROJ_BUILD_CMD)
	@ln -f $@ $(distDir)
endif # __include_jni_mk__
# ------------------------------------------------------------------------------
