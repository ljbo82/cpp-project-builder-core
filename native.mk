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

# Native host detection

# Hosts with supported auto-detection:
#    linux-x86, linux-x64, linux-arm, linux-arm64,
#    windows-x86, windows-x64, windows-arm, windows-arm64

ifndef cpb_native_mk
cpb_native_mk := $(lastword $(MAKEFILE_LIST))

include $(dir $(cpb_native_mk))functions.mk

# Reserved variables -----------------------------------------------------------
$(call FN_CHECK_RESERVED,cpb_native_mk_os)
$(call FN_CHECK_RESERVED,cpb_native_mk_arch)
$(call FN_CHECK_RESERVED,NATIVE_OS)
$(call FN_CHECK_RESERVED,NATIVE_ARCH)
$(call FN_CHECK_RESERVED,NATIVE_HOST)
# ------------------------------------------------------------------------------

ifeq ($(OS),Windows_NT)
    NATIVE_OS := windows
else
    cpb_native_mk_os := $(call FN_SHELL,uname -s)
    ifneq ($(filter Linux linux,$(cpb_native_mk_os)),)
        NATIVE_OS := linux
    else
        ifneq ($(filter Darwin darwin, $(cpb_native_mk_os)),)
            NATIVE_OS := osx
        endif
    endif
endif

ifdef NATIVE_OS
    ifeq ($(NATIVE_OS),windows)
        cpb_native_mk_arch := $(call FN_SHELL,cmd /C SET Processor | grep PROCESSOR_ARCHITECTURE | sed 's:PROCESSOR_ARCHITECTURE=::')
        ifeq ($(cpb_native_mk_arch),AMD64)
            NATIVE_ARCH := x64
        else
            ifeq ($(cpb_native_mk_arch),x86)
                NATIVE_ARCH := x86
            else
                ifneq ($(cpb_native_mk_arch),ARM32)
                    NATIVE_ARCH := arm
                else
                    ifeq ($(cpb_native_mk_arch),ARM64)
                        NATIVE_ARCH := arm64
                    endif
                endif
            endif
        endif
    else
        cpb_native_mk_arch := $(call FN_SHELL,uname -m)
        ifeq ($(cpb_native_mk_arch),x86_64)
            NATIVE_ARCH := x64
        else
            ifneq ($(filter %86, $(cpb_native_mk_arch)),)
                NATIVE_ARCH := x86
            else
                ifneq ($(filter arm, $(cpb_native_mk_arch)),)
                    NATIVE_ARCH := arm
                else
                    ifneq ($(filter arm64, $(cpb_native_mk_arch)),)
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

VARS += NATIVE_OS NATIVE_ARCH NATIVE_HOST

endif # ifndef cpb_native_mk
