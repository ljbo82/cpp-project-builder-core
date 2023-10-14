# Copyright (c) 2023 Leandro José Britto de Oliveira
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

ifndef __project_mk__
    $(error This file cannot be manually included)
endif

ifeq ($(PROJ_TYPE),app)
    ifndef ARTIFACT
        ARTIFACT := $(PROJ_NAME)
    endif
else ifeq ($(PROJ_TYPE),lib)
    LIB_TYPE ?= shared
    ifndef ARTIFACT
        __hosts_linux_mk_target_base_name__ := lib$(PROJ_NAME)$(call FN_SEMVER_MAJOR,$(PROJ_VERSION))
        ifeq ($(LIB_TYPE),static)
            ARTIFACT := $(__hosts_linux_mk_target_base_name__).a
        endif
        ifeq ($(LIB_TYPE),shared)
            # NOTE: __hosts_linux_mk_shared_lib_suffix__ is modified in OSX hosts
            ifndef __hosts_linux_mk_shared_lib_suffix__
                __hosts_linux_mk_shared_lib_suffix__ := .so
            endif
            ARTIFACT := $(__hosts_linux_mk_target_base_name__)$(__hosts_linux_mk_shared_lib_suffix__)
            ifdef __hosts_linux_mk_shared_lib_suffix__
                undefine __hosts_linux_mk_shared_lib_suffix__
            endif
        endif
        undefine __hosts_linux_mk_target_base_name__
    endif
endif

endif # ifndef __hosts_linux_mk__
