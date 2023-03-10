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

# Doxygen targets

ifndef __doxygen_mk__
__doxygen_mk__ := 1

# Include build system makefiles -----------------------------------------------
include $(dir $(lastword $(MAKEFILE_LIST)))common.mk
# ------------------------------------------------------------------------------

# Doc output directory ---------------------------------------------------------
DOC_DIR ?= doc
ifneq ($(words $(DOC_DIR)),1)
    $(error [DOC_DIR] Value cannot have whitespaces: $(DOC_DIR)
endif
ifeq ($(DOC_DIR),)
    $(error [DOC_DIR] Missing value)
endif
ifdef O_DOC_DIR
    $(error [O_DOC_DIR] Reserved variable)
endif
O_DOC_DIR := $(O)/$(DOC_DIR)
# ------------------------------------------------------------------------------

# Doxyfile definition ----------------------------------------------------------
DOXYFILE ?= Doxyfile
ifeq ($(DOXYFILE),)
    $(error [DOXYFILE] Missing value)
endif
ifneq ($(words $(DOXYFILE)),1)
    $(error [DOXYFILE] Value cannot have whitespaces: $(DOXYFILE)
endif
# ------------------------------------------------------------------------------

# DOC ==========================================================================
ifdef PRE_DOC_DEPS
    ifneq ($(origin PRE_DOC_DEPS),file)
        $(error [PRE_DOC_DEPS] Not defined in a makefile (origin: $(origin PRE_DOC_DEPS)))
    endif
endif
ifdef POST_DOC_DEPS
    ifneq ($(origin POST_DOC_DEPS),file)
        $(error [POST_DOC_DEPS] Not defined in a makefile (origin: $(origin POST_DOC_DEPS)))
    endif
endif

.PHONY: pre-doc
pre-doc: $(PRE_DOC_DEPS)

--__doxygen_mk_doc__: pre-doc
    ifeq ($(wildcard $(DOXYFILE)),)
	    $(error [DOXYFILE] File not found: $(DOXYFILE))
    else
	    @mkdir -p $(O_DOC_DIR)
	    $(O_VERBOSE)( cat $(DOXYFILE); $(foreach arg,$(strip OUTPUT_DIRECTORY=$(O_DOC_DIR) $(DOXYARGS)),echo cat $(arg); ) ) | doxygen -
    endif

--__doxygen_mk_post_doc__: --__doxygen_mk_doc__ $(POST_DOC_DEPS)

.PHONY: doc
doc: --__doxygen_mk_post_doc__
# ==============================================================================

endif # ifndef __doxygen_mk__
