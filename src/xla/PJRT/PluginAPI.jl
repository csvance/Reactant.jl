# Access to the PJRT C API function table that libReactantExtra exports, and a check that
# the generated bindings in `CAPI.jl` describe the same table.

"""
    get_pjrt_api(symbol::Symbol=:GetPjrtApi) -> Ptr{CAPI.PJRT_Api}

Return the PJRT C API function table that `libReactantExtra` exports under `symbol`, or
`C_NULL` if this build exports no such symbol. `GetPjrtApi` is the standard entry point and
is present in the CUDA and ROCm builds.
"""
function get_pjrt_api(symbol::Symbol=:GetPjrtApi)
    Reactant_jll.is_available() || return Ptr{CAPI.PJRT_Api}(C_NULL)
    fptr = Libdl.dlsym_e(Reactant_jll.libReactantExtra_handle, symbol)
    fptr == C_NULL && return Ptr{CAPI.PJRT_Api}(C_NULL)
    return ccall(fptr, Ptr{CAPI.PJRT_Api}, ())
end

"""
    pjrt_api_version(api::Ptr{CAPI.PJRT_Api}) -> VersionNumber

The `major.minor` PJRT C API version a function table reports about itself.
"""
function pjrt_api_version(api::Ptr{CAPI.PJRT_Api})
    @assert api != C_NULL "PJRT_Api table is null"
    version = unsafe_load(api.pjrt_api_version)
    return VersionNumber(version.major_version, version.minor_version)
end

"""
    bindings_pjrt_api_version() -> VersionNumber

The PJRT C API version the generated bindings in `CAPI.jl` were produced from.
"""
function bindings_pjrt_api_version()
    return VersionNumber(CAPI.PJRT_API_MAJOR, CAPI.PJRT_API_MINOR)
end

"""
    check_pjrt_api(api::Ptr{CAPI.PJRT_Api})

Throw if the function table `api` does not match the generated bindings: its `struct_size`
must equal `CAPI.PJRT_Api_STRUCT_SIZE` and its version must equal
[`bindings_pjrt_api_version`](@ref). A mismatch means the bindings were generated from a
different `pjrt_c_api.h` than the one the library was built with, and reading the table
through them would be unsafe.
"""
function check_pjrt_api(api::Ptr{CAPI.PJRT_Api})
    @assert api != C_NULL "PJRT_Api table is null"
    struct_size = unsafe_load(api.struct_size)
    expected_size = Csize_t(CAPI.PJRT_Api_STRUCT_SIZE)
    struct_size == expected_size || error(
        "PJRT_Api struct_size mismatch: the library reports $(struct_size) bytes but the \
         generated bindings expect $(expected_size) bytes. Regenerate `CAPI.jl` against the \
         `pjrt_c_api.h` of this Reactant_jll.",
    )
    version = pjrt_api_version(api)
    expected_version = bindings_pjrt_api_version()
    version == expected_version || error(
        "PJRT C API version mismatch: the library reports $(version) but the generated \
         bindings were produced from $(expected_version). Regenerate `CAPI.jl` against the \
         `pjrt_c_api.h` of this Reactant_jll.",
    )
    return nothing
end
