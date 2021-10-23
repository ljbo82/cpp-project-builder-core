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

ifndef _include_jni_mk
_include_jni_mk := 1

# ------------------------------------------------------------------------------
_jni_mk_dir := $(dir $(lastword $(MAKEFILE_LIST)))
# ------------------------------------------------------------------------------

override PROJ_TYPE := lib
override LIB_TYPE  := shared

include $(_jni_mk_dir)/native_host.mk

O ?= output

ifeq ($(JDK_HOME),)
    jni_mk_error := JDK_HOME not set
endif

ifneq ($(jni_mk_error),)
    PRE_BUILD_DEPS += jni-mk-error
endif

ifeq ($(nativeOS),)
    $(error Could not detect native operating system)
else
    ifeq ($(nativeOS),windows)
        jniPlatform := win32
    else ifeq ($(nativeOS),linux)
        jniPlatform := linux
    else
        $(error Unsupported operating system: $(nativeOS))
    endif
endif

JAVA_SRC_DIR    ?= ../java/src/main/java
JNI_OUTPUT_DIR  := $(O)/jni
PRE_BUILD_DEPS  += jni-mk-header-gen
INCLUDE_DIRS    += $(JDK_HOME)/include $(JDK_HOME)/include/$(jniPlatform)
INCLUDE_DIRS    += $(JNI_OUTPUT_DIR)

include $(_jni_mk_dir)/project.mk

ifneq ($(JDK_HOME),)
    javac := $(JDK_HOME)/bin/javac
else
    javac := javac
endif

javaSrcFiles   := $(sort $(strip $(shell find $(JAVA_SRC_DIR) -type f -name '*.java' 2> /dev/null)))
jniHeaderDeps  := $(foreach javaSrcFile,$(javaSrcFiles),$(JNI_OUTPUT_DIR)/$(subst /,_,$(javaSrcFile:$(JAVA_SRC_DIR)/%.java=%.h)))

# $(call jniHeaderDep_template,dep)
define jniHeaderDep_template=
$(1)
	@printf "$$(nl)[JAVAC] $$@\n"
	@mkdir -p $$(dir $$@)
	$$(v)$$(javac) -d $(JNI_OUTPUT_DIR) -cp $(JAVA_SRC_DIR) -h $$(dir $$@) $$<
	@touch $$@
endef

$(foreach javaSrcFile,$(javaSrcFiles),$(eval $(call jniHeaderDep_template,$(JNI_OUTPUT_DIR)/$(subst /,_,$(javaSrcFile:$(JAVA_SRC_DIR)/%.java=%.h)): $(javaSrcFile))))

ifneq ($(jni_mk_error),)
.PHONY: jni-mk-error
jni-mk-error:
	$(error $(jni_mk_error))
endif

.PHONY: jni-mk-header-gen
jni-mk-header-gen: $(jniHeaderDeps)

endif # _include_jni_mk
