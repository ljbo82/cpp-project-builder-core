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

# Doxygen support

ifndef cpb_doxygen_mk
cpb_doxygen_mk := $(lastword $(MAKEFILE_LIST))

include $(dir $(cpb_doxygen_mk))include/common.mk

# Doc src/output directories----------------------------------------------------
ifdef DOC_DIR
    $(call FN_CHECK_NON_EMPTY,DOC_DIR)
    $(call FN_CHECK_NO_WHITESPACE,DOC_DIR)
else
    DOC_DIR ?= $(O_BASE)/doc
endif
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

.PHONY: --cpb_doxygen_mk_pre_doc
--cpb_doxygen_mk_pre_doc: $(PRE_DOC_DEPS) ;

.PHONY: --cpb_doxygen_mk_doc
--cpb_doxygen_mk_doc: --cpb_doxygen_mk_pre_doc
    ifeq ($(wildcard $(DOXYFILE)),)
	    $(error [DOXYFILE] File not found: $(DOXYFILE))
    else
	    @mkdir -p $(DOC_DIR)
	    $(VERBOSE)(cat $(DOXYFILE)$(foreach arg,$(strip OUTPUT_DIRECTORY=$(DOC_DIR) $(DOXYARGS)),; echo "$(arg)")) | doxygen -
    endif

.PHONY: --cpb_doxygen_mk_post_doc
--cpb_doxygen_mk_post_doc: --cpb_doxygen_mk_doc $(POST_DOC_DEPS) ;

.PHONY: doc
doc: --cpb_doxygen_mk_post_doc ;
# ==============================================================================

# Exports default variable set for print-vars
VARS += DOC_DIR DOXYFILE PRE_DOC_DEPS POST_DOC_DEPS

endif # ifndef cpb_doxygen_mk
