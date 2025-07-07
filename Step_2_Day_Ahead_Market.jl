#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 24-Bus_Power_System_Step_4_Day_Ahead_Market ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#~~~~~~~~~~~~~~~~~~~~~~~~~ Diamantis Almpantis(s212854) - Shahatphong Pechrak(s213062) - Erlend Thabiso Rømyhr(s212426) - Georgios Merahtsakis(s213520)~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Import packages
using JuMP
using HiGHS
using Printf
using DataFrames

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Declare Model

Step_4_Day_Ahead_Market = Model(HiGHS.Optimizer)
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Declare Sets
Conventional_Generators = [1 2 3 4 5 6 7 8 9 10 11 12] # Conventional Generators that exist in the 24-Bus system
CG = length(Conventional_Generators)
Wind_Generators = [1 2 3 4 5 6] # Wind Generators that exist in the 24-Bus system
WG = length(Wind_Generators)
Hours = [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24] # The hours that the demand and production of the system take place
T = length(Hours)
Demand_points = [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17] # The areas that generators will supply
DP = length(Demand_points)
Nodes=[1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24]
Bus = length(Nodes)


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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

# Demand =
# [
# 67.48173	60.37839	111.877605	46.17171	44.395875	85.24008	78.13674	106.5501	108.325935	120.75678	165.152655	120.75678	197.117685	62.154225	207.772695	113.65344	79.912575;
# 63.45297	56.77371	105.198345	43.41519	41.745375	80.15112	73.47186	100.1889	101.858715	113.54742	155.292795	113.54742	185.349465	58.443525	195.368355	106.86816	75.141675;
# 60.4314	    54.0702	    100.1889	41.3478	    39.7575	    76.3344	    69.9732	    95.418	    97.0083	    108.1404	147.8979	108.1404	176.5233	55.6605	    186.0651	101.7792	71.5635;
# 59.42421	53.16903	98.519085	40.65867	39.094875	75.06216	68.80698	93.8277	    95.391495	106.33806	145.432935	106.33806	173.581245	54.732825	182.964015	100.08288	70.370775;
# 59.42421	53.16903	98.519085	40.65867	39.094875	75.06216	68.80698	93.8277	    95.391495	106.33806	145.432935	106.33806	173.581245	54.732825	182.964015	100.08288	70.370775;
# 60.4314	    54.0702	    100.1889	41.3478	    39.7575	    76.3344	    69.9732	    95.418	    97.0083	    108.1404	147.8979	108.1404	176.5233	55.6605	    186.0651	101.7792	71.5635;
# 74.53206	66.68658	123.56631	50.99562	49.03425	94.14576	86.30028	117.6822	119.64357	133.37316	182.40741	133.37316	217.71207	68.64795	229.48029	125.52768	88.26165;
# 86.61834	77.50062	143.60409	59.26518	56.98575	109.41264	100.29492	136.7658	139.04523	155.00124	211.98699	155.00124	253.01673	79.78005	266.69331	145.88352	102.57435;
# 95.68305	85.61115	158.632425	65.46735	62.949375	120.8628	110.7909	151.0785	153.596475	171.2223	234.171675	171.2223	279.495225	88.129125	294.603075	161.1504	113.308875;
# 96.69024	86.51232	160.30224	66.15648	63.612	    278398.2742	111.95712	152.6688	155.21328	173.02464	236.63664	173.02464	282.43728	89.0568	    297.70416	162.84672	114.5016;
# 96.69024	86.51232	160.30224	166580.3627	63.612	    122.13504	111.95712	152.6688	155.21328	173.02464	236.63664	173.02464	282.43728	89.0568	    297.70416	162.84672	114.5016;
# 95.68305	85.61115	158.632425	65.46735	62.949375	120.8628	110.7909	151.0785	153.596475	171.2223	234.171675	171.2223	279.495225	88.129125	294.603075	161.1504	113.308875;
# 95.68305	85.61115	158.632425	65.46735	62.949375	120.8628	110.7909	151.0785	153.596475	171.2223	234.171675	171.2223	279.495225	88.129125	294.603075	161.1504	113.308875;
# 95.68305	85.61115	158.632425	65.46735	62.949375	120.8628	110.7909	151.0785	153.596475	171.2223	589638.4234	171.2223	279.495225	88.129125	294.603075	161.1504	113.308875;
# 93.66867	83.80881	155.292795	64.08909	61.624125	118.31832	108.45846	147.8979	150.362865	167.61762	229.241745	167.61762	273.611115	86.273775	288.400905	157.75776	110.923425;
# 93.66867	83.80881	155.292795	64.08909	61.624125	118.31832	108.45846	147.8979	150.362865	167.61762	229.241745	167.61762	273.611115	86.273775	288.400905	157.75776	110.923425;
# 99.71181	89.21583	165.311685	68.22387	65.599875	125.95176	115.45578	157.4397	160.063695	178.43166	244.031535	178.43166	291.263445	91.839825	307.007415	167.93568	118.079775;
# 100.719	    90.117	    166.9815	68.913	    66.2625	    127.224	    116.622	    159.03	    161.6805	180.234	    246.4965	180.234	    294.2055	92.7675	    310.1085	169.632	    119.2725;
# 100.719	    90.117	    166.9815	68.913	    66.2625	    127.224	    116.622	    159.03	    161.6805	180.234	    246.4965	180.234	    294.2055	92.7675	    310.1085	169.632	    119.2725;
# 96.69024	86.51232	160.30224	66.15648	63.612	    122.13504	111.95712	152.6688	155.21328	173.02464	236.63664	173.02464	282.43728	89.0568	    297.70416	162.84672	114.5016;
# 91.65429	82.00647	151.953165	62.71083	60.298875	115.77384	106.12602	144.7173	147.129255	164.01294	224.311815	164.01294	267.727005	84.418425	282.198735	154.36512	108.537975;
# 83.59677	74.79711	138.594645	57.19779	54.997875	105.59592	96.79626	131.9949	134.194815	149.59422	204.592095	149.59422	244.190565	76.997025	257.390055	140.79456	98.996175;
# 73.52487	65.78541	121.896495	50.30649	48.371625	92.87352	85.13406	116.0919	118.026765	131.57082	179.942445	131.57082	214.770015	67.720275	226.379205	123.83136	87.068925;
# 63.45297	56.77371	105.198345	43.41519	41.745375	80.15112	73.47186	100.1889	101.858715	113.54742	155.292795	113.54742	185.349465	58.443525	195.368355	106.86816	75.141675
# ] # The demand of MW in Demand points dp for every hour t


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

