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

# Doxygen support

ifndef doxygen_mk
doxygen_mk := 1

include $(dir $(lastword $(MAKEFILE_LIST)))common.mk

# Doc src/output directories----------------------------------------------------
DOC_DIR ?= doc
ifneq ($(words $(DOC_DIR)),1)
    $(error [DOC_DIR] Value cannot have whitespaces: $(DOC_DIR))
endif
ifeq ($(DOC_DIR),)
    $(error [DOC_DIR] Missing value)
endif
ifdef O_DOC_DIR
    $(error [O_DOC_DIR] Reserved variable)
endif
O_DOC_DIR := $(O)/doc
# ------------------------------------------------------------------------------

# Doxyfile definition ----------------------------------------------------------
DOXYFILE ?= Doxyfile
ifeq ($(DOXYFILE),)
    $(error [DOXYFILE] Missing value)
endif
ifneq ($(words $(DOXYFILE)),1)
    $(error [DOXYFILE] Value cannot have whitespaces: $(DOXYFILE))
endif
# ------------------------------------------------------------------------------

# doc ==========================================================================
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

.PHONY: --doxygen_mk_pre_doc
--doxygen_mk_pre_doc: $(PRE_DOC_DEPS) ;

.PHONY: --doxygen_mk_doc
--doxygen_mk_doc: --doxygen_mk_pre_doc
    ifeq ($(wildcard $(DOXYFILE)),)
	    $(error [DOXYFILE] File not found: $(DOXYFILE))
    else
	    @mkdir -p $(O_DOC_DIR)
	    $(VERBOSE)(cat $(DOXYFILE)$(foreach arg,$(strip OUTPUT_DIRECTORY=$(O_DOC_DIR) $(DOXYARGS)),; echo cat $(arg))) | doxygen -
    endif

.PHONY: --doxygen_mk_post_doc
--doxygen_mk_post_doc: --doxygen_mk_doc $(POST_DOC_DEPS) ;

.PHONY: doc
doc: --doxygen_mk_post_doc ;
# ==============================================================================

endif # ifndef doxygen_mk
