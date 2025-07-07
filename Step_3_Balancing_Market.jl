#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Power_System_Step_3_24_Bus_Balance_Balance_Market ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#~~~~~~~~~~~~~~~~~~~~~~~~~ Diamantis Almpantis(s212854) - Shahatphong Pechrak(s213062) - Erlend Thabiso Rømyhr(s212426) - Georgios Merahtsakis(s213520)~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Import packages
using JuMP
using HiGHS
using Printf
using DataFrames

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Declare Model
Step_3_24_Bus_Balance = Model(HiGHS.Optimizer)
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Declare Sets
Conventional_Generators = [1 2 3 4 5 6 7 8 9 10 11 12] # Conventional Generators that exist in the 24-Bus system
CG = length(Conventional_Generators)
Wind_Generators = [1 2 3 4 5 6] # Wind Generators that exist in the 24-Bus system
WG = length(Wind_Generators)

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Declare Parameters
Up_regulation=[152 152 350 591 60 155 109.15 0 0 0 310 350]  # up capacity limits of regulation from the remaining production of Day-Ahead Market for generator cg
Down_regulation=[0 0 0 0 0 0 45.85 400 400 0 0 0] # down capacity limits of regulation from remaining production of Day-Ahead Market for generator cg

# Offer Up and Down Regulation of each generator
Cost_Up=[14.652 14.652 22.77 23.023 28.721 11.572 11.572 6.622 6.017 0 11.572 11.979] # Up regulation cost for generator cg
Cost_Down=[11.7216 11.7216 18.216 18.4184 22.9768 9.2576 9.2576 5.2976 4.8136 0 9.2576 9.5832] # Down regulation cost for generator cg

Wind_For =[113.76	124.06	105.85	89.77	99.26	97.28] #Wind forcasted changing that affect to production of some wind farm increase 15%
Wind_Real =[102.38	142.67	95.27	103.24	89.33	111.88] #Wind forcasted changing that affect to production of some wind farm decrease 10%
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Declare Variables
#~~~~~~~~~~~~~~~~~~

#The amount of up regulation power in MW generated from conventiotal cg
@variable(Step_3_24_Bus_Balance, P_Up[1:CG] >=0)

#The amount of down regulation power in MW generated from conventiotal cg
@variable(Step_3_24_Bus_Balance, P_Down[1:CG] >=0)

#The amount of curtailment demand in MW in this hour
@variable(Step_3_24_Bus_Balance, P_Demand >=0)

# Declare Objective function - Minimize the cost of Balancing market
@objective(Step_3_24_Bus_Balance, Min , (500*P_Demand) + sum(Cost_Up[cg]*P_Up[cg] for cg=1:CG) - sum(Cost_Down[cg]*P_Down[cg] for cg=1:CG))
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Declare Constraints

# The up regulation powerpower generated from convetional generators can not exceed their maximum capacity generation limit
@constraint(Step_3_24_Bus_Balance, Upward_Regultation_Power[cg=1:CG],P_Up[cg]<=Up_regulation[cg])

# The down regulation powerpower generated from convetional generators can not exceed their production at this hour
@constraint(Step_3_24_Bus_Balance, Downward_Regultation_Power[cg=1:CG],P_Down[cg]<=Down_regulation[cg])

#The curtailment demand can not exceed the total demand of this hour
@constraint(Step_3_24_Bus_Balance, Curtailment_Demand, 0<=P_Demand<=1778.5)

# Balance equation for the system showing that maximum load of demand equals the power generated from conventional units cg and wind parks wg
@constraint(Step_3_24_Bus_Balance, balance_equation, sum(P_Up[cg] for cg = 1:CG)-sum(P_Down[cg] for cg = 1:CG)+ P_Demand == 300 + sum(Wind_For[wg] for wg = 1:WG)-sum(Wind_Real[wg] for wg = 1:WG))
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Solve Model
optimize!(Step_3_24_Bus_Balance)
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Print Solutions
println("Minimize Social Welfare(Optimal objective value): $(objective_value(Step_3_24_Bus_Balance))")
println("\n")

println("Market Clearing Price in hour [USD/MWh]: $(dual.(balance_equation))")
println("\n")

println("Demand [MWh]: $(round(JuMP.value.(P_Demand), digits =3))[MWh]")
println("\n")

for cg = 1:CG
println("Upward generator No.$cg: $(round(JuMP.value.(P_Up[cg]), digits =3))[MWh]" )
end
println("\n")

for cg = 1:CG
println("Downward generator No.$cg: $(round(JuMP.value.(P_Down[cg]), digits =3))[MWh]" )
end
