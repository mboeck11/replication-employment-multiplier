# Replication Package — DSGE Model

## Paper

**Labor Market Institutions, Fiscal Multipliers, and Macroeconomic Volatility**

Maximilian Boeck, Jesús Crespo Cuaresma, and Christian Glocker  
*May 2026*

**Keywords:** Fiscal policy; labor market institutions; interacted panel VAR  
**JEL Codes:** E62, C33, J21, J38

### Abstract

How do labor market institutions shape the transmission of government spending shocks and macroeconomic volatility? We develop a theoretical model in which labor market institutions affect fiscal transmission through their effect on wage rigidity, job separation, and matching frictions. We estimate an interacted panel vector autoregressive model for 16 OECD economies and study how macroeconomic responses to government spending shocks vary with institutional labor market characteristics. In line with our theoretical predictions, we show that institutions that stabilize employment and wages tend to dampen output volatility and attenuate the response of output and employment to government spending shocks.

---

## Overview of the DSGE Model

The theoretical framework combines a **Diamond–Mortensen–Pissarides (DMP) search-and-matching labor market** with an otherwise standard **New Keynesian (NK)** business-cycle model, built on Merz (1995), Andolfatto (1996), Krause and Lubik (2007), and Monacelli, Perotti, and Trigari (2010). The model is calibrated at **monthly frequency**.

Three labor market institution (LMI) parameters are the focus of the analysis:

| Parameter | Symbol | Description |
|-----------|--------|-------------|
| Union density (UD) | η (`eta`) | Workers' bargaining power in Nash wage bargaining |
| Benefit replacement rate (BRR) | φ (`varphi`) | Unemployment benefit as a share of the previous wage |
| Employment protection legislation (EPL) | ς (`varsigma`) | Firing cost rate relative to the previous wage |

A labor tax wedge τ (`tau`) is also considered. The remaining parameters govern preferences, technology, the matching function, nominal price rigidities, and monetary policy. See Section 3 of the paper for a full model description.

---

## Software Requirements

