#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 24-Bus_Power_System_Step_2_Nodal ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#~~~~~~~~~~~~~~~~~~~~~~~~~ Diamantis Almpantis(s212854) - Shahatphong Pechrak(s213062) - Erlend Thabiso Rømyhr(s212426) - Georgios Merahtsakis(s213520)~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Import packages
using JuMP
using HiGHS
using Printf
using DataFrames

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Declare Model

Step_2_24_Bus_Nodal = Model(HiGHS.Optimizer)
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Declare Sets
Conventional_Generators = [1 2 3 4 5 6 7 8 9 10 11 12] # Conventional Generators that exist in the 24-Bus system
CG = length(Conventional_Generators)
Wind_Generators = [1 2 3 4 5 6] # Wind Generators that exist in the 24-Bus system
WG = length(Wind_Generators)
Nodes = collect(1:24) # Nodes in our 24 Bus Power System
N = length(Nodes)
Conventional_Gen_Nodes = [1 2 7 13 15 15 16 18 21 22 23 23] # Conventional Generators location on nodes
Conventional_Gen_Nodes2 = [1 2 7 13 15 15 16 18 21 22 23 23 0 0 0 0 0 0 0 0 0 0 0 0 ] # Conventional Generators location on nodes
Wind_Gen_Nodes = [3 16 21 23 5 7] # Wind Generator location on nodes
Wind_Gen_Nodes2 = [3 16 21 23 5 7 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 ] # Wind Generator location on nodes
Hours = [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24] # The hours that the demand and production of the system take place
T = length(Hours)
Demand_points = [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17] # The areas that generators will supply
DP = length(Demand_points)
Demand_points_nodes = [1 2 3 4 5 6 7 8 9 10 13 14 15 16 18 19 20] # Demand points connected with nodes
Demand_points_nodes2 = [1 2 3 4 5 6 7 8 9 10 13 14 15 16 18 19 20 0 0 0 0 0 0 0 ] # Demand points connected with nodes
Batteries = [1 2 3 4 5 6] # The batteries that are available in our system
B = length(Batteries)
Batteries_Nodes = [3 5 7 16 21 23] # The nodes that batterie b is connected
Batteries_Nodes2 = [3 5 7 16 21 23 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 ] # The nodes that batterie b is connected

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Mapping
# Node with node that reveal the capacity of transmission lines
Transmission_lines =
[0	175	175	0	350	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0
175	0	0	175	0	175	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0
175	0	0	0	0	0	0	0	175	0	0	0	0	0	0	0	0	0	0	0	0	0	0	400
0	175	0	0	0	0	0	0	175	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0
350	0	0	0	0	0	0	0	0	350	0	0	0	0	0	0	0	0	0	0	0	0	0	0
0	175	0	0	0	0	0	0	0	175	0	0	0	0	0	0	0	0	0	0	0	0	0	0
0	0	0	0	0	0	0	350	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0
0	0	0	0	0	0	350	0	175	175	0	0	0	0	0	0	0	0	0	0	0	0	0	0
0	0	175	175	0	0	0	175	0	0	400	400	0	0	0	0	0	0	0	0	0	0	0	0
0	0	0	0	350	170	0	175	0	0	400	400	0	0	0	0	0	0	0	0	0	0	0	0
0	0	0	0	0	0	0	0	400	400	0	0	500	500	0	0	0	0	0	0	0	0	0	0
0	0	0	0	0	0	0	0	400	400	0	0	500	0	0	0	0	0	0	0	0	0	500	0
0	0	0	0	0	0	0	0	0	0	500	500	0	0	0	0	0	0	0	0	0	0	250	0
0	0	0	0	0	0	0	0	0	0	500	0	0	0	0	250	0	0	0	0	0	0	0	0
0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	500	0	0	0	0	400	0	0	500
0	0	0	0	0	0	0	0	0	0	0	0	0	250	500	0	500	0	500	0	0	0	0	0
0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	500	0	500	0	0	0	500	0	0
0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	500	0	0	0	1000	0	0	0
0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	500	0	0	0	1000	0	0	0	0
0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1000	0	0	0	1000	0
0	0	0	0	0	0	0	0	0	0	0	0	0	0	400	0	0	1000	0	0	0	500	0	0
0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	500	0	0	0	500	0	0	0
0	0	0	0	0	0	0	0	0	0	0	500	250	0	0	0	0	0	0	1000	0	0	0	0
0	0	400	0	0	0	0	0	0	0	0	0	0	0	500	0	0	0	0	0	0	0	0	0
]

