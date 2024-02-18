# Copyright (c) 2022-2024 Leandro José Britto de Oliveira
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

# Windows customizations for GCC toolchain

ifndef cpb_hosts_windows_host_mk
cpb_hosts_windows_host_mk := $(lastword $(MAKEFILE_LIST))

ifndef cpb_builder_mk
    $(error This file cannot be manually included)
endif

ifneq ($(filter app lib,$(PROJ_TYPE)),)
    ifeq ($(PROJ_TYPE),app)
        ifndef ARTIFACT
            ARTIFACT := $(PROJ_NAME).exe
        endif
    else
        # $(PROJ_TYPE) is equal lib
        LIB_TYPE ?= shared
        ifeq ($(LIB_TYPE),static)
            ifndef ARTIFACT
                ARTIFACT := lib$(LIB_NAME).a
            endif
        else ifeq ($(LIB_TYPE),shared)
            ifndef ARTIFACT
                ARTIFACT := $(LIB_NAME).dll
            endif
        endif
	endif
endif

endif #cpb_hosts_windows_host_mk