# The minimum power of each generator in time t
C_p_min =
[
0	0	0	177.584	0	0	0	0	0	0	0	0
0	0	0	166.982	0	0	0	0	0	0	0	0
0	0	0	158	1.455	0	0	0	0	0	0	0
0	0	0	150.949	5.431	0	0	0	0	0	0	0
0	0	0	150.949	5.431	0	0	0	0	0	0	0
0	0	0	157.575	1.455	0	0	0	0	0	0	0
0	0	0.342	180	15.795	0	0	0	0	0	0	0
0	0	47.943	180	0	0	0	0	0	0	0	0
0	0	70	180	1.798	0	0	0	0	0	0	0
0	0	70	180	4.448	0	0	0	0	0	0	0
0	0	70	180	4.448	0	0	0	0	0	0	0
0	0	70	180	1.798	0	0	0	0	0	0	0
0	0	70	180	1.798	0	0	0	0	0	0	0
0	0	70	180	1.798	0	0	0	0	0	0	0
0	0	66.467	180	0	0	0	0	0	0	0	0
0	0	66.467	180	0	0	0	0	0	0	0	0
0	0	70	180	12.399	0	0	0	0	0	0	0
0	0	70	180	15.05	0	0	0	0	0	0	0
0	0	70	180	15.05	0	0	0	0	0	0	0
0	0	70	180	4.448	0	0	0	0	0	0	0
0	0	61.196	180	0	0	0	0	0	0	0	0
0	0	39.992	180	0	0	0	0	0	0	0	0
0	0	0	180	13.487	0	0	0	0	0	0	0
0	0	0	166.982	0	0	0	0	0	0	0	0
]# The minimum power of each generator in time t


# The maximum power of each generator in time t
C_p_max =
[
152	152	323.625	411	0	155	155	400	400	300	310	350
152	152	339.528	411	0	155	155	400	400	300	310	350
152	152	350	411	1.455	155	155	400	400	300	310	350
152	152	350	411	5.431	155	155	400	400	300	310	350
152	152	350	411	5.431	155	155	400	400	300	310	350
152	152	350	411	1.455	155	155	400	400	300	310	350
152	152	280	411	15.795	155	155	400	400	300	310	350
152	120.086	280	411	0	155	155	400	400	300	310	350
112	122.506	280	411	1.798	155	155	400	400	300	310	350
112	115.88	280	411	4.448	155	155	400	400	300	310	350
112	115.88	280	411	4.448	155	155	400	400	300	310	350
112	122.506	280	411	1.798	155	155	400	400	300	310	350
112	122.506	280	411	1.798	155	155	400	400	300	310	350
112	122.506	280	411	1.798	155	155	400	400	300	310	350
112	132.255	280	411	0	155	155	400	400	300	310	350
132.255	112	280	411	0	155	155	400	400	300	310	350
112	112	280	411	12.399	139.001	155	400	400	300	310	350
112	112	280	411	15.05	132.375	155	400	400	300	310	350
112	112	280	411	15.05	132.375	155	400	400	300	310	350
112	115.88	280	411	4.448	155	155	400	400	300	310	350
140.207	112	280	411	0	155	155	400	400	300	310	350
152	132.013	280	411	0	155	155	400	400	300	310	350
152	152	286.285	411	13.487	155	155	400	400	300	310	350
152	152	339.528	411	0	155	155	400	400	300	310	350
]# The maximum power of each generator in time t


