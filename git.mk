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

# Git repository support

ifndef cpb_git_mk
cpb_git_mk := $(lastword $(MAKEFILE_LIST))

include $(dir $(cpb_git_mk))include/common.mk

GIT_REPO_DIR ?= .
$(call FN_CHECK_NON_EMPTY,GIT_REPO_DIR)
$(call FN_CHECK_NO_WHITESPACE,GIT_REPO_DIR)
$(call FN_CHECK_ORIGIN,GIT_REPO_DIR,file)

$(call FN_CHECK_RESERVED,cpb_git_mk_repo_available)
cpb_git_mk_repo_available := $(call FN_SHELL,cd $(GIT_REPO_DIR) > /dev/null 2>&1; git status > /dev/null 2>&1 && echo y)

ifneq ($(cpb_git_mk_repo_available),)
    $(call FN_CHECK_RESERVED,GIT_COMMIT)
    GIT_COMMIT := $(call FN_SHELL,cd $(GIT_REPO_DIR) > /dev/null 2>&1; git rev-parse HEAD > /dev/null 2>&1 && echo y)
    ifneq ($(GIT_COMMIT),)
        GIT_COMMIT := $(call FN_SHELL,cd $(GIT_REPO_DIR) > /dev/null 2>&1; git rev-parse HEAD)

        $(call FN_CHECK_RESERVED,GIT_COMMIT_SHORT)
        GIT_COMMIT_SHORT := $(call FN_SHELL,cd $(GIT_REPO_DIR) > /dev/null 2>&1; git rev-parse --short HEAD)

        $(call FN_CHECK_RESERVED,GIT_STATUS)
        GIT_STATUS := $(call FN_SHELL,cd $(GIT_REPO_DIR) > /dev/null 2>&1; git status -s)
        ifeq ($(GIT_STATUS),)
            GIT_STATUS := clean
        else
            GIT_STATUS := dirty
        endif

        $(call FN_CHECK_RESERVED,GIT_TAG)
        GIT_TAG := $(call FN_SHELL,cd $(GIT_REPO_DIR) > /dev/null 2>&1; git describe --tags > /dev/null 2>&1 && echo y)
        ifneq ($(GIT_TAG),)
            GIT_TAG := $(call FN_SHELL,cd $(GIT_REPO_DIR) > /dev/null 2>&1; git describe --tags)
        else
            undefine GIT_TAG
        endif
    else
        undefine GIT_COMMIT
    endif
endif

$(call FN_CHECK_RESERVED,GIT_VERSION)
ifneq ($(GIT_TAG),)
    GIT_VERSION := $(GIT_TAG)
else ifneq ($(GIT_COMMIT_SHORT),)
    GIT_VERSION := $(GIT_COMMIT_SHORT)
endif

ifneq ($(GIT_VERSION),)
    ifeq ($(GIT_STATUS),dirty)
        GIT_VERSION := $(GIT_VERSION)-dirty
    endif
endif

endif # ifndef cpb_git_mk
