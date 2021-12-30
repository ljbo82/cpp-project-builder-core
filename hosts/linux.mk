# Copyright (c) 2022 Leandro José Britto de Oliveira
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# Linux host standard definitions

ifndef __hosts_linux_mk__
__hosts_linux_mk__ := 1

__hosts_linux_mk_proj_version_major__ := $(call FN_SEMVER_MAJOR,$(PROJ_VERSION))
__hosts_linux_mk_proj_version_minor__ := $(call FN_SEMVER_MINOR,$(PROJ_VERSION))
__hosts_linux_mk_proj_version_patch__ := $(call FN_SEMVER_PATCH,$(PROJ_VERSION))

__hosts_linux_mk_target_base_name__ := $(PROJ_NAME)$(__hosts_linux_mk_proj_version_major__)

ifeq ($(PROJ_TYPE),app)
    ifndef TARGET
        TARGET := $(__hosts_linux_mk_target_base_name__)
    endif
endif

ifeq ($(PROJ_TYPE),lib)
    LIB_TYPE ?= shared
    __hosts_linux_mk_target_base_name__ := lib$(__hosts_linux_mk_target_base_name__)

    ifeq ($(LIB_TYPE),static)
        __hosts_linux_mk_target_base_name__ := $(__hosts_linux_mk_target_base_name__).a
        __hosts_linux_mk_deps__ := y
    endif

    ifeq ($(LIB_TYPE),shared)
        __hosts_linux_mk_shared_lib_suffix__ ?= .so
        __hosts_linux_mk_target_base_name__ := $(__hosts_linux_mk_target_base_name__)$(__hosts_linux_mk_shared_lib_suffix__)
        __hosts_linux_mk_deps__ := y
    endif

    ifeq ($(__hosts_linux_mk_deps__),y)
        ifndef TARGET
            TARGET := $(__hosts_linux_mk_target_base_name__).$(__hosts_linux_mk_proj_version_minor__).$(__hosts_linux_mk_proj_version_patch__)

            # NOTE: SRC_FILES is defined later

            define __hosts_linux_mk_deps__
            POST_BUILD_DEPS += $$(if $$(SRC_FILES),$(O_BUILD_DIR)/$(__hosts_linux_mk_target_base_name__),)
            EXTRA_DIST_FILES += $$(if $$(SRC_FILES),$(O_BUILD_DIR)/$(__hosts_linux_mk_target_base_name__):lib/$(__hosts_linux_mk_target_base_name__),)
            endef

            $(eval $(__hosts_linux_mk_deps__))

            __hosts_linux_mk_deps__ := y
        endif
    endif
endif

# POST_BUILD_DEPS ==============================================================
ifeq ($(__hosts_linux_mk_deps__),y)
$(O_BUILD_DIR)/$(__hosts_linux_mk_target_base_name__): $(O_BUILD_DIR)/$(TARGET)
	$(if $(filter 1,$(V)),@echo [POST-BUILD] $@,)
	$(if $(filter 1,$(V)),,@)ln -sf $(notdir $<) $@
endif # ifeq ($(__hosts_linux_mk_deps__),y)
# ==============================================================================

undefine __hosts_linux_mk_proj_version_patch__
undefine __hosts_linux_mk_proj_version_minor__
undefine __hosts_linux_mk_proj_version_major__
undefine __hosts_linux_mk_target_base_name__
undefine __hosts_linux_mk_deps__
undefine __hosts_linux_mk_shared_lib_suffix__

endif # ifndef __hosts_linux_mk__
