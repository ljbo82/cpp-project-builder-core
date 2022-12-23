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

# Windows host standard definitions

ifndef __hosts_windows_mk__
__hosts_windows_mk__ := 1

ifeq ($(HOST),windows-x86)
    export CROSS_COMPILE ?= i686-w64-mingw32-
else ifeq ($(HOST),windows-x64)
    export CROSS_COMPILE ?= x86_64-w64-mingw32-
endif

ifeq ($(PROJ_TYPE),app)
    ifndef ARTIFACT
        ARTIFACT := $(PROJ_NAME)$(call FN_SEMVER_MAJOR,$(PROJ_VERSION)).exe
    endif
endif

LIB_TYPE ?= shared

ifeq ($(PROJ_TYPE),lib)
    ifeq ($(LIB_TYPE),static)
        ifndef ARTIFACT
            ARTIFACT := lib$(PROJ_NAME)$(call FN_SEMVER_MAJOR,$(PROJ_VERSION)).a
        endif
    endif

    ifeq ($(LIB_TYPE),shared)
        ifndef ARTIFACT
            ARTIFACT := $(PROJ_NAME)$(call FN_SEMVER_MAJOR,$(PROJ_VERSION)).dll
        endif
        LDFLAGS += -Wl,--out-implib,$(O_BUILD_DIR)/$(ARTIFACT).lib
        LDFLAGS += -Wl,--output-def,$(O_BUILD_DIR)/$(ARTIFACT).def
        DIST_FILES += $(if $(SRC_FILES),$(O_BUILD_DIR)/$(ARTIFACT).lib:lib/$(ARTIFACT).lib,)
        DIST_FILES += $(if $(SRC_FILES),$(O_BUILD_DIR)/$(ARTIFACT).def:lib/$(ARTIFACT).def)
    endif
endif

endif #__hosts_windows_mk__