Wind_Mapping = zeros(length(Nodes),length(Wind_Generators))
    for n in Nodes
        for g in 1:WG
            if Wind_Gen_Nodes[g]==n
                Wind_Mapping[n,g]=1
            else
                Wind_Mapping[n,g]=0
            end
        end
    end

Conventional_Mapping = zeros(length(Nodes),length(Conventional_Generators))
    for n in Nodes
        for g in 1:CG
            if Conventional_Gen_Nodes[g]==n
                Conventional_Mapping[n,g]=1
            else
                Conventional_Mapping[n,g]=0
            end
        end
    end

Battery_Mapping = zeros(length(Nodes),length(Batteries))
    for n in Nodes
        for g in 1:B
            if Batteries_Nodes[g]==n
                Battery_Mapping[n,g]=1
            else
                Battery_Mapping[n,g]=0
            end
        end
    end

Demand_Point_Mapping = zeros(length(Nodes),length(Demand_points))
    for n in Nodes
        for g in 1:DP
            if Demand_points_nodes[g]==n
                Demand_Point_Mapping[n,g]=1
            else
                Demand_Point_Mapping[n,g]=0
            end
        end
    end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Declare Parameters
Total_Demand =
[
1775.835
1669.815
1590.3
1563.795
1563.795
1590.3
1961.37
2279.43
2517.975
2544.48
2544.48
2517.975
2517.975
2517.975
2464.965
2464.965
2623.995
2650.5
2650.5
2544.48
2411.955
2199.915
1934.865
1669.815
] #Total hourly demand

Demand_Breakdown = [0.038	0.034	0.063	0.026	0.025	0.048	0.044	0.06	0.061	0.068	0.093	0.068	0.111	0.035	0.117	0.064	0.045]
#Hourly demand breakdown

Demand = zeros(T,DP)
    for t=1:T
        for dp=1:DP
            Demand[t,dp] = Demand_Breakdown[dp] * Total_Demand[t]
        end
    end
Demand



#= Wind parks are situated:
Wind park 1 --> node 3, zone 10
Wind park 2 --> node 5, zone 5
Wind park 3 --> node 7, zone 1
Wind park 4 --> node 16, zone 4
Wind park 5 --> node 21, zone 12
Wind park 6 --> node 23, zone 15 =#

W_p =
[
113.76	124.06	105.85	89.77	99.26	97.28;
119.83	131.60	118.54	102.79	109.48	104.93;
123.97	136.02	136.00	119.70	120.02	116.03;
129.52	134.22	147.67	130.97	127.84	124.43;
127.41	132.79	153.35	137.56	130.26	126.33;
126.51	134.04	154.79	138.19	131.40	125.30;
125.03	136.69	155.74	138.16	133.54	125.13;
125.44	135.92	157.22	136.34	131.06	121.87;
125.00	136.07	155.57	130.90	129.35	122.18;
131.21	137.52	154.26	130.18	131.85	133.36;
132.82	140.31	149.86	129.77	133.43	138.41;
129.24	140.15	140.65	127.10	133.26	134.69;
123.25	137.37	134.44	125.83	130.07	128.22;
119.55	137.10	130.41	121.53	125.37	122.50;
119.73	142.00	127.36	122.73	122.71	118.86;
126.58	142.00	129.23	128.61	123.20	124.30;
131.36	141.99	127.02	126.72	132.00	130.51;
139.88	142.67	127.16	123.98	138.89	131.95;
142.88	144.88	131.63	124.68	143.98	131.60;
139.75	145.50	134.49	127.52	142.38	129.16;
134.56	144.31	136.05	130.07	137.10	126.15;
131.10	143.24	140.69	136.27	136.97	126.65;
127.43	136.75	136.66	134.41	133.05	126.66;
124.82	131.52	137.92	130.44	129.78	127.01
] # Forecasted production in MW of wind parks wg in hours t according to their factors (https://sites.google.com/site/datasmopf/wind-scenarios)


