module Outputs
# módulo para obtenção de gráficos e parâmetros
include("ambient_conditions.jl")
using ..BaseDefinitions, Plots, .AmbientConditions
export text_output, height_time, height_horizontal, speed_time, accel_time


function text_output(full_Flight::Dict{Any, Any}, dt::Float64=0.001)
    # Definição das variáveis pra ficar menos confuso
    max_vel = 0; apogee = 0; rail_exit_vel = 0; max_mach = 0;
    drogue_open_vel = 0; main_open_vel = 0; max_acc = 0;
    drogue_open_acc = 0; main_open_acc = 0;

    for phase in keys(full_Flight)
        Xs = full_Flight[phase][1]
        if phase != "end"
            for i in 1:(length(Xs) - 1)
                X = Xs[i]
                # Cálculo da velocidade e aceleração
                X_vel = vel_mod(X)
                X_mach = X_vel/Vsom(X.y)
                X_acc = (vel_mod(Xs[i + 1]) - vel_mod(X))/dt

                # Atribuição dos valores relevantes
                (X.y > apogee) && (apogee = X.y)
                (X_vel > max_vel) && (max_vel = X_vel)
                (X_acc > max_acc) && (max_acc = X_acc)
                (X_mach > max_mach) && (max_mach = X_mach)
            end

            # Atribuição de valores específicos de interesse
            (phase == "rail") && (rail_exit_vel = vel_mod(Xs[end]))
            (phase == "drogue") && (drogue_open_vel = vel_mod(Xs[1]);
                                    drogue_open_acc = (vel_mod(Xs[2]) - vel_mod(Xs[1])) / dt)
            (phase == "main") && (main_open_vel = vel_mod(Xs[1]);
                                  main_open_acc = (vel_mod(Xs[2]) - vel_mod(Xs[1])) / dt)
        end
    end

    # Apresentação no terminal
    println("max velocity: $max_vel \n", "apogee: $apogee \n",
            "max acceleration: $max_acc \n",
            "max mach number: $max_mach \n",
            "velocity on rail exit : $rail_exit_vel \n",
            "velocity on drogue opening: $drogue_open_vel \n",
            "acceleration on drogue opening: $drogue_open_acc \n",
            "velocity on main opening: $main_open_vel \n",
            "acceleration on main opening: $main_open_acc")

    # Apresentação em arquivo
    open("outputs/output.txt", "w") do io
        write(io, "max velocity: $max_vel \n", "apogee: $apogee \n")
        write(io, "max acceleration: $max_acc \n")
        write(io, "max mach number: $max_mach \n")
        write(io, "velocity on rail exit : $rail_exit_vel \n")
        write(io, "velocity on drogue opening: $drogue_open_vel \n")
        write(io, "acceleration on drogue opening: $drogue_open_acc \n")
        write(io, "velocity on main opening: $main_open_vel \n")
        write(io, "acceleration on main opening: $main_open_acc")
    end
end

function height_time(full_Flight::Dict{Any, Any}, dt::Float64=0.001)
    plot(0, 0)
    for phase in keys(full_Flight)
        if phase != "end"
            # Vetor de posição vertical
            height_vec = [X.y for X in full_Flight[phase][1]]
            # Plot de cada fase do voo
            plot!(range(full_Flight[phase][2],stop=full_Flight[phase][3],
                length=length(full_Flight[phase][1])), height_vec)
            # Tempo inicial da próxima fase
        end
        # Salvar em .png
    end
    png("outputs/height_time")
end

function height_horizontal(full_Flight::Dict{Any, Any})
    plot(0, 0)
    for phase in keys(full_Flight)
        if phase != "end"
            # Vetores de poição horizontal e vertical
            x_vec = [X.x for X in full_Flight[phase][1]]
            y_vec = [X.y for X in full_Flight[phase][1]]
            # Plot de cada fase do voo
            plot!(x_vec, y_vec)
        end
    end
    # Salvar em .png
    png("outputs/height_horizontal")
end

function speed_time(full_Flight::Dict{Any, Any}, dt::Float64=0.001)
    plot(0, 0)
    for phase in keys(full_Flight)
        if phase != "end"
            # Vetor de velocidade
            speed_vec = [vel_mod(X) for X in full_Flight[phase][1]]
            # Plot de cada fase do voo
            plot!(range(full_Flight[phase][2],stop=full_Flight[phase][3],
                length=length(full_Flight[phase][1])), speed_vec)
            # Tempo inicial da próxima fase
        end
    end
    # Salvar em .png
    png("outputs/speed_time")
end

function accel_time(full_Flight::Dict{Any, Any}, dt::Float64=0.001)
    plot(0, 0)
    for phase in keys(full_Flight)
        if phase != "end"
            # Vetor de velocidade
            accel_vec = Vector{Any}(undef, length(full_Flight[phase][1]))
            for i in 1:length(full_Flight[phase][1])
                if i == 1
                    accel_vec[i] = 0
                elseif i != length(full_Flight[phase][1])
                    accel_vec[i] = (vel_mod(full_Flight[phase][1][i+1])
                                - vel_mod(full_Flight[phase][1][i])) / dt
                else
                    accel_vec[i] = 0
                end
            end
            # Plot de cada fase do voo
            plot!(range(full_Flight[phase][2],stop=full_Flight[phase][3],
                length=length(full_Flight[phase][1])), accel_vec)
            # Tempo inicial da próxima fase
        end
    end
    # Salvar em .png
    png("outputs/accel_time")
end

function vel_mod(X::StateVector)
    sqrt(X.vx ^ 2 + X.vy ^ 2)
end

end
