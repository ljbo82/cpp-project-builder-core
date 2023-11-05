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

# Native host detection

# Hosts with supported auto-detection:
#    linux-x86, linux-x64, linux-arm, linux-arm64,
#    windows-x86, windows-x64, windows-arm, windows-arm64

ifndef include_native_mk
include_native_mk := 1

override undefine include_native_mk_os
override undefine include_native_mk_arch

ifdef NATIVE_OS
    $(error [NATIVE_OS] Reserved variable)
endif
ifdef NATIVE_ARCH
    $(error [NATIVE_ARCH] Reserved variable)
endif
ifdef NATIVE_HOST
    $(error [NATIVE_HOST] Reserved variable)
endif

ifeq ($(OS),Windows_NT)
    NATIVE_OS := windows
else
    include_native_mk_os := $(shell uname -s)
    ifneq ($(filter Linux linux,$(include_native_mk_os)),)
        NATIVE_OS := linux
    else
        ifneq ($(filter Darwin darwin, $(include_native_mk_os)),)
            NATIVE_OS := osx
        endif
    endif
endif

ifdef NATIVE_OS
    ifeq ($(NATIVE_OS),windows)
        include_native_mk_arch := $(shell cmd /C SET Processor | grep PROCESSOR_ARCHITECTURE | sed 's:PROCESSOR_ARCHITECTURE=::')
        ifeq ($(include_native_mk_arch),AMD64)
            NATIVE_ARCH := x64
        else
            ifeq ($(include_native_mk_arch),x86)
                NATIVE_ARCH := x86
            else
                ifneq ($(include_native_mk_arch),ARM32)
                    NATIVE_ARCH := arm
                else
                    ifeq ($(include_native_mk_arch),ARM64)
                        NATIVE_ARCH := arm64
                    endif
                endif
            endif
        endif
    else
        include_native_mk_arch := $(shell uname -m)
        ifeq ($(include_native_mk_arch),x86_64)
            NATIVE_ARCH := x64
        else
            ifneq ($(filter %86, $(include_native_mk_arch)),)
                NATIVE_ARCH := x86
            else
                ifneq ($(filter arm, $(include_native_mk_arch)),)
                    NATIVE_ARCH := arm
                else
                    ifneq ($(filter arm64, $(include_native_mk_arch)),)
                        NATIVE_ARCH := arm64
                    endif
                endif
            endif
        endif
    endif

    ifdef NATIVE_ARCH
        NATIVE_HOST := $(NATIVE_OS)-$(NATIVE_ARCH)
    else
        NATIVE_HOST := $(NATIVE_OS)
    endif
endif

endif # ifndef include_native_mk
