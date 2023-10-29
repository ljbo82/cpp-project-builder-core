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

# Common definitions

ifndef include_common_mk
include_common_mk := 1

# Output directory -------------------------------------------------------------
O ?= output
ifeq ($(O),)
    $(error [O] Missing value)
endif
ifneq ($(words $(O)),1)
    $(error [O] Value cannot have whitespaces: $(O))
endif
# ------------------------------------------------------------------------------

# Enable/Disable verbose mode --------------------------------------------------
V ?= 0
ifeq ($(V),)
    $(error [V] Missing value)
endif
ifneq ($(call FN_INVALID_OPTION,$(V),0 1),)
    $(error [V] Invalid value: $(V))
endif
ifdef VERBOSE
    $(error [VERBOSE] Reserved variable)
endif
VERBOSE := $(if $(filter 0,$(V)),@,)
# ------------------------------------------------------------------------------

# Allows passing additional compiler flags via command line --------------------
override undefine common_mk_tmp

common_mk_tmp := $(ASFLAGS)
override undefine ASFLAGS
ASFLAGS := $(common_mk_tmp)

common_mk_tmp := $(CFLAGS)
override undefine CFLAGS
CFLAGS := $(common_mk_tmp)

common_mk_tmp := $(CXXFLAGS)
override undefine CXXFLAGS
CXXFLAGS := $(common_mk_tmp)

common_mk_tmp := $(ARFLAGS)
override undefine ARFLAGS
ARFLAGS := $(common_mk_tmp)

common_mk_tmp := $(LDFLAGS)
override undefine LDFLAGS
LDFLAGS := $(common_mk_tmp)

undefine common_mk_tmp
# ------------------------------------------------------------------------------

endif # ifndef include_common_mk
