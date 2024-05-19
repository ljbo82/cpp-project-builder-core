include $(CPB_DIR)/include/common.mk

DOWNLOADS_DIR ?= $(O)/downloads

# Syntax: $(call cpb_fn_download_cmd[https],1:uri,2:filename)
$(call fn_check_reserved,cpb_fn_download_cmd[https])
cpb_fn_download_cmd[https] = wget $(1) $(strip $(if $(3),--no-check-certificate,) -O $(2))

# Syntax: $(call cpb_fn_download_cmd[http],1:uri,2:filename)
$(call fn_check_reserved,cpb_fn_download_cmd[http])
cpb_fn_download_cmd[http] = wget $(1) -O $(2)

$(call fn_check_reserved,SRC_URI[template])
$(call fn_check_reserved,SRC_URI[uri])
$(call fn_check_reserved,SRC_URI[scheme])
$(call fn_check_reserved,SRC_URI[checksum])
$(call fn_check_reserved,SRC_URI[checksum_type])
$(call fn_check_reserved,SRC_URI[file_or_dir])
$(call fn_check_reserved,SRC_URI[type])

# ==============================================================================
.PHONY: --force
--force:
# ==============================================================================

# Syntax $(call SRC_URI[template],uriEntry)
# uriEntry: <1:uri>;[2:checksum],[3:file_or_dir];[4:type]
define SRC_URI[template]
# ------------------------------------------------------------------------------
undefine SRC_URI[uri]
undefine SRC_URI[scheme]
undefine SRC_URI[checksum]
undefine SRC_URI[checksum_type]
undefine SRC_URI[file_or_dir]
undefine SRC_URI[type]

SRC_URI[uri] :=$$(call fn_token,$(1),;,1)
ifeq ($$(SRC_URI[uri]),)
    $$(call fn_error,[SRC_URI] Missing URI in entry '$(1)')
endif

