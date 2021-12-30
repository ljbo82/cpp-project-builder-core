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

# Native host detection

# Hosts with supported auto-detection:
#    linux-x86, linux-x64, linux-arm, linux-arm64,
#    windows-x86, windows-x64, windows-arm, windows-arm64

ifndef __native_host_mk__
__native_host_mk__ := 1

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
    __native_host_mk_os__ := $(shell uname -s)
    ifneq ($(filter Linux linux,$(__native_host_mk_os__)),)
        NATIVE_OS := linux
    else
        ifneq ($(filter Darwin darwin, $(__native_host_mk_os__)),)
            NATIVE_OS := osx
        endif
    endif
    undefine __native_host_mk_os__
endif


ifdef NATIVE_OS
    ifeq ($(NATIVE_OS),windows)
        __native_host_mk_arch__ := $(shell cmd /C SET Processor | grep PROCESSOR_ARCHITECTURE | sed 's:PROCESSOR_ARCHITECTURE=::')
        ifeq ($(__native_host_mk_arch__),AMD64)
            NATIVE_ARCH := x64
        else
            ifeq ($(__native_host_mk_arch__),x86)
                NATIVE_ARCH := x86
            else
                ifneq ($(__native_host_mk_arch__),ARM32)
                    NATIVE_ARCH := arm
                else
                    ifeq ($(__native_host_mk_arch__),ARM64)
                        NATIVE_ARCH := arm64
                    endif
                endif
            endif
        endif
    else
        __native_host_mk_arch__ := $(shell uname -m)
        ifeq ($(__native_host_mk_arch__),x86_64)
            NATIVE_ARCH := x64
        else
            ifneq ($(filter %86, $(__native_host_mk_arch__)),)
                NATIVE_ARCH := x86
            else
                ifneq ($(filter arm, $(__native_host_mk_arch__)),)
                    NATIVE_ARCH := arm
                else
                    ifneq ($(filter arm64, $(__native_host_mk_arch__)),)
                        NATIVE_ARCH := arm64
                    endif
                endif
            endif
        endif
    endif
    undefine __native_host_mk_arch__

    ifdef NATIVE_ARCH
        NATIVE_HOST := $(NATIVE_OS)-$(NATIVE_ARCH)
    else
        NATIVE_HOST := $(NATIVE_OS)
    endif
endif

endif # ifndef __native_host_mk__
