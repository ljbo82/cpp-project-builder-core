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

# LIB facility

ifndef __libs_mk__
__libs_mk__ := 1

#$(call __libs_mk_template1__,<lib_name>,[lib_dir])
define __libs_mk_template1__
__libs_mk_has_lib_dir__ := $$(if $$(or $$(__libs_mk_has_lib_dir__),$(2)),1,)
__libs_mk_ldflags__ += -l$(1)
$(if $(2),PRE_BUILD_DEPS += $$(O)/libs/$(1).marker,)
$(if $(2),--$(1):,)
$(if $(2),	$$(O_VERBOSE)$$(MAKE) -C $(2) O=$$(call FN_REL_DIR,$(2),$$(O)/libs) BUILD_SUBDIR=$(1) DIST_MARKER=$(1).marker,)
$(if $(2),$$(O)/libs/$(1).marker: --$(1) ;,)

endef

# $(call __libs_mk_fn_lib_name__,<lib_entry>)
__libs_mk_fn_lib_name__     = $(word 1, $(subst :, ,$(1)))

# $(call __libs_mk_fn_lib_dir__,<lib_entry>)
__libs_mk_fn_lib_dir__      = $(word 2, $(subst :, ,$(1)))

# $(call __libs_mk_template__,<lib_entry>)
__libs_mk_template__    = $(call __libs_mk_template1__,$(call __libs_mk_fn_lib_name__,$(1)),$(call __libs_mk_fn_lib_dir__,$(1)))

# $(call __libs_mk_fn_template__,<lib_entry>)
__libs_mk_fn_template__ = $(eval $(call __libs_mk_template__,$(1)))

$(foreach lib,$(LIBS),$(call __libs_mk_fn_template__,$(lib)))
ifeq ($(__libs_mk_has_lib_dir__),1)
    INCLUDE_DIRS += $(O)/libs/dist/include
    LDFLAGS := $(LDFLAGS) -L$(O)/libs/dist/lib $(__libs_mk_ldflags__)
else
    LDFLAGS := $(LDFLAGS) $(__libs_mk_ldflags__)
endif

undefine __libs_mk_template1__
undefine __libs_mk_has_lib_dir__
undefine __libs_mk_ldflags__
undefine __libs_mk_fn_lib_name__
undefine __libs_mk_fn_lib_dir__
undefine __libs_mk_template__
undefine __libs_mk_fn_template__

endif # ifndef __libs_mk__
