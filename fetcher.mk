include $(CPB_DIR)/include/common.mk

DOWNLOADS_DIR ?= $(O)/downloads

# Syntax $(call cpb_fn_checksum_test_cmd,1:checksum,2:file)
$(call fn_check_reserved,cpb_fn_checksum_test_cmd)
cpb_fn_checksum_test_cmd = $(if $(findstring =,$(1)),$(call fn_token,$(1),=,1),md5)sum -c <<< '$(call fn_token,$(1),=,1) $(2)'

# Syntax: $(call cpb_fn_download_cmd[https],1:uri,2:filename,[3:checksum])
$(call fn_check_reserved,cpb_fn_download_cmd[https])
cpb_fn_download_cmd[https] = wget $(1) $(strip $(if $(3),--no-check-certificate,) -O $(2))$(if $(3), && $(call cpb_fn_checksum_test_cmd,$(3),$(2)),) || rm $(2)

# Syntax: $(call cpb_fn_download_cmd[http],1:uri,2:filename,3:checksum)
$(call fn_check_reserved,cpb_fn_download_cmd[http])
cpb_fn_download_cmd[http] = wget $(1) -O $(2) && $(call cpb_fn_checksum_test_cmd,$(3),$(2)) || rm $(2)

# Syntax: $(call cpb_fn_download_cmd[git],1:uri,2:dirname,3:reference)
$(call fn_check_reserved,cpb_fn_download_cmd[git])
cpb_fn_download_cmd[git] = (cd $(2)  > /dev/null || (git clone $(1) -o $(2) --recursive && cd $(2))) && git checkout $(3) && git clean -dfx

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
        $$(if $$(findstring =,$$(SRC_URI[checksum])),$$(call fn_warning,[WARNING][SRC_URI] Specified checksum type for a git entry ('$(1)'). It will be ignored!),)
        SRC_URI[checksum_type] := git
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

# Download command associated with a file (will be used by recipe)
SRC_URI[$$(SRC_URI[file_or_dir]).download_cmd] := $$(call cpb_fn_download_cmd[$$(SRC_URI[scheme])],$$(SRC_URI[uri]),$$(DOWNLOADS_DIR)/$$(SRC_URI[file_or_dir]),$$(SRC_URI[checksum]))

# Checksum type associated with a file (will be used by recipe in non-git type)
ifneq ($$(SRC_URI[type]),git)
    # Example expansion: SRC_URI[abc.tar.gz.checksum_type] := md5
    SRC_URI[$$(SRC_URI[file_or_dir]).checksum_type] := $$(SRC_URI[checksum_type])
endif

# Checksum associated with a file (will be used by recipe in non-git type)
ifneq ($$(SRC_URI[type]),git)
    # Example expansion: SRC_URI[abc.tar.gz.md5.contents] := 0123456789abcdef abc.tar.gz
    SRC_URI[$$(SRC_URI[file_or_dir]).$$(SRC_URI[checksum_type]).contents] := $$(SRC_URI[checksum]) $$(SRC_URI[file_or_dir])
endif

$$(info $(call fn_text,$(1),93))
$$(info SRC_URI[uri]: $$(SRC_URI[uri]))
$$(info SRC_URI[scheme]: $$(SRC_URI[scheme]))
$$(info SRC_URI[checksum]: $$(SRC_URI[checksum]))
$$(info SRC_URI[checksum_type]: $$(SRC_URI[checksum_type]))
$$(info SRC_URI[file_or_dir]: $$(SRC_URI[file_or_dir]))
$$(info SRC_URI[type]: $$(SRC_URI[type]))
$$(info SRC_URI[$$(SRC_URI[file_or_dir]).checksum_type]: $$(SRC_URI[$$(SRC_URI[file_or_dir]).checksum_type]))
$$(info SRC_URI[$$(SRC_URI[file_or_dir]).download_cmd]: $$(SRC_URI[$$(SRC_URI[file_or_dir]).download_cmd]))
$$(info SRC_URI[$$(SRC_URI[file_or_dir]).$$(SRC_URI[checksum_type]).contents]: $$(SRC_URI[$$(SRC_URI[file_or_dir]).$$(SRC_URI[checksum_type]).contents]))
$$(info )

PRE_BUILD_DEPS := $$(PRE_BUILD_DEPS) $$(DOWNLOADS_DIR)/$$(SRC_URI[file_or_dir])

ifneq ($$(SRC_URI[type]),git)
# ==============================================================================
$$(DOWNLOADS_DIR)/$$(SRC_URI[file_or_dir]).$$(SRC_URI[checksum_type]): --force
#   HINTS:
#   1) Contents of $$@: $$(SRC_URI[$$(notdir $$@).contents]
	$$(call fn_log,$$@,1)
	$$(V_PREFIX)mkdir -p $$(dir $$@)
    # Example expansion: [ "$(cat downloads/abc.tar.gz.md5 2> /dev/null)" = "0123456789abcdef abc.tar.gz" ] || echo "0123456789abcdef abc.tar.gz" > downloads/abc.tar.gz.md5
	$$(V_PREFIX)[ "$$$$(cat $$@ 2> /dev/null)" = "$$(SRC_URI[$$(notdir $$@).contents])" ] || echo "$$(SRC_URI[$$(notdir $$@).contents])" > $$@
# ==============================================================================
endif

# ==============================================================================
$$(DOWNLOADS_DIR)/$$(SRC_URI[file_or_dir]): $$(if $$(call fn_eq,$$(SRC_URI[type]),git),--force,$$(DOWNLOADS_DIR)/$$(SRC_URI[file_or_dir]).$$(SRC_URI[checksum_type]))
#    HINTS:
#    1) Checksum file associated with $$@ : $$@.$$(SRC_URI[$$(notdir $$@).checksum_type])
#    2) Contents of checksum file associated with $$@: $$(SRC_URI[$$(notdir $$@).$$(SRC_URI[$$(notdir $$@).checksum_type]).contents])
#    3) Download command associated with $$@: $$(SRC_URI[$$(notdir $$@).download_cmd])
	@$$(call fn_log,$$@,1)
    ifneq ($$(SRC_URI[type]),git)
        # Example expansion: [ "$(cat downloads/abc.tar.gz.md5 2> /dev/null)" = "0123456789abcdef abc.tar.gz" ] || bash -c "wget...."
	    $$(V_PREFIX)[ "$$$$(cat $$@.$$(SRC_URI[$$(notdir $$@).checksum_type]))" = "$$(SRC_URI[$$(notdir $$@).$$(SRC_URI[$$(notdir $$@).checksum_type]).contents])" ] || bash -c "$$(SRC_URI[$$(notdir $$@).download_cmd])"
    else
	    $$(V_PREFIX)bash -c "$$(SRC_URI[$$(notdir $$@).download_cmd])"
    endif
# ==============================================================================
# ------------------------------------------------------------------------------
endef

$(foreach entry,$(SRC_URI),$(eval $(call SRC_URI[template],$(entry))))
