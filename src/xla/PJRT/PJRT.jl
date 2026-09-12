module PJRT

using ..Reactant: Reactant, MLIR
using ..XLA: XLA
using Reactant_jll: Reactant_jll

using Libdl: Libdl

include("Client.jl")
include("Device.jl")
include("Future.jl")
include("Buffer.jl")
include("AsyncBuffer.jl")
include("LoadedExecutable.jl")

# Generated bindings for the PJRT C API (`xla/pjrt/c/pjrt_c_api.h` and its extensions).
module CAPI
    include("CAPI.jl")
end

include("PluginAPI.jl")

end
