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

GCC_PROJECT_BUILDER ?= ../..

PROJ_NAME := hello
PROJ_TYPE := app

INCLUDE_DIRS += $(O_DIST_DIR)/include
LDFLAGS      += -L$(O_DIST_DIR)/lib -lmylib0

include $(GCC_PROJECT_BUILDER)/project.mk

# Source code use special decorators when building a shared library
ifeq ($(LIB_TYPE),shared)
    CFLAGS += -DUSE_DLL
endif

# Forces build of mylib before application build
PRE_BUILD_DEPS += lib

include $(GCC_PROJECT_BUILDER)/builder.mk

# ==============================================================================
# Library source directory
LIB_DIR ?= ../lib

.PHONY: lib
lib:
	@echo [PRE-BUILD] lib
    # NOTE: Uses a custom BUILD_DIR in order to isolate library object files from application ones.
	$(O_VERBOSE)$(MAKE) -C $(LIB_DIR) BUILD_DIR=build/lib O=$(shell realpath -m --relative-to=$(LIB_DIR) $(O))
# ==============================================================================
