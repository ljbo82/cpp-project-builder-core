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
_doxygen_mk_dir := $(dir $(lastword $(MAKEFILE_LIST)))
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
include $(_doxygen_mk_dir)common.mk
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
defaultDocOutputDirBase := output
ifeq ($(O), )
    O := $(defaultDocOutputDirBase)
endif
docOutputDir := $(O)/doc
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
ifeq ($(DOXYFILE),)
    DOXYFILE := Doxyfile
endif
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
__doxyargs := $(strip OUTPUT_DIRECTORY=$(docOutputDir) $(DOXYARGS))
__doxyargs := $(foreach arg,$(__doxyargs),echo cat $(arg); )
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
post-doc: pre-doc $(DOC_DEPS) $(POST_DOC_DEPS)
    ifeq ($(wildcard $(DOXYFILE)), )
	    $(error [ERROR] $(DOXYFILE) not found)
    else
	    @mkdir -p $(docOutputDir)
	    $(v)( cat $(DOXYFILE); $(__doxyargs) ) | doxygen -
        ifneq ($(POST_DOC), )
	        $(v)$(POST_DOC)
        endif
    endif
# ==============================================================================

endif # _include_doxygen_mk
