using Reactant, Test

const PJRT = Reactant.XLA.PJRT
const CAPI = PJRT.CAPI

@testset "PJRT C API bindings" begin
    # The generated struct must be exactly as large as the header says the table is.
    @test sizeof(CAPI.PJRT_Api) == Int(CAPI.PJRT_Api_STRUCT_SIZE)
    @test PJRT.bindings_pjrt_api_version() isa VersionNumber

    api = PJRT.get_pjrt_api()
    if api == C_NULL
        # Only the CUDA and ROCm builds of libReactantExtra export a PJRT C API table.
        @test PJRT.get_pjrt_api(:DoesNotExist) == C_NULL
    else
        # The table the library exports must be the one the bindings describe.
        @test unsafe_load(api.struct_size) == Csize_t(CAPI.PJRT_Api_STRUCT_SIZE)
        @test PJRT.pjrt_api_version(api) == PJRT.bindings_pjrt_api_version()
        @test PJRT.check_pjrt_api(api) === nothing
    end
end