C_p_min = [0 0 0 0 0 0 0 0 0 0 0 0] # The minimum power that can be generated in MW from Conventioan generator cg per hour t

C_p_max = [152 152 350 591 60 155 155 400 400 300 310 350] # The maximum power that can be generated in MW from Conventional generator cg per hour t

Ramp_up = [120 120 350 240 60 155 155 280 280 300 180 240] # The maximum increase in MWh that can be done from the previous hour in each Conventional generator cg per hour t

Ramp_down = [120 120 350 240 60 155 155 280 280 300 180 240] # The maximum decrease in MWh that can be done from the previous hour in each Conventional generator cg in hour t

Initial_State = [76 76 0 0 0 0 124 240 240 240 248 280] # Initial power output of generating convetional cg when t=0

Cost_cg = [13.32 13.32 20.7 20.93 26.11 10.52 10.52 6.02 5.47 0 10.52 10.89] # Cost of generated power in $ per MWh for conventional cg for all hours

Cost_wg = [0 0 0 0 0 0] # Cost of generated power in $ per MWh for wind park wg in hour t

Bid_price = [20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20] # Bid price of demand point dp in all hours

Cost_Battery = 0 # Bid price of Battery
# Storage
battery_capacity = 100  # maximum storage capacity for each unit total 6 units
cap_storage_min = -25 # maximum amount of energy that can be taken out from a battery per time step for each unit total 6 units
cap_storage_max = 25 # maximum amount of energy that can be put in in a battery per time step for each unit total 6 units
eta_storage = 0.98 # charging and disharging efficiency of the batteries
Susceptance = 500 # Susceptance of line connecting node n to node m
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Declare Variables
#~~~~~~~~~~~~~~~~~~
# The positive amount of power in MW generated from conventiotal cg in hour t
@variable(Step_2_24_Bus_Nodal, p_g[1:T,1:CG] >= 0)

# The positive amount of power generated in MW from wind park wg in hour t
@variable(Step_2_24_Bus_Nodal, w_g[1:T,1:WG] >= 0)

# The amount of power generated for the demand of demand point dp in hour t
@variable(Step_2_24_Bus_Nodal, p_d[1:T,1:DP] >= 0)

# The amount of power that charging the battery in hour t
@variable(Step_2_24_Bus_Nodal, p_b[1:T,1:DP])

# The state of charge of the battery in hour t
@variable(Step_2_24_Bus_Nodal, Eb_s[1:T,1:B] >= 0)

# The voltage ange at node n which is theta n minus theta m
@variable(Step_2_24_Bus_Nodal, theta[1:T,1:N,1:N])

# Power flow from node n to node m
@variable(Step_2_24_Bus_Nodal, Power_flow[1:T,1:N,1:N])
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Declare Objective function - Maximize the Social Welfare
@objective(Step_2_24_Bus_Nodal, Max,
    sum(Bid_price[dp]*p_d[t,dp] for t=1:T for dp=1:DP) -
    sum(Cost_cg[cg]*p_g[t,cg] for t=1:T for cg=1:CG) -
    sum(Cost_wg[wg]*w_g[t,wg] for t=1:T for wg=1:WG) + sum(Cost_Battery*p_b[t,b] for t=1:T for b=1:B))
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Declare Constraints

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Conventional Generators' Constraints~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# The power generated from convetional generators cg can not exceed their  maximum capacity generation limit
@constraint(Step_2_24_Bus_Nodal, conventional_max_generation[t=1:T, cg=1:CG], p_g[t,cg] <= C_p_max[cg])

