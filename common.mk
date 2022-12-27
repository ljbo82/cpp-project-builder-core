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

# Common definitions

ifndef __common_mk__
__common_mk__ := 1

# Checks for whitespace in CWD -------------------------------------------------
ifneq ($(words $(shell pwd)),1)
    $(error Current directory ($(shell pwd)) contains one or more whitespaces)
endif
# ------------------------------------------------------------------------------

# Enable/Disable verbose mode --------------------------------------------------
V ?= 0
ifeq ($(V),)
    $(error [V] Missing value)
endif
ifneq ($(V),0)
    ifneq ($(V),1)
        $(error [V] Invalid value: $(V))
    endif
endif
ifdef O_VERBOSE
    $(error [O_VERBOSE] Reserved variable)
endif
O_VERBOSE = $(if $(filter 0,$(V)),@,)
# ------------------------------------------------------------------------------

endif # ifndef __common_mk__