| Software | Purpose | Notes |
|----------|---------|-------|
| **MATLAB** (R2019b or later) | Main scripting and steady-state computations | Requires the **Symbolic Math Toolbox** (used in `console_baseline.m`) and the **Statistics and Machine Learning Toolbox** (for `logncdf`, `lognpdf`, `logninv`) |
| **Dynare** (4.x or later) | Solving and simulating the DSGE model | Available at [https://www.dynare.org](https://www.dynare.org) |

The main script adds the Dynare path via:
```matlab
path(oldpath, '/usr/lib/dynare/matlab');
```
This path is Linux-specific. **Adjust it** to your local Dynare installation before running (e.g., on Windows: `'C:\dynare\<version>\matlab'`; on macOS: `'/Applications/Dynare/<version>/matlab'`).

---

## File Inventory

### Master script

| File | Description |
|------|-------------|
| `main.m` | **Main entry point.** Loops over LMI parameter grids, calls Dynare for each configuration, computes cumulative fiscal multipliers, and exports the paper's figures. This is the only file a replicator needs to run directly. |

### Steady-state solvers (called internally from Dynare `.mod` files)

These files are executed by Dynare at pre-processing time via the `console_baseline;` or `console_dmp_baseline;` directive at the top of each `.mod` file. They compute steady-state values and save them to `par_dmp_baseline.mat`, which is then loaded by the model file.

| File | Called by | Description |
|------|-----------|-------------|
| `console_baseline.m` | `dmp_baseline_nom_rigid.mod`, `dmp_baseline_nom_rigid_matching.mod`, `dmp_baseline_nom_rigid_alt_main_res.mod` | Steady-state solver for the **main NK-DMP model**. Uses MATLAB's Symbolic Math Toolbox (`solve`) to obtain closed-form solutions for the five key endogenous steady-state variables (Fn, w, κ, Hn, mrs). Handles the full 28-parameter vector. |
| `console_dmp_baseline.m` | All other `.mod` files | Steady-state solver for **simpler/auxiliary DMP model variants**. Solves analytically without symbolic tools. Uses a 22-parameter vector (note: parameter ordering for positions 20–21 differs from `console_baseline.m`; see parameter table below). |

> **Note on parameter ordering:** The two console files share positions 1–19 and 22 but differ at positions 20–21: `console_baseline.m` uses position 20 for `thetaP` (Calvo) and position 21 for `phi_pi` (Taylor inflation), while `console_dmp_baseline.m` reverses these. This is handled correctly in the master script, which only calls `dmp_baseline_nom_rigid.mod` (which uses `console_baseline.m`).

### External functions (called within Dynare model blocks)

| File | Description |
|------|-------------|
| `Atfct.m` | Computes the conditional expectation of idiosyncratic job productivity above the endogenous separation threshold: $A(\tilde{a}) = E[a \mid a \geq \tilde{a}]$, where $a$ follows a log-normal distribution. Corresponds to Eq. (3.4) in the paper. |
| `Ftfct.m` | Computes the endogenous job separation probability: $F(\tilde{a}) = \Pr(a < \tilde{a})$ for log-normally distributed $a$. Enters the overall separation rate in Eq. (3.2). |
| `IRF_matching_objective.m` | Objective function for the **IRF matching exercise** (Section 4). Called within the optimization loop in `dmp_baseline_nom_rigid_matching.mod`. Runs `stoch_simul` and returns the quadratic distance between model-implied and target empirical IRFs. |

### Dynare model files (`.mod`)

All `.mod` files share the same core NK-DMP model structure. They differ in which frictions are active and which shocks are included.

| File | Frictions / Extensions | Figures |
|------|----------------------|---------|
| `dmp_baseline_nom_rigid.mod` | **Baseline model.** Calvo price stickiness, Taylor rule with interest rate smoothing. Switch parameters control: inflation indexation (`gammaP`), real wage rigidity (`rhorw`), non-Ricardian households (`xi`), firing costs in government budget (`FCBC`), public capital in production function (`alphaG`). | **Figures 2, B1–B6** |
| `dmp_baseline_nom_rigid_matching.mod` | Same model, extended for **IRF matching exercise**. Calls `IRF_matching_objective.m` via CMA-ES or csminwel optimizer. Requires `IRF_emp_nov.xlsx` (empirical IRFs). | — |
| `dmp_baseline_nom_rigid_alt_main_res.mod` | Alternative specification of baseline model (government spending shock enters directly without scaling; Calvo parameter rescaled). Used for robustness checks on the main results. | — |
| `dmp_baseline_nom_rigid_MP.mod` | Nominal rigidities, no non-Ricardian households. **Two shocks:** government spending (`vg`) and monetary policy (`vMP`). | — |
| `dmp_baseline_nom_rigid_nrh.mod` | Nominal rigidities + **non-Ricardian households**. No real wage rigidity. | — |
| `dmp_baseline_nrh.mod` | Nominal rigidities + non-Ricardian households + real wage rigidity option. Simpler Taylor rule. | — |
| `dmp_baseline_all_frictions.mod` | Nominal rigidities + non-Ricardian households + real wage rigidity, all active simultaneously. | — |
| `dmp_baseline_FirCos_in_GBC.mod` | **Firing costs as government revenue** (equivalent to `FCBC=1` in the baseline). Appendix B robustness. | **Figure B4** |
| `dmp_baseline_G_in_PF.mod` | **Government spending enters production** as public capital (equivalent to `alphaG>0`). Appendix B robustness. | **Figure B5** |
| `dmp_baseline_5_shocks.mod` | Five structural shocks: government spending, TFP, monetary policy, discount factor, matching efficiency. | — |
| `dmp_baseline_rw_rigid.mod` | **Real wage rigidity** as the sole additional friction beyond the DMP baseline. | — |

---

## Replication Instructions

### Step 1 — Adjust paths

Open `Modellsimulationshauptdatei.m` and update the Dynare path on line 15:
```matlab
path(oldpath, '/usr/lib/dynare/matlab');  % <-- update to your Dynare installation
```

### Step 2 — Run the master script

From MATLAB's current directory set to this folder, execute:
```matlab
Modellsimulationshauptdatei
```

The script (i) loops over a grid of LMI parameter values (η, φ, ς), (ii) calls `dynare dmp_baseline_nom_rigid.mod` for each configuration, (iii) computes cumulative impulse-response-based fiscal multipliers, and (iv) exports figures.

### Step 3 — Expected output

The following PDF figures are exported to the current directory:

| Figure | File | Content |
|--------|------|---------|
| Figure 2 | `Figure_2.pdf` | Fiscal multipliers across LMI parameter ranges (baseline model) |
| Figure B1 | `Figure_B1.pdf` | Multipliers: with vs. without price inflation indexation |
| Figure B2 | `Figure_B2.pdf` | Multipliers: flexible vs. sticky real wages |
| Figure B3 | `Figure_B3.pdf` | Multipliers: Ricardian vs. non-Ricardian (hand-to-mouth) households |
| Figure B4 | `Figure_B4.pdf` | Multipliers: firing costs as resource costs vs. government revenue |
| Figure B5 | `Figure_B5.pdf` | Multipliers: with productivity-enhancing government spending |
| Figure B6 | `Figure_B6.pdf` | Multipliers: separability between consumption and leisure |

> **Note on computation time and quantitative accuracy.** The master script uses a reduced parameter grid (`iter = 7`) and a shorter IRF horizon than the full simulations underlying the published results. The figures should reproduce the qualitative patterns and economic mechanisms of the paper, but not necessarily the exact quantitative values.

### IRF matching exercise (Section 4)

Running the IRF matching exercise requires `IRF_emp_nov.xlsx`, which contains the empirical IRFs estimated from the interacted panel VAR. This file must be placed in the working directory (or the path on line 263 of `dmp_baseline_nom_rigid_matching.mod` must be updated). Call `dynare dmp_baseline_nom_rigid_matching.mod` directly from within `Modellsimulationshauptdatei.m` after uncommenting the relevant section.

---

## Parameter Vector Layout

Both console files expect the parameter vector `x_` (column vector) and a `shock` vector. Positions 1–19 are shared; positions 20 onward differ across the two files.

### Shared positions (1–19)

| Index | Name | Description |
|-------|------|-------------|
| 1 | `eta` | Workers' bargaining power (union density proxy) |
| 2 | `varphi` | Unemployment benefit replacement rate |
| 3 | `varsigma` | Firing cost rate (employment protection proxy) |
| 4 | `tau` | Labor income tax rate |
| 5 | `betta` | Household discount factor |
| 6 | `alpha` | Elasticity of production w.r.t. labor (= 0 in baseline) |
| 7 | `gshare` | Government spending share in steady state |
| 8 | `tfp` | Total factor productivity in steady state |
| 9 | `rhog` | AR(1) persistence of government spending shock |
| 10 | `sigma` | Consumption-leisure complementarity parameter |
| 11 | `gamma` | Elasticity of matches w.r.t. unemployment |
| 12 | `p` | Job-finding probability in steady state |
| 13 | `theta` | Labor market tightness in steady state |
| 14 | `zeta` | Ratio of MRS to MPL in steady state |
| 15 | `rhorw` | Degree of real wage rigidity (0 = fully flexible) |
| 16 | `rhob` | Exogenous job separation rate |
| 17 | `mua` | Mean of log-normal idiosyncratic productivity distribution |
| 18 | `siga` | Std. dev. of log-normal idiosyncratic productivity distribution |
| 19 | `rhot` | Overall (endogenous + exogenous) job separation rate in steady state |

### Additional positions — `console_baseline.m` (positions 20–28)

| Index | Name | Description |
|-------|------|-------------|
| 20 | `thetaP` | Calvo price stickiness parameter |
| 21 | `phi_pi` | Taylor rule: inflation response coefficient |
| 22 | `phi_y` | Taylor rule: output response coefficient |
| 23 | `rho_i` | Interest rate smoothing coefficient |
| 24 | `xi` | Share of non-Ricardian (hand-to-mouth) households |
| 25 | `hb` | Habit formation in consumption |
| 26 | `gammaP` | Inflation indexation of prices (0 = no indexation) |
| 27 | `FCBC` | Firing costs in government budget constraint (1 = yes, 0 = no) |
| 28 | `alphaG` | Elasticity of public capital in the production function |

### Additional positions — `console_dmp_baseline.m` (positions 20–22)

| Index | Name | Description |
|-------|------|-------------|
| 20 | `phi_pi` | Taylor rule: inflation response coefficient |
| 21 | `thetaP` | Calvo price stickiness parameter |
| 22 | `xi` | Share of non-Ricardian households |

### Shock vector

`shock = [shockG, shockA, shockMP, ...]` where each entry is 0 or 1 and activates the corresponding structural shock. The baseline activates only the government spending shock: `shock = [1, 0, 0, 0, 0, 0, 0]`.