# The power generated from convetional generators cg must be equal or more that their minimum capacity generation limid
@constraint(Step_2_24_Bus_Nodal, conventional_min_generation[t=1:T, cg = 1:CG], p_g[t,cg] >= C_p_min[cg])

# Ramp up constraint for the power generated from conventional generators cg in time t minus the power generated in previous hour t-1 can not exceed ramp up limits
@constraint(Step_2_24_Bus_Nodal, ramp_up[t=2:T, cg = 1:CG], p_g[t,cg] - p_g[t-1,cg] <= Ramp_up[cg])

# Ramp down constraint for the power generated from conventional generators cg in time t minus the power generated in previous hour t-1 can not exceed ramp down limits
@constraint(Step_2_24_Bus_Nodal, ramp_down[t=2:T, cg = 1:CG], p_g[t,cg] - p_g[t-1,cg] >= -Ramp_down[cg])

# Ramp up constraint for the power generated from conventional generators cg in time t=1 minus the initial charge of conventional generator in t=0 can not exceed ramp up limits
@constraint(Step_2_24_Bus_Nodal, ramp_up_initial[t = 1, cg = 1:CG], p_g[cg,t]-Initial_State[cg] <= Ramp_up[cg])

# Ramp down constraint for the power generated from conventional generators cg in time t=1 minus the initial charge of conventional generator in t=0 can not exceed ramp down limits
@constraint(Step_2_24_Bus_Nodal, ramp_down_initial[t = 1, cg = 1:CG], p_g[cg,t]-Initial_State[cg] >= -Ramp_down[cg])

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Renewable Generators' Constraints~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# The power generated from wind parks wg can not exceed their maximum capacity generation limit
@constraint(Step_2_24_Bus_Nodal, wind_park_generation[t = 1:T, wg = 1:WG], w_g[t,wg] <= W_p[t,wg])

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Demand Points' Constraints~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# The power generated from all generators in hour t can not exceed the load of demand points DP
@constraint(Step_2_24_Bus_Nodal, generation_demand_points[t = 1:T, dp = 1:DP], p_d[t,dp] <= Demand[t,dp])

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Battieries' Constraints~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

@constraint(Step_2_24_Bus_Nodal, power_battery[b=1:B], Eb_s[1,b] == eta_storage * p_b[1,b]) # Power charged in battery in first time step t=1 equals to zero

@constraint(Step_2_24_Bus_Nodal, power_of_battery[t=2:T,b=1:B], Eb_s[t,b] == Eb_s[t-1,b] + eta_storage * p_b[t,b]) # State of charge equality

@constraint(Step_2_24_Bus_Nodal, limits_of_battery_Up[t=1:T,b=1:B], p_b[t,b] <= cap_storage_max) # Upper bound limit of battery charge

@constraint(Step_2_24_Bus_Nodal, limits_of_battery_Low[t=1:T,b=1:B], p_b[t,b] >= cap_storage_min) # Lower bound limit of battery charge

@constraint(Step_2_24_Bus_Nodal, max_energy_stored[t=1:T,b=1:B], Eb_s[t,b] <= battery_capacity) # Maximum potential energy stored in battery can not exceed battery's capacity

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Balance Equation Constraints~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Balance constraint
@constraint(Step_2_24_Bus_Nodal, balance_equation[t=1:T,k=1:24],sum( Conventional_Gen_Nodes2[m] == k ? p_g[t,m] : 0 for m=1:24)
                                                 + sum( Wind_Gen_Nodes2[j] == k ? w_g[t,j] : 0 for j=1:24) - sum( Demand_points_nodes2[l] == k ? p_d[t,l] : 0 for l=1:24) - sum( Batteries_Nodes2[a] == k ? p_d[t,a] : 0 for a=1:24)  - sum(Power_flow[t,k,m] for m=1:N) ==0)

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Network Constraints~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# Power flow equality
@constraint(Step_2_24_Bus_Nodal, transmission_flow[t=1:T,n=1:N,m=1:N], Power_flow[t,n,m] == Susceptance*(theta[t,n,m] - theta[t,m,n]))