Ramp_up = [120 120 350 240 60 155 155 280 280 300 180 240] # The maximum increase in MWh that can be done from the previous hour in each Conventional generator cg per hour t

Ramp_down = [120 120 350 240 60 155 155 280 280 300 180 240] # The maximum decrease in MWh that can be done from the previous hour in each Conventional generator cg in hour t

Initial_State = [76 76 0 0 0 0 124 240 240 240 248 280] # Initial power output of generating convetional cv when t=0

Cost_cg = [13.32 13.32 20.7 20.93 26.11 10.52 10.52 6.02 5.47 0 10.52 10.89] # Cost of generated power in $ per MWh for conventional cg for all hours

Cost_wg = [0 0 0 0 0 0] # Cost of generated power in $ per MWh for wind park wg in hour t

Bid_price = [20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20] # Bid price of demand point dp in all hours

Cost_Battery = 0
# Storage
battery_capacity = 600  # maximum storage capacity
cap_storage_min = -150 # maximum amount of energy that can be taken out from a battery per time step
cap_storage_max = 150 # maximum amount of energy that can be put in in a battery per time step
eta_storage = 0.98 # Charge and discharge efficiency of batteries

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Declare Variables
#~~~~~~~~~~~~~~~~~~

# The positive amount of power in MW generated from conventiotal cg in hour t
@variable(Step_4_Day_Ahead_Market, p_g[1:T,1:CG] >= 0)

# The positive amount of power generated in MW from wind park wg in hour t
@variable(Step_4_Day_Ahead_Market, w_g[1:T,1:WG] >= 0)

# The amount of power generated for the demand of demand point dp in hour t
@variable(Step_4_Day_Ahead_Market, p_d[1:T,1:DP] >= 0)

# The amount of power that charging the battery in hour t
@variable(Step_4_Day_Ahead_Market, p_b[1:T])

# The state of charge of the battery in hour t
@variable(Step_4_Day_Ahead_Market, Eb_s[1:T] >= 0)
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Declare Objective function - Maximize the Social Welfare
@objective(Step_4_Day_Ahead_Market, Max,
    sum(Bid_price[dp]*p_d[t,dp] for t=1:T for dp=1:DP) -
    sum(Cost_cg[cg]*p_g[t,cg] for t=1:T for cg=1:CG) -
    sum(Cost_wg[wg]*w_g[t,wg] for t=1:T for wg=1:WG) + sum(Cost_Battery*p_b[t] for t=1:T))
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Declare Constraints
# The power generated from convetional generators cg can not exceed their  maximum capacity generation limit
@constraint(Step_4_Day_Ahead_Market, conventional_max_generation[t=1:T, cg=1:CG], p_g[t,cg] <= C_p_max[t,cg])

# The power generated from convetional generators cg must be equal or more that their minimum capacity generation limid
@constraint(Step_4_Day_Ahead_Market, conventional_min_generation[t=1:T, cg =1:CG], p_g[t,cg] >= C_p_min[t,cg])

# The power generated from wind parks wg can not exceed their maximum capacity generation limit
@constraint(Step_4_Day_Ahead_Market, wind_park_generation[t = 1:T, wg = 1:WG], w_g[t,wg] <= W_p[t,wg])

# Ramp up constraint for the power generated from conventional generators cg in time t minus the power generated in previous hour t-1 can not exceed ramp up limits
@constraint(Step_4_Day_Ahead_Market, ramp_up[t=2:T, cg = 1:CG], p_g[t,cg] - p_g[t-1,cg] <= Ramp_up[cg])

# Ramp down constraint for the power generated from conventional generators cg in time t minus the power generated in previous hour t-1 can not exceed ramp down limits
@constraint(Step_4_Day_Ahead_Market, ramp_down[t=2:T, cg = 1:CG], p_g[t,cg] - p_g[t-1,cg] >= -Ramp_down[cg])

