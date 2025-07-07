#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 24-Bus_Power_System_Step_2_Zonal ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#~~~~~~~~~~~~~~~~~~~~~~~~~ Diamantis Almpantis(s212854) - Shahatphong Pechrak(s213062) - Erlend Thabiso Rømyhr(s212426) - Georgios Merahtsakis(s213520)~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Import packages
using JuMP
using HiGHS
using Printf
using DataFrames

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Declare Model

Step_2_24_Bus_Zonal = Model(HiGHS.Optimizer)
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
Wind_Gen_Nodes = [3 5 7 16 21 23] # Wind Generator location on nodes
Wind_Gen_Nodes2 = [3 5 7 16 21 23 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 ] # Wind Generator location on nodes
Hours = [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24] # The hours that the demand and production of the system take place
T = length(Hours)
Demand_points = [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17] # The areas that generators will supply
DP = length(Demand_points)
Demand_points_nodes = [1 2 3 4 5 6 7 8 9 10 13 14 15 16 18 19 20] # Demand points connected with nodes
Batteries = [1 2 3 4 5 6] # The batteries that are available in our system
B = length(Batteries)
Batteries_Nodes = [3 5 7 16 21 23] # The nodes that batterie b is connected
#Zone1 = collect(1:10) # Nodes in zone 1
#Zone2 = collect(11:24) # Nodes in zone 2
Zones = [1 2] # The zones that are zonal system is splitted to
Z = length(Zones)
Nodes_Zones = [1 1 1 1 1 1 1 1 1 1 2 2 2 2 2 2 2 2 2 2 2 2 2 2] # The zone z that each node n belongs
Conventional_Gen_Zones = [1 1 1 2 2 2 2 2 2 2 2 2] # The zone z that each conventional generator cg belongs
Wind_Gen_Zones = [1 1 1 2 2 2 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 ] # The zone z that each wind generator wg belongs
Batteries_Zones = [1 1 1 2 2 2] # The zone z that each battery b belongs
Demand_points_Zones = [1 1 1 1 1 1 1 1 1 1 2 2 2 2 2 2 2] # The zone z that each demand point dp belongs



