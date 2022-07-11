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

PROJ_NAME := hello
PROJ_TYPE := app

# Library includes will be placed into $(O_DIST_DIR)/include
INCLUDE_DIRS += $(O_DIST_DIR)/include

# Library binaries will be placed into $(O_DIST_DIR)/lib
LDFLAGS += -L$(O_DIST_DIR)/lib -lmylib0

CPP_PROJECT_BUILDER ?= ../..

# Since LIB_TYPE will be defined after platform layers are processed,
# includes project.mk instead of builder.mk in order to fully parse project
# data prior to compiler management.
include $(CPP_PROJECT_BUILDER)/project.mk

# At this point, LIB_TYPE is defined, but compiler management did not took
# place yet.

# Source code use special decorators when using a shared library
ifeq ($(LIB_TYPE),shared)
    CFLAGS += -DUSE_SHARED_LIB
endif

# ==============================================================================
# Library source directory
LIB_DIR ?= ../lib
LIB_OUTPUT := $(shell realpath -m --relative-to=$(LIB_DIR) $(O))
LIB_ARTIFACT := $(word 3, $(shell $(MAKE) -s -C $(LIB_DIR) print-vars VARS=ARTIFACT))

ARTIFACT_DEPS += $(O_DIST_DIR)/lib/$(LIB_ARTIFACT)

# Empty phony target used with the sole purpose of forcing a dependent target
# to be executed
.PHONY: --lib
--lib:

$(O_DIST_DIR)/lib/$(LIB_ARTIFACT): --lib
	@echo [BUILD] $@
    # NOTE: Uses a custom BUILD_DIR in order to isolate library object files from application ones.
	$(O_VERBOSE)$(MAKE) -C $(LIB_DIR) BUILD_DIR=build/lib O=$(LIB_OUTPUT)
# ==============================================================================

include $(CPP_PROJECT_BUILDER)/builder.mk
