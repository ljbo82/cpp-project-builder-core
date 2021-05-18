# This file is part of gcc-project-builder.
# Copyright (C) 2021 Leandro José Britto de Oliveira
#
# gcc-project-builder is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#
# gcc-project-builder is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with gcc-project-builder.  If not, see <https://www.gnu.org/licenses/>

ifndef _include_doxygen_mk
_include_doxygen_mk := 1

# ------------------------------------------------------------------------------
ifeq ($(DOC_BUILD_DIR), )
    DOC_BUILD_DIR := dist/doc
endif
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
ifeq ($(DOXYFILE), )
    DOXYFILE := Doxyfile
endif
# ------------------------------------------------------------------------------

# DOC ==========================================================================
.PHONY: doc
doc: post-doc

.PHONY: pre-doc
pre-doc: $(PRE_DOC_DEPS)
    ifneq ($(PRE_DOC), )
	    $(v)$(PRE_DOC)
    endif

.PHONY: post-doc
post-doc: pre-doc $(DOC_DEPS)
    ifeq ($(wildcard $(DOXYFILE)), )
	    $(error [ERROR] $(DOXYFILE) not found)
    else
	    @mkdir -p $(DOC_BUILD_DIR)
	    $(v)( cat $(DOXYFILE); echo OUTPUT_DIRECTORY = $(DOC_BUILD_DIR) ) | doxygen -
        ifneq ($(POST_DOC), )
	        $(v)$(POST_DOC)
        endif
    endif
# ==============================================================================

endif # _include_doxygen_mk