#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Mapping
# Node with node that reveal the capacity of transmission lines
Transmission_lines =
[
0	175	175	0	350	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0
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

Wind_Mapping = zeros(length(Zones),length(Wind_Generators))
    for z in Zones
        for g in 1:WG
            if Wind_Gen_Zones[g]==z
                Wind_Mapping[z,g]=1
            else
                Wind_Mapping[z,g]=0
            end
        end
    end

Conventional_Mapping = zeros(length(Zones),length(Conventional_Generators))
    for z in Zones
        for g in 1:CG
            if Conventional_Gen_Zones[g]==z
                Conventional_Mapping[z,g]=1
            else
                Conventional_Mapping[z,g]=0
            end
        end
    end

Battery_Mapping = zeros(length(Zones),length(Batteries))
    for z in Zones
        for g in 1:B
            if Batteries_Zones[g]==z
                Battery_Mapping[z,g]=1
            else
                Battery_Mapping[z,g]=0
            end
        end
    end

Demand_Point_Mapping = zeros(length(Zones),length(Demand_points))
    for z in Zones
        for g in 1:DP
            if Demand_points_Zones[g]==z
                Demand_Point_Mapping[z,g]=1
            else
                Demand_Point_Mapping[z,g]=0
            end
        end
    end

Nodes_Mapping = zeros(length(Zones),length(Nodes))
    for z in Zones
        for n in 1:N
            if Nodes_Zones[n]==z
                Nodes_Mapping[z,n]=1
            else
                Nodes_Mapping[z,n]=0
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
battery_capacity = 100  # maximum storage capacity for each unit
cap_storage_min = -25 # maximum amount of energy that can be taken out from a battery per time step for each unit
cap_storage_max = 25 # maximum amount of energy that can be put in in a battery per time step for each unit
eta_storage = 0.98 # storage efficiency of the battery
Susceptance = 500 # Susceptance of line connecting node n to node m
ATCs1 = 2000 # Available transfer capability from zone 1 to zone 2
ATCs2 = 2000 # Available transfer capability from zone 2 to zone 1
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Declare Variables
#~~~~~~~~~~~~~~~~~~
# The positive amount of power in MW generated from conventiotal cg in hour t
@variable(Step_2_24_Bus_Zonal, p_g[1:T,1:CG] >= 0)

# The positive amount of power generated in MW from wind park wg in hour t
@variable(Step_2_24_Bus_Zonal, w_g[1:T,1:WG] >= 0)

# The amount of power generated for the demand of demand point dp in hour t
@variable(Step_2_24_Bus_Zonal, p_d[1:T,1:DP] >= 0)

# The amount of power that charging the battery in hour t
@variable(Step_2_24_Bus_Zonal, p_b[1:T,1:DP])

# The state of charge of the battery in hour t
@variable(Step_2_24_Bus_Zonal, Eb_s[1:T,1:B] >= 0)

# Power flow from one to zone to the other
@variable(Step_2_24_Bus_Zonal, Power_flow[1:T,1:Z,1:Z])
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Declare Objective function - Maximize the Social Welfare
@objective(Step_2_24_Bus_Zonal, Max,
    sum(Bid_price[dp]*p_d[t,dp] for t=1:T for dp=1:DP) -
    sum(Cost_cg[cg]*p_g[t,cg] for t=1:T for cg=1:CG) -
    sum(Cost_wg[wg]*w_g[t,wg] for t=1:T for wg=1:WG) + sum(Cost_Battery*p_b[t,b] for t=1:T for b=1:B))
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Declare Constraints

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Conventional Generators' Constraints~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# The power generated from convetional generators cg can not exceed their  maximum capacity generation limit
@constraint(Step_2_24_Bus_Zonal, conventional_max_generation[t=1:T, cg=1:CG], p_g[t,cg] <= C_p_max[cg])

# The power generated from convetional generators cg must be equal or more that their minimum capacity generation limid
@constraint(Step_2_24_Bus_Zonal, conventional_min_generation[t=1:T, cg = 1:CG], p_g[t,cg] >= C_p_min[cg])

# Ramp up constraint for the power generated from conventional generators cg in time t minus the power generated in previous hour t-1 can not exceed ramp up limits
@constraint(Step_2_24_Bus_Zonal, ramp_up[t=2:T, cg = 1:CG], p_g[t,cg] - p_g[t-1,cg] <= Ramp_up[cg])

# Ramp down constraint for the power generated from conventional generators cg in time t minus the power generated in previous hour t-1 can not exceed ramp down limits
@constraint(Step_2_24_Bus_Zonal, ramp_down[t=2:T, cg = 1:CG], p_g[t,cg] - p_g[t-1,cg] >= -Ramp_down[cg])

# Ramp up constraint for the power generated from conventional generators cg in time t=1 minus the initial charge of conventional generator in t=0 can not exceed ramp up limits
@constraint(Step_2_24_Bus_Zonal, ramp_up_initial[t = 1, cg = 1:CG], p_g[cg,t]-Initial_State[cg] <= Ramp_up[cg])

# Ramp down constraint for the power generated from conventional generators cg in time t=1 minus the initial charge of conventional generator in t=0 can not exceed ramp down limits
@constraint(Step_2_24_Bus_Zonal, ramp_down_initial[t = 1, cg = 1:CG], p_g[cg,t]-Initial_State[cg] >= -Ramp_down[cg])

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Renewable Generators' Constraints~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# The power generated from wind parks wg can not exceed their maximum capacity generation limit
@constraint(Step_2_24_Bus_Zonal, wind_park_generation[t = 1:T, wg = 1:WG], w_g[t,wg] <= W_p[t,wg])

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Demand Points' Constraints~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# The power generated from all generators in hour t can not exceed the load of demand points DP
@constraint(Step_2_24_Bus_Zonal, generation_demand_points[t = 1:T, dp = 1:DP], p_d[t,dp] <= Demand[t,dp])

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Battieries' Constraints~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

@constraint(Step_2_24_Bus_Zonal, power_battery[b=1:B], Eb_s[1,b] == eta_storage * p_b[1,b]) # Power charged in battery in first time step t=1 equals to zero

@constraint(Step_2_24_Bus_Zonal, power_of_battery[t=2:T,b=1:B], Eb_s[t,b] == Eb_s[t-1,b] + eta_storage * p_b[t,b]) # State of charge equality

@constraint(Step_2_24_Bus_Zonal, limits_of_battery_Up[t=1:T,b=1:B], p_b[t,b] <= cap_storage_max) # Upper bound limit of battery charge

@constraint(Step_2_24_Bus_Zonal, limits_of_battery_Low[t=1:T,b=1:B], p_b[t,b] >= cap_storage_min) # Lower bound limit of battery charge

@constraint(Step_2_24_Bus_Zonal, max_energy_stored[t=1:T,b=1:B], Eb_s[t,b] <= battery_capacity) # Maximum potential energy stored in battery can not exceed battery's capacity

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Balance Equation Constraints~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#Balance constraint
@constraint(Step_2_24_Bus_Zonal, balance_equation[t=1:T,z=1:Z], sum(p_d[t,dp] * Demand_Point_Mapping[z,dp] for dp = 1:DP) +sum(Power_flow[t,z,x] for x=1:Z)-sum(p_g[t,cg] * Conventional_Mapping[z,cg] for cg = 1:CG)-sum(w_g[t,wg] * Wind_Mapping[z,wg] for wg = 1:WG) + sum(p_b[t,b] * Battery_Mapping[z,b] for b = 1:B)  == 0)

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Network Constraints~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
@constraint(Step_2_24_Bus_Zonal, transmission_flow_up[t=1:T], Power_flow[t,1,2] <= ATCs1) # Power flow upper limits from available transmission capacity ATC

@constraint(Step_2_24_Bus_Zonal, transmission_flow_down[t=1:T], Power_flow[t,1,2] >= -ATCs2) # Power flow lower limits from available transmission capacity ATC

@constraint(Step_2_24_Bus_Zonal, force1[t=1:T], Power_flow[t,1,1] == 0) # forcing the power flow from zone 1 to zone 1 to be zero at every time step t

@constraint(Step_2_24_Bus_Zonal, force2[t=1:T], Power_flow[t,2,2] == 0) # forcing the power flow from zone 2 to zone 2 to be zero at every time step t

@constraint(Step_2_24_Bus_Zonal, force3[t=1:T], Power_flow[t,1,2] == -Power_flow[t,2,1]) # The power flow from zone 1 to zone 2 equals the power flow from zone 2 to zone 1

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Solve Model
optimize!(Step_2_24_Bus_Zonal)

Total_Flow = zeros(length(Hours),length(Zones),length(Zones))
 for t in Hours
    for z in Zones
        for m in Zones
            Total_Flow[t,z,m]=JuMP.value(Power_flow[t,z,m])
            end
        end
    end

println("\n")

println("")
println("Termination status: $(termination_status(Step_2_24_Bus_Zonal))")
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Print Solutions
println("----------------------------------------------------");
if termination_status(Step_2_24_Bus_Zonal) == MOI.OPTIMAL
    println("Maximum Social Welfare(Optimal objective value): $(objective_value(Step_2_24_Bus_Zonal))")

    println("-------------------------")

            println("\n")

            for t=1:T
                println("\n")
                println("Hour $t")
                for z=1:Z
                    println("Market Clearing Price in hour $t [USD/MWh], zone $z: $(-dual.(balance_equation[t,z]))")
                end
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
                   println("Demand satisfaction:")
                   println("\n")
                   for z=1:Z
                       for t=1:T
                           println("Market Clearing Price in hour $t [USD/MWh], zone $z: $(-dual.(balance_equation[t,z]))")
                       end
                   end
                   println("\n")

                   for t=1:T
                       println("Demand covered in hour $t [MWh]: Demand[MWh]: $(sum(JuMP.value.(p_d[t,:]))) (out of total: $(sum(Demand[t,:]))[MWh])")
                   end

else
    println("No optimal solution available")
end
