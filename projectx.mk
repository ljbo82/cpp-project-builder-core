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

# Project parser

ifndef __project_mk__
__project_mk__ := 1

__project_mk_self_dir__ := $(dir $(lastword $(MAKEFILE_LIST)))

include $(__project_mk_self_dir__)common.mk







# LIBS -------------------------------------------------------------------------
ifdef LIBS
    ifneq ($(origin LIBS),file)
        $(error [LIBS] Not defined in a makefile (origin: $(origin LIBS)))
    endif
endif

#$(call __project_mk_libs_template1__,<lib_name>,[lib_dir])
define __project_mk_libs_template1__
__project_mk_libs_has_lib_dir__ := $$(if $$(or $$(__project_mk_libs_has_lib_dir__),$(2)),1,)
__project_mk_libs_ldflags__ += -l$(1)
$(if $(2),PRE_BUILD_DEPS += $$(O)/$(LIBS_SUBDIR)/$(1).marker,)
$(if $(2),--$(1):,)
$(if $(2),$$(O_VERBOSE)$$(MAKE) -C $(2) O=$$(call FN_REL_DIR,$(2),$$(O)/$(LIBS_SUBDIR)) BUILD_SUBDIR=$(1) DIST_MARKER=$(1).marker,)
$(if $(2),$$(O)/$(LIBS_SUBDIR)/$(1).marker: --$(1) ;,)

endef

# $(call __project_mk_libs_fn_lib_name__,<lib_entry>)
__project_mk_libs_fn_lib_name__     = $(word 1, $(subst :, ,$(1)))

# $(call __project_mk_libs_fn_lib_dir__,<lib_entry>)
__project_mk_libs_fn_lib_dir__      = $(word 2, $(subst :, ,$(1)))

# $(call __project_mk_libs_template__,<lib_entry>)
__project_mk_libs_template__    = $(call __project_mk_libs_template1__,$(call __project_mk_libs_fn_lib_name__,$(1)),$(call __project_mk_libs_fn_lib_dir__,$(1)))

# $(call __project_mk_libs_fn_template__,<lib_entry>)
__project_mk_libs_fn_template__ = $(eval $(call __project_mk_libs_template__,$(1)))

$(foreach lib,$(LIBS),$(call __project_mk_libs_fn_template__,$(lib)))
ifeq ($(__project_mk_libs_has_lib_dir__),1)
    INCLUDE_DIRS += $(O)/$(LIBS_SUBDIR)/dist/include
    LDFLAGS := $(LDFLAGS) -L$(O)/$(LIBS_SUBDIR)/dist/lib $(__project_mk_libs_ldflags__)
else
    LDFLAGS := $(LDFLAGS) $(__project_mk_libs_ldflags__)
endif
# ------------------------------------------------------------------------------

# LAZY -------------------------------------------------------------------------
ifdef LAZY
    ifneq ($(origin LAZY),file)
        $(error [LAZY] Not defined in a makefile (origin: $(origin LAZY)))
    endif
endif

$(eval $(LAZY))
# ------------------------------------------------------------------------------

undefine __project_mk_self_dir__


undefine __project_mk_libs_template1__
undefine __project_mk_libs_has_lib_dir__
undefine __project_mk_libs_ldflags__
undefine __project_mk_libs_fn_lib_name__
undefine __project_mk_libs_fn_lib_dir__
undefine __project_mk_libs_template__
undefine __project_mk_libs_fn_template__

endif # ifndef __project_mk__