SRC_URI[scheme] := $$(call fn_test_patterns,http://% https://% git://%,$$(SRC_URI[uri]),://%)
ifeq ($$(SRC_URI[scheme]),)
    $$(call fn_error,[SRC_URI] Unknown scheme in URI field ('$$(SRC_URI[uri])'))
endif

SRC_URI[checksum] := $$(call fn_token,$(1),;,2)
ifeq ($$(SRC_URI[checksum]),)
    $$(call fn_warning,[WARNING][SRC_URI] Checksum not informed in URI entry '$(1)'!)
else
    ifeq ($$(SRC_URI[scheme]),git)
        $$(if $$(findstring =,$$(SRC_URI[checksum])),$$(call fn_error,[SRC_URI] Specified checksum type for a git entry ('$(1)'). It will be ignored!),)
        SRC_URI[checksum_type] :=
    else
        SRC_URI[checksum_type] := $$(if $$(findstring =,$$(SRC_URI[checksum])),$$(call fn_token,$$(SRC_URI[checksum]),=,1),md5)
        ifeq ($$(call fn_test_patterns,md5 sha1 sha224 sha256 sha384 sha512,$$(SRC_URI[checksum_type])),)
            $$(call fn_error,[SRC_URI] Unknown checksum type ('$$(SRC_URI[checksum_type])'))
        endif
    endif
    SRC_URI[checksum] := $$(if $$(findstring =,$$(SRC_URI[checksum])),$$(call fn_token,$$(SRC_URI[checksum]),=,2),$$(SRC_URI[checksum]))
endif

SRC_URI[file_or_dir] := $$(call fn_token,$(1),;,3)
SRC_URI[file_or_dir] := $$(if $$(SRC_URI[file_or_dir]),$$(SRC_URI[file_or_dir]),$$(notdir $$(SRC_URI[uri])))
ifeq ($$(SRC_URI[file_or_dir]),)
    $$(call fn_error,[SRC_URI] Could not infer filename from URI field '$$(SRC_URI[uri]))'
else ifneq ($$(dir $$(SRC_URI[file_or_dir])),./)
    $$(call fn_error,[SRC_URI] No subdirectories are allowed in file_or_dir field ('$$(SRC_URI[file_or_dir])'))
endif

SRC_URI[type] := $$(call fn_token,$(1),;,4)
ifeq ($$(SRC_URI[type]),)
    ifeq ($$(SRC_URI[scheme]),git)
        SRC_URI[type] := git
    else
        SRC_URI[type] := $$(call fn_test_patterns,%.tar %.tar.bz2 %.tar.xz %.tar.gz %.git,$$(SRC_URI[file_or_dir]),%.)
        ifeq ($$(SRC_URI[type]),)
            $$(call fn_error,[SRC_URI] Could not infer type from URI field '$$(SRC_URI[uri])')
        endif
    endif
endif
ifeq ($$(call fn_test_patterns,tar tar.bz2 tar.xz tar.gz git custom none,$$(SRC_URI[type])),)
    $$(call fn_error,[SRC_URI] Unknown type ('$$(SRC_URI[type])'))
endif

ifeq ($$(SRC_URI[scheme]),git)
    ifeq ($$(call fn_test_patterns,git custom none,$$(SRC_URI[type])),)
        $$(call fn_error,[SRC_URI] Invalid type for git scheme ('$$(SRC_URI[type])'))
    endif
endif

# URI command associated with a file or dir
SRC_URI[$$(SRC_URI[file_or_dir]).uri] := $$(SRC_URI[uri])

# Checksum associated with a file or dir
SRC_URI[$$(SRC_URI[file_or_dir]).checksum] := $$(SRC_URI[checksum])

# Checksum info associated with a file (non-git recipes)
ifneq ($$(SRC_URI[scheme]),git)
    # Example expansion: SRC_URI[abc.tar.gz.checksum_type] := md5
    SRC_URI[$$(SRC_URI[file_or_dir]).checksum_type] := $$(SRC_URI[checksum_type])

    # Example expansion: SRC_URI[abc.tar.gz.md5.contents] := 0123456789abcdef abc.tar.gz
    SRC_URI[$$(SRC_URI[file_or_dir]).$$(SRC_URI[checksum_type]).contents] := $$(SRC_URI[checksum]) $$(SRC_URI[file_or_dir])

    # Download command associated with a file
    SRC_URI[$$(SRC_URI[file_or_dir]).download_cmd] := $$(call cpb_fn_download_cmd[$$(SRC_URI[scheme])],$$(SRC_URI[uri]),$$(DOWNLOADS_DIR)/$$(SRC_URI[file_or_dir]))
endif

# $$(info $(call fn_text,$(1),93))
# $$(info SRC_URI[uri]: $$(SRC_URI[uri]))
# $$(info SRC_URI[scheme]: $$(SRC_URI[scheme]))
# $$(info SRC_URI[checksum]: $$(SRC_URI[checksum]))
# $$(info SRC_URI[checksum_type]: $$(SRC_URI[checksum_type]))
# $$(info SRC_URI[file_or_dir]: $$(SRC_URI[file_or_dir]))
# $$(info SRC_URI[type]: $$(SRC_URI[type]))
# $$(info SRC_URI[$$(SRC_URI[file_or_dir]).checksum_type]: $$(SRC_URI[$$(SRC_URI[file_or_dir]).checksum_type]))
# $$(info SRC_URI[$$(SRC_URI[file_or_dir]).download_cmd]: $$(SRC_URI[$$(SRC_URI[file_or_dir]).download_cmd]))
# $$(info SRC_URI[$$(SRC_URI[file_or_dir]).$$(SRC_URI[checksum_type]).contents]: $$(SRC_URI[$$(SRC_URI[file_or_dir]).$$(SRC_URI[checksum_type]).contents]))
# $$(info )

PRE_BUILD_DEPS := $$(PRE_BUILD_DEPS) $$(DOWNLOADS_DIR)/$$(SRC_URI[file_or_dir])

# ==============================================================================
$$(DOWNLOADS_DIR)/$$(SRC_URI[file_or_dir]): --force
#    HINTS:
#    1) File associated with $$@: $$(notdir $$@)
#    2) Checksum type associated with $$@: $$(SRC_URI[$$(notdir $$@).checksum_type])
#    3) Checksum associated with $$@: $$(SRC_URI[$$(notdir $$@).checksum])
#    4) Checksum file associated with $$@ : $$@.$$(SRC_URI[$$(notdir $$@).checksum_type])
#    5) Contents of checksum file associated with $$@: $$(SRC_URI[$$(notdir $$@).$$(SRC_URI[$$(notdir $$@).checksum_type]).contents])
#    6) Download command associated with $$@: $$(SRC_URI[$$(notdir $$@).download_cmd])
#    7) URI associated with $$@: $$(SRC_URI[$$(notdir $$@).uri])

    ifneq ($$(SRC_URI[scheme]),git)
	    @mkdir -p $$(dir $$@)

        # Updates checksum file...
	    @$$(if $$(SRC_URI[$$(notdir $$@).checksum]),if [ "$$$$(cat $$@.$$(SRC_URI[$$(notdir $$@).checksum_type]) 2> /dev/null)" != "$$(SRC_URI[$$(notdir $$@).$$(SRC_URI[$$(notdir $$@).checksum_type]).contents])" ]; then echo "$$(SRC_URI[$$(notdir $$@).$$(SRC_URI[$$(notdir $$@).checksum_type]).contents])" > $$@.$$(SRC_URI[$$(notdir $$@).checksum_type]); fi,)

        # Downloads only if file does not exist or checksum changed...
	    @if [ ! -f $$@ ]$$(if $$(SRC_URI[$$(notdir $$@).checksum]), || [ "$$$$(cat $$@.$$(SRC_URI[$$(notdir $$@).checksum_type]))" != "$$(SRC_URI[$$(notdir $$@).$$(SRC_URI[$$(notdir $$@).checksum_type]).contents])" ],); then $$(call fn_log_cmd,[GET] $$(SRC_URI[$$(notdir $$@).uri]),$$(V)) && $$(SRC_URI[$$(notdir $$@).download_cmd]) || ($$(call fn_color_print_cmd,[SRC_URI] Download failure,91) && false); fi

        # Check if downloaded file checksum matches...
	    @$$(if $$(SRC_URI[$$(notdir $$@).checksum]),cd $$(dir $$@) && $$(subst .,,$$(suffix $$@.$$(SRC_URI[$$(notdir $$@).checksum_type])))sum -c $$(notdir $$@.$$(SRC_URI[$$(notdir $$@).checksum_type])) > /dev/null 2>&1 || ($$(call fn_color_print_cmd,[SRC_URI] Checksum failed for $$@,91) && false),)

        # Extract
        # TODO
    else
        # Clone repo only if directory does not exist...
	    @if [ ! -d $$@ ]; then $$(call fn_log_cmd,[GIT] $$(SRC_URI[$$(notdir $$@).uri]),$$(V)) && git clone $$(SRC_URI[$$(notdir $$@).uri]) $$@ --recursive || ($$(call fn_color_print_cmd,[SRC_URI] Failure cloning repository,91) && false); fi

        # Switching branches...
	    @$$(if $$(SRC_URI[$$(notdir $$@).checksum]),@cd $$@ && git checkout -q $$(SRC_URI[$$(notdir $$@).checksum]) && git clean -dfx && git submodule update || ($$(call fn_color_print_cmd,[SRC_URI] Failure switching branches,91) && false),)
    endif
# ==============================================================================
# ------------------------------------------------------------------------------
endef

$(foreach entry,$(SRC_URI),$(eval $(call SRC_URI[template],$(entry))))
