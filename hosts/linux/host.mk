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

__hosts_linux_mk_target_base_name__ := $(PROJ_NAME)$(call FN_SEMVER_MAJOR,$(PROJ_VERSION))

ifeq ($(PROJ_TYPE),app)
    ifndef ARTIFACT
        ARTIFACT := $(__hosts_linux_mk_target_base_name__)
    endif
endif

LIB_TYPE ?= shared

ifeq ($(PROJ_TYPE),lib)
    __hosts_linux_mk_target_base_name__ := lib$(__hosts_linux_mk_target_base_name__)

    ifeq ($(LIB_TYPE),static)
        ifndef ARTIFACT
            ARTIFACT := $(__hosts_linux_mk_target_base_name__).a
        endif
    endif

    ifeq ($(LIB_TYPE),shared)
        ifndef ARTIFACT
            __hosts_linux_mk_shared_lib_suffix__ ?= .so
            ARTIFACT := $(__hosts_linux_mk_target_base_name__)$(__hosts_linux_mk_shared_lib_suffix__)
        endif
    endif
endif


undefine __hosts_linux_mk_target_base_name__
undefine __hosts_linux_mk_shared_lib_suffix__

endif # ifndef __hosts_linux_mk__
