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

# Common definitions

ifndef cpb_include_common_mk
cpb_include_common_mk := 1

override undefine cpb_include_common_mk_self_dir

cpb_include_common_mk_self_dir := $(dir $(lastword $(MAKEFILE_LIST)))

include $(cpb_include_common_mk_self_dir)functions.mk

# Output directory -------------------------------------------------------------
O ?= output
$(call FN_CHECK_NON_EMPTY,O)
$(call FN_CHECK_NO_WHITESPACE,O)
# ------------------------------------------------------------------------------

# Enable/Disable verbose mode --------------------------------------------------
V ?= 0
$(call FN_CHECK_NON_EMPTY,V)
$(call FN_CHECK_WORDS,V,0 1)
ifdef VERBOSE
    $(error [VERBOSE] Reserved variable)
endif
VERBOSE := $(if $(filter 0,$(V)),@,)
# ------------------------------------------------------------------------------

endif # ifndef cpb_include_common_mk
