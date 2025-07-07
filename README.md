# montel-market-clearing-models

Electricity market modeling and forecasting examples in Julia.

This repository was developed as part of a university assignment focused on modeling different electricity market mechanisms using Julia and JuMP. The models simulate market clearing, day-ahead and balancing markets, and compare different pricing and reserve setups.

## Repository Structure

├── Step_1_Market_Clearing_No_Network.jl
├── Step_2_Day_Ahead_Market.jl
├── Step_2_Market_Clearing_Nodal.jl
├── Step_2_Market_Clearing_Zonal.jl
├── Step_3_Balancing_Market.jl
├── Step_4_Joint_Market_US_style.jl
├── Step_4_Reserve_Market_EU_style.jl
├── data_sources/
│ ├── Assignment_1_input_data.pdf
│ ├── Assignment_Description.pdf
│ └── IEEE_RTS_24Bus_Paper.pdf
└── README.md


---

## Assignment: Electricity Market Modeling

This assignment explores various aspects of electricity markets through progressively advanced modeling tasks. Each step builds on the previous one.

### Step Overview

| Step | File                                 | Description                                                  |
|------|--------------------------------------|--------------------------------------------------------------|
| 1    | `Step_1_Market_Clearing_No_Network.jl` | Basic market clearing without network constraints          |
| 2a   | `Step_2_Day_Ahead_Market.jl`         | Day-ahead scheduling in energy-only market                   |
| 2b   | `Step_2_Market_Clearing_Nodal.jl`    | Market clearing with nodal pricing (locational marginal)     |
| 2c   | `Step_2_Market_Clearing_Zonal.jl`    | Market clearing with zonal pricing                           |
| 3    | `Step_3_Balancing_Market.jl`         | Balancing market simulation                                  |
| 4a   | `Step_4_Joint_Market_US_style.jl`    | Joint market simulation (US-style integration)               |
| 4b   | `Step_4_Reserve_Market_EU_style.jl`  | Reserve market modeling (EU-style coordination)              |

---

## Data Sources

All input data and assignment description are located in [`data_sources/`](./data_sources):

- [`Assignment_Input_Data.pdf`](./data_sources/Assignment_Input_Data.pdf): Raw input values and scenarios  
- [`Assignment_Description.pdf`](./data_sources/Assignment_Description.pdf): Task breakdown and scope  
- [`IEEE_RTS_24Bus_Paper.pdf`](./data_sources/IEEE_RTS_24Bus_Paper.pdf): Background paper used for system modeling

---

## 🛠 Requirements

- **Julia** ≥ 1.7
- Recommended packages:
  - `JuMP`
  - `GLPK`
  - `DataFrames`
  - `CSV`
  - `Plots` (optional, for visualization)

```julia
using Pkg
Pkg.add(["JuMP", "GLPK", "DataFrames", "CSV", "Plots"])




