module ITARocket_2DOF
include("base_def.jl")
include("input.jl")
include("output.jl")
include("rk4solve.jl")
using .Inputs, .Solver, .Outputs

export manual_input, read_project, read_cd, read_thrust, fullFlight
export text_output, height_time, height_horizontal, speed_time, accel_time

end
