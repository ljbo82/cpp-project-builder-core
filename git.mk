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

# Git repository support

ifndef git_mk
git_mk := 1

GIT_REPO_DIR ?= .
ifeq ($(GIT_REPO_DIR),)
    $(error [GIT_REPO_DIR] Missing value)
endif

ifneq ($(words $(GIT_REPO_DIR)),1)
    $(error [GIT_REPO_DIR] Value cannot have whitespaces: $(GIT_REPO_DIR))
endif

git_mk_repo_available := $(shell cd $(GIT_REPO_DIR) > /dev/null 2>&1; git status > /dev/null 2>&1 && echo y)
ifneq ($(git_mk_repo_available),)
    ifdef GIT_COMMIT
        $(error [GIT_COMMIT] Reserved variable)
    endif
    GIT_COMMIT := $(shell cd $(GIT_REPO_DIR) > /dev/null 2>&1; git rev-parse HEAD > /dev/null 2>&1 && echo y)
    ifneq ($(GIT_COMMIT),)
        GIT_COMMIT := $(shell cd $(GIT_REPO_DIR) > /dev/null 2>&1; git rev-parse HEAD)

        ifdef GIT_COMMIT_SHORT
            $(error [GIT_COMMIT_SHORT] Reserved variable)
        endif
        GIT_COMMIT_SHORT := $(shell cd $(GIT_REPO_DIR) > /dev/null 2>&1; git rev-parse --short HEAD)

        ifdef GIT_STATUS
            $(error [GIT_STATUS] Reserved variable)
        endif
        GIT_STATUS := $(shell cd $(GIT_REPO_DIR) > /dev/null 2>&1; git status -s)
        ifeq ($(GIT_STATUS),)
            GIT_STATUS := clean
        else
            GIT_STATUS := dirty
        endif

        ifdef GIT_TAG
            $(error [GIT_TAG] Reserved variable)
        endif
        GIT_TAG := $(shell cd $(GIT_REPO_DIR) > /dev/null 2>&1; git describe --tags > /dev/null 2>&1 && echo y)
        ifneq ($(GIT_TAG),)
            GIT_TAG := $(shell cd $(GIT_REPO_DIR) > /dev/null 2>&1; git describe --tags)
        else
            undefine GIT_TAG
        endif
    else
        undefine GIT_COMMIT
    endif
endif

ifdef GIT_VERSION
    $(error [GIT_VERSION] Reserved variable)
endif
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

undefine git_mk_repo_available

endif # ifndef git_mk
