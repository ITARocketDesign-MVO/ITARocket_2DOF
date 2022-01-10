module Outputs
# módulo para obtenção de gráficos e parâmetros
include("ambient_conditions.jl")
using ..BaseDefinitions, Plots, .AmbientConditions
export text_output, height_time, height_horizontal, speed_time, accel_time


function text_output(res::SimResults, dt::Float64=0.1; project::String = ".")
    # Definição das variáveis pra ficar menos confuso
    max_vel = 0; apogee = 0; rail_exit_vel = 0; max_mach = 0;
    drogue_open_vel = 0; main_open_vel = 0; max_acc = 0;
    drogue_open_acc = 0; main_open_acc = 0;

    for phase in res.phases
        Xs = res[phase]
        for i in 1:(length(Xs) - 1)
            X = Xs[i]
            # Cálculo da velocidade e aceleração
            X_vel = vel_mod(X)
            #Vsom está errado!!
            X_mach = X_vel/Vsom(X.y)
            X_acc = vel_mod(Xs[i + 1] - X)/res.dt

            # Atribuição dos valores relevantes
            (X.y > apogee) && (apogee = X.y)
            (X_vel > max_vel) && (max_vel = X_vel)
            (X_acc > max_acc) && (max_acc = X_acc)
            (X_mach > max_mach) && (max_mach = X_mach)
        end

        # Atribuição de valores específicos de interesse
        (phase == "rail") && (rail_exit_vel = vel_mod(Xs[end]))
        (phase == "drogue") && (drogue_open_vel = vel_mod(Xs[1]);
                                drogue_open_acc = (vel_mod(Xs[2]) - vel_mod(Xs[1])) / res.dt)
        (phase == "main") && (main_open_vel = vel_mod(Xs[1]);
                                main_open_acc = (vel_mod(Xs[2]) - vel_mod(Xs[1])) / res.dt)
    
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
    open("$project/output.txt", "w") do io
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

function height_time(res::SimResults; project::String = ".")
    plot(0, 0)
    for (i, phase) in enumerate(res.phases)
            # Vetor de posição vertical
            height_vec = [X.y for X in res[phase]]
            # Plot de cada fase do voo
            plot!(range((i==1) ? 0 : res.phase_transition_times[i-1],
                            stop=res.phase_transition_times[i],
                            length=length(res[phase])), height_vec, lab="")
    end
    # Salvar em .png
    png("$project/height_time")
end

function height_horizontal(res::SimResults; project::String = ".")
    plot(0, 0)
    for phase in res.phases
        # Vetores de poição horizontal e vertical
        x_vec = [X.x for X in res[phase]]
        y_vec = [X.y for X in res[phase]]
        # Plot de cada fase do voo
        plot!(x_vec, y_vec, lab="")
    end
    # Salvar em .png
    png("$project/height_horizontal")
end

function speed_time(res::SimResults; project::String = ".")
    plot(0, 0)
    for (i, phase) in enumerate(res.phases)
        # Vetor de velocidade
        speed_vec = [vel_mod(X) for X in res[phase]]
        # Plot de cada fase do voo
        plot!(range((i==1) ? 0 : res.phase_transition_times[i-1],
                    stop=res.phase_transition_times[i],
                    length=length(res[phase])), speed_vec, lab="")
    end
    # Salvar em .png
    png("$project/speed_time")
end

function accel_time(res::SimResults; project::String = ".")
    plot(0, 0)
    for (j, phase) in enumerate(res.phases)
        # Vetor de velocidade
        accel_vec = Vector{Any}(undef, length(res[phase]))
        for i in 1:length(accel_vec)
            if i == 1 || i == length(accel_vec)
                accel_vec[i] = 0
            else
                accel_vec[i] = vel_mod(res.state_vector_list[i+1]-res.state_vector_list[i]) / res.dt
            end
        end
        # Plot de cada fase do voo
        if length(accel_vec) >0
            plot!(range( (j==1) ? 0 : res.phase_transition_times[j-1],
                            stop =res.phase_transition_times[j],
                            length =length(res[phase])), accel_vec, lab="")
        end
    end
    # Salvar em .png
    png("$project/accel_time")
end

function vel_mod(X::StateVector)
    sqrt(X.vx ^ 2 + X.vy ^ 2)
end

end
