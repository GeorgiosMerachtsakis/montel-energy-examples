#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 24-Bus_Power_System_Step_4_Reverse_Market ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#~~~~~~~~~~~~~~~~~~~~~~~~~ Diamantis Almpantis(s212854) - Shahatphong Pechrak(s213062) - Erlend Thabiso Rømyhr(s212426) - Georgios Merahtsakis(s213520)~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Import packages
using JuMP
using HiGHS
using Printf
using DataFrames

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Declare Model

Step_4_1_Reverse_Market_24_Bus = Model(HiGHS.Optimizer)
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Declare Sets
Conventional_Generators = [1 2 3 4 5 6 7 8 9 10 11 12] # Conventional Generators that exist in the 24-Bus system
CG = length(Conventional_Generators)
Wind_Generators = [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24] # Wind Generators that exist in the 24-Bus system
WG = length(Wind_Generators)
Hours = [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24] # The hours that the demand and production of the system take place
T = length(Hours)
Demand_points = [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17] # The areas that generators will supply
DP = length(Demand_points)

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Declare Parameters
Total_Demand=[1775.835 1669.815 1590.3 1563.795 1563.795 1590.3 1961.37 2279.43 2517.975 2544.48 2544.48 2517.975 2517.975 2517.975 2464.965 2464.965 2623.995 2650.5 2650.5 2544.48 2411.955 2199.915 1934.865 1669.815] #Total hourly demand

R_up = [40 40 70 180 60 30 30 0 0 0 60 40] #upward reserve capacities

R_dw = [40 40 70 180 60 30 30 0 0 0 60 40] #downward reserve capacities

C_p_max = [152 152 350 591 60 155 155 400 400 300 310 350] #maximum capacities of each generator

C_up = [15 15 10 8 7 16 16 0 0 0 17 16] # upward reserve capacity cost

C_dw = [14 14 9 7 5 14 14 0 0 0 16 14] # downward reserve capacity cost

# Declare Variables
#~~~~~~~~~~~~~~~~~~

# Upward reverse capacity to be provided by conventional generation cg in hour t
@variable(Step_4_1_Reverse_Market_24_Bus, upw_reverse[1:T,1:CG] >= 0)

# # Downward reverse capacity to be provided by conventional generation cg in hour t
@variable(Step_4_1_Reverse_Market_24_Bus, down_reverse[1:T,1:CG] >=0)

# Declare Objective function - Minimize the cost of Reserve market
@objective(Step_4_1_Reverse_Market_24_Bus, Min,
    sum(C_up[cg]*upw_reverse[t,cg] +C_dw[cg]*down_reverse[t,cg] for t=1:T for cg=1:CG))
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Declare Constraints
# The upward power generated from convetional generators cg can not exceed their  maximum upward reserve capacities limits
@constraint(Step_4_1_Reverse_Market_24_Bus, reverse_up_max_generation[t=1:T, cg=1:CG],upw_reverse[t,cg] <= R_up[cg])

# The downward power generated from convetional generators cg can not exceed their  maximum downward reserve capacities limits
@constraint(Step_4_1_Reverse_Market_24_Bus, reverse_dw_min_generation[t=1:T, cg = 1:CG], down_reverse[t,cg] <= R_dw[cg])

# Total reserve capacity must not over total capacity
@constraint(Step_4_1_Reverse_Market_24_Bus, max_generation[t=1:T, cg=1:CG],upw_reverse[t,cg]+down_reverse[t,cg] <= C_p_max[cg] )

#Total upward reserve capacity 15%
@constraint(Step_4_1_Reverse_Market_24_Bus, upw_equality[t=1:T], sum(upw_reverse[t,:]) == (Total_Demand[t] * 0.15))

#Total Downward reserve capacity 10%
@constraint(Step_4_1_Reverse_Market_24_Bus, down_equality[t=1:T], sum(down_reverse[t,:]) == (Total_Demand[t] * 0.1))

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Solve Model
optimize!(Step_4_1_Reverse_Market_24_Bus)
println("")
println("Termination status: $(termination_status(Step_4_1_Reverse_Market_24_Bus))")
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Print Solutions
println("----------------------------------------------------");
if termination_status(Step_4_1_Reverse_Market_24_Bus) == MOI.OPTIMAL
    println("Minimized reserved cost(Optimal objective value): $(objective_value(Step_4_1_Reverse_Market_24_Bus))")

    println("-------------------------")

            println("\n")

            for t=1:T
                println("Upward reserved capacity price $t [USD/MWh]: $(dual.(upw_equality[t]))")
            end
            println("\n")

            for t=1:T
                println("Downward reserved capacity price $t [USD/MWh]: $(dual.(down_equality[t]))")
            end
            println("\n")

            for t=1:T
            println("Upward reserve in hour $t [MWh]:  $(sum(JuMP.value.(upw_reverse[t,:]))) [MW])")
            end
            println("\n")

            for t=1:T
            println("Down reserve in hour $t [MWh]:  $(sum(JuMP.value.(down_reverse[t,:]))) [MW])")
            end

else
    println("No optimal solution available")
end
