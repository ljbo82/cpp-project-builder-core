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

__doxygen_mk_dir := $(dir $(lastword $(MAKEFILE_LIST)))
include $(__doxygen_mk_dir)defs.mk

docBuildDir := $(distDir)/doc
ifeq ($(DOXYFILE), )
    DOXYFILE := Doxyfile
endif

# DOC ==========================================================================
.PHONY: doc 
doc: post-doc

.PHONY: pre-doc
pre-doc: $(PRE_DOC_DEPS)
    ifneq ($(PRE_DOC), )
	    @printf "$(nl)[PRE-DOC]\n"
	    $(v)$(PRE_DOC)
    endif

.PHONY: post-doc
post-doc: pre-doc $(DOC_DEPS)
    ifeq ($(wildcard $(DOXYFILE)), )
	    $(error [ERROR] $(DOXYFILE) not found)
    else
	    @mkdir -p $(docBuildDir)
	    $(v)( cat $(DOXYFILE); echo OUTPUT_DIRECTORY = $(docBuildDir) ) | doxygen -
        ifneq ($(POST_DOC), )
	        @printf "$(nl)[POST_DOC]\n"
	        $(v)$(POST_DOC)
        endif
    endif
# ==============================================================================

undefine __doxygen_mk_dir

endif # _include_doxygen_mk

