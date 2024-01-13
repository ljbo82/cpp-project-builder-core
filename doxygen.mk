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

override undefine doxygen_mk_self_dir

doxygen_mk_self_dir := $(dir $(lastword $(MAKEFILE_LIST)))

include $(doxygen_mk_self_dir)include/common.mk

# Doc src/output directories----------------------------------------------------
DOC_DIR ?= doc
$(call FN_CHECK_NON_EMPTY,DOC_DIR)
$(call FN_CHECK_NO_WHITESPACE,DOC_DIR)
ifdef O_DOC_DIR
    $(error [O_DOC_DIR] Reserved variable)
endif
O_DOC_DIR := $(O)/doc
# ------------------------------------------------------------------------------

# Doxyfile definition ----------------------------------------------------------
DOXYFILE ?= Doxyfile
$(call FN_CHECK_NON_EMPTY,DOXYFILE)
$(call FN_CHECK_NO_WHITESPACE,DOXYFILE)
# ------------------------------------------------------------------------------

# doc ==========================================================================
ifdef PRE_DOC_DEPS
    $(call FN_CHECK_ORIGIN,PRE_DOC_DEPS,file)
endif
ifdef POST_DOC_DEPS
    $(call FN_CHECK_ORIGIN,POST_DOC_DEPS,file)
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