# Maximum flow that can be achieved from node n to node m
@constraint(Step_2_24_Bus_Nodal, flow_limits_up[t=1:T,n=1:N,m=1:N], Power_flow[t,n,m] <= Transmission_lines[n,m])

# Minimum flow that can be achieved from node n to node m
@constraint(Step_2_24_Bus_Nodal, flow_limits_down[t=1:T,n=1:N,m=1:N], Power_flow[t,n,m] >= -Transmission_lines[n,m])

# Transmission Constraints
@constraint(Step_2_24_Bus_Nodal, theta_refference[t=1:T], theta[t,1,1] == 0) # Difference of voltage angles in time step 1 is equal to zero

@constraint(Step_2_24_Bus_Nodal, force_flow[t=1:T,n=1:N,m=1:N], Susceptance*(theta[t,n,m] - theta[t,m,n]) >= -Transmission_lines[n,m])

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Solve Model
optimize!(Step_2_24_Bus_Nodal)

Total_Flow = zeros(length(Hours),length(Nodes),length(Nodes))
 for t in Hours
    for n in Nodes
        for m in Nodes
            Total_Flow[t,n,m]=JuMP.value(Power_flow[t,n,m])
            end
        end
    end
println("\n")
println("")
println("Termination status: $(termination_status(Step_2_24_Bus_Nodal))")
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Print Solutions
println("----------------------------------------------------");
if termination_status(Step_2_24_Bus_Nodal) == MOI.OPTIMAL
    println("Maximum Social Welfare(Optimal objective value): $(objective_value(Step_2_24_Bus_Nodal))")

    println("-------------------------")

            println("\n")

            for t=1:T
                println("\n")
                println("Hour $t")

                for b=1:B
                println("Power to/from Battery $b in hour $t [MWh]: $(JuMP.value.(p_b[t,b])) ")
                println("Energy stored in battery $b in hour $t [MW]: $(JuMP.value.(Eb_s[t,b])) ")
                end

                print("Demand covered in hour $t [MWh]: Demand[MWh]: $(sum(JuMP.value.(p_d[t,:]))) (out of total: $(sum(Demand[t,:]))[MWh]) -> Breakdown: Conventional: $(sum(JuMP.value.(p_g[t,:]))) (out of total: $(sum(C_p_max[:]))[MWh]), Wind: $(sum(JuMP.value.(w_g[t,:]))) (out of total: $(sum(W_p[t,:]))[MWh])")
                println("\n")

                for wg = 1:WG
                println("Contribution of wind generator No.$wg: $(round(JuMP.value.(w_g[t,wg]), digits =3))[MWh] out of forecasted potential: $(W_p[t,wg])[MWh] <- (with offer price: $(Cost_wg[wg]))")
                end

                for cg = 1:CG
                println("Contribution of conventional generator No.$cg: $(round(JuMP.value.(p_g[t,cg]), digits =3))[MWh] out of max potential: $(C_p_max[cg])[MWh] <- (with offer price: $(Cost_cg[cg]))")
                end
            end

            #Print out dual variable values
                   println("\n")
                   println("Dual values:")
                   println("\n")
                   # for t=1:T
                   #     println("Market Clearing Price in hour $t [USD/MWh]: $(-dual.(balance_equation[t]))")
                   # end
                   for n=1:N
                       println("\n")

                       for t=1:T
                       println("Market Clearing Price in hour $t [USD/MWh], node $n: $(dual.(balance_equation[t,n]))")
                        end
                    end

                   for t=1:T
                       println("Demand covered in hour $t [MWh]: Demand[MWh]: $(sum(JuMP.value.(p_d[t,:]))) (out of total: $(sum(Demand[t,:]))[MWh])")
                   end

else
    println("No optimal solution available")
end
