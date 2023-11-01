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

# Common definitions

ifndef include_gcc_mk
include_gcc_mk := 1

# Allows passing additional compiler flags via command line --------------------
override undefine include_gcc_mk_tmp

include_gcc_mk_tmp := $(ASFLAGS)
override undefine ASFLAGS
ASFLAGS := $(include_gcc_mk_tmp)

include_gcc_mk_tmp := $(CFLAGS)
override undefine CFLAGS
CFLAGS := $(include_gcc_mk_tmp)

include_gcc_mk_tmp := $(CXXFLAGS)
override undefine CXXFLAGS
CXXFLAGS := $(include_gcc_mk_tmp)

override ARFLAGS := $(subst r,,$(subst c,,$(subst s,,$(subst v,,$(ARFLAGS)))))
include_gcc_mk_tmp := $(ARFLAGS)
override undefine ARFLAGS
ARFLAGS := $(include_gcc_mk_tmp)

include_gcc_mk_tmp := $(LDFLAGS)
override undefine LDFLAGS
LDFLAGS := $(include_gcc_mk_tmp)
# ------------------------------------------------------------------------------

endif # ifndef include_gcc_mk