# Ramp up constraint for the power generated from conventional generators cg in time t=1 minus the initial charge of conventional generator in t=0 can not exceed ramp up limits
@constraint(Step_4_Day_Ahead_Market, ramp_up_initial[t = 1, cg = 1:CG], p_g[cg,t]-Initial_State[cg] <= Ramp_up[cg])

# Ramp down constraint for the power generated from conventional generators cg in time t=1 minus the initial charge of conventional generator in t=0 can not exceed ramp down limits
@constraint(Step_4_Day_Ahead_Market, ramp_down_initial[t = 1, cg = 1:CG], p_g[cg,t]-Initial_State[cg] >= -Ramp_down[cg])

# The power generated from all generators in hour t can not exceed the load of demand points DP
@constraint(Step_4_Day_Ahead_Market, generation_demand_points[t = 1:T, dp = 1:DP], p_d[t,dp] <= Demand[t,dp])


# Balance equation for the system showing that maximum load of demand equals the power generated from conventional units cg and wind parks wg in time t
@constraint(Step_4_Day_Ahead_Market, balance_equation[t = 1:T], sum(p_d[t,dp] for dp = 1:DP)-sum(p_g[t,cg] for cg = 1:CG)-sum(w_g[t,wg] for wg = 1:WG) + sum(p_b[t]) == 0)

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Battieries' Constraints~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
@constraint(Step_4_Day_Ahead_Market, state_of_charge, Eb_s[1] == eta_storage * p_b[1]) # State of charge in first time step equal to the energy stored multiplied with the efficiency of the battery

@constraint(Step_4_Day_Ahead_Market, power_of_battery[t=2:T], Eb_s[t] == Eb_s[t-1] + eta_storage * p_b[t]) # State of charge equality

@constraint(Step_4_Day_Ahead_Market, limits_of_battery_Up[t=1:T], p_b[t] <= cap_storage_max) # Upper bound limit of battery charge

@constraint(Step_4_Day_Ahead_Market, limits_of_battery_Low[t=1:T], p_b[t] >= cap_storage_min) # Lower bound limit of battery charge

@constraint(Step_4_Day_Ahead_Market, max_energy_stored[t=1:T], Eb_s[t] <= battery_capacity) # Maximum potential energy stored in battery can not exceed battery's capacity
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Solve Model
optimize!(Step_4_Day_Ahead_Market)
println("")
println("Termination status: $(termination_status(Step_4_Day_Ahead_Market))")
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Print Solutions
println("----------------------------------------------------");
if termination_status(Step_4_Day_Ahead_Market) == MOI.OPTIMAL
    println("Maximum Social Welfare(Optimal objective value): $(objective_value(Step_4_Day_Ahead_Market))")

    println("-------------------------")

            println("\n")

            for t=1:T
                println("\n")
                println("Hour $t")
                println("Market Clearing Price in hour $t [USD/MWh]: $(-dual.(balance_equation[t]))")
                println("Power of Battery in hour $t [MWh]: $(JuMP.value.(p_b[t])) ")
                println("Energy stored in battery in hour $t [MW]: $(JuMP.value.(Eb_s[t])) ")
                print("Demand covered in hour $t [MWh]: Demand[MWh]: $(sum(JuMP.value.(p_d[t,:]))) (out of total: $(sum(Demand[t,:]))[MWh]) -> Breakdown: Conventional: $(sum(JuMP.value.(p_g[t,:]))) (out of total: $(sum(C_p_max[:]))[MWh]), Wind: $(sum(JuMP.value.(w_g[t,:]))) (out of total: $(sum(W_p[t,:]))[MWh])")
                println("\n")

                for wg = 1:WG
                println("Contribution of wind generator No.$wg: $(round(JuMP.value.(w_g[t,wg]), digits =3))[MWh] out of forecasted potential: $(W_p[t,wg])[MWh] <- (at offer price: $(Cost_wg[wg]))")
                end

                for cg = 1:CG
                println("Contribution of conventional generator No.$cg: $(round(JuMP.value.(p_g[t,cg]), digits =3))[MWh] out of max potential: $(C_p_max[t,cg])[MWh] <- (at offer price: $(Cost_cg[cg]) if produce more than $(C_p_min[t,cg]))")
                end
            end

            #Print out dual variable values
                   println("\n")
                   println("Dual values:")
                   println("\n")
                   for t=1:T
                       println("Market Clearing Price in hour $t [USD/MWh]: $(-dual.(balance_equation[t]))")
                   end
                   println("\n")

                   for t=1:T
                       println("Demand covered in hour $t [MWh]: Demand[MWh]: $(sum(JuMP.value.(p_d[t,:]))) (out of total: $(sum(Demand[t,:]))[MWh])")
                   end

else
    println("No optimal solution available")
end
