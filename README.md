# Code and Data for: "Behavioral Signatures of Post-Decisional Attention in Preferential Choice"

This repository contains the MATLAB code and data required to reproduce the model fitting, simulations, and figures from the paper.

---

## Requirements

- **MATLAB** (tested with R2020b and later)
- **Parallel Computing Toolbox** (for `parfor` loops; optional but strongly recommended)

All external dependencies (including the BADS optimizer and plotting utilities) are
included in the `matlab_functions/` folder — no separate downloads required.

---

## Folder structure

```
code_n_data_for_sharing/
├── data/                            Preprocessed behavioral data
│   ├── data_krajbich2010.mat        Choice, RT, value, and fixation data (Krajbich et al. 2010)
│   ├── dwell_duration_pd.mat        Log-normal distributions fit to fixation durations
│   ├── MultAddLastFix.mat           Multi-dataset fixation data (D2–D4); used by Figs. 3–4
│   ├── data_Callaway2021.mat        Callaway et al. (2021) model simulations
│   ├── data_Drugowitsch2021.mat     Jang & Drugowitsch (2021) model simulations
│   ├── data_Folke_2alt.mat          Folke et al. (2016) dataset
│   └── sepulveda2020_food.mat       Sepulveda et al. (2020) dataset
│
├── functions/                       Shared MATLAB functions (DTB solver, plotting, helpers)
├── matlab_functions/                External dependencies (BADS, cbrewer, publish_plot, etc.)
│
├── Fig2_both_aDDM_predictions/      aDDM predictions: last-fixation bias and dwell advantage
├── Fig3_OV_LastDwell/               Last-fixation bias vs. overall value (4 datasets)
├── Fig4_DeltaDwell_vs_consistency/  Dwell advantage split by choice consistency (7 datasets)
├── Fig5_model_PDG/                  PDG model: fitting and simulation
│   ├── fitting_flat_bounds/         Fit PDG model to behavioral data (flat bounds)
│   └── simulation_flat_bounds/      Simulate PDG behavior and eye movements
├── Fig7_pre_post_gaze/              Pre- and post-decision gaze toward chosen item
├── Fig8_sensitivity_tau_e/          Sensitivity of PDG predictions to post-decisional latency τ_e
├── Fig10_multi_model_figure/        Multi-model comparison figure
│
├── model_ATT/                       ATT model: multiplicative intra-decisional attention
│   └── dtb_att_code/                Core DTB solver with time-varying drift
├── model_ATT_ADDITIVE/              ATT-ADDITIVE: additive (rather than multiplicative) attention
│   └── dtb_att_code/
├── model_ATT_VarDrift/              ATT-VarDrift: ATT with inter-trial drift-rate variability
│   └── dtb_att_code/
├── model_ATT_VarDrift_2D/           ATT-VarDrift-2D: ATT with inter-trial value variability
│   └── dtb_att_code/
├── model_ATT_PD/                    ATT+PD: ATT extended with post-decisional gaze dynamics
├── model_ATT_VarDrift_PD/           ATT-VarDrift+PD: combines VarDrift and post-decisional gaze
├── model_aDDM_orig_params/          aDDM simulated with original Krajbich et al. parameters
├── Callaway2021/                    Callaway et al. (2021) model predictions vs. data
└── Drugowitsch2021/                 Jang & Drugowitsch (2021) model predictions vs. data
```

---

## Models

### PDG model (`Fig5_model_PDG/`)
A drift-diffusion model where the drift rate is scaled by the total value of both
options (magnitude effect), but fixations have **no intra-decisional effect** on
evidence accumulation. Eye movements are generated post-hoc by sampling from
empirical fixation duration distributions and adding a post-decisional gaze shift.

### ATT model (`model_ATT/`)
An attentional drift-diffusion model where the momentary drift is **multiplicatively**
modulated by the currently fixated item: the unattended item's value is discounted
by a factor `omega`. Fixation sequences are taken directly from the data.

Parameters: `kappa`, `B0`, `a`, `d`, `coh0`, `y0`, `omega`.

### ATT-ADDITIVE model (`model_ATT_ADDITIVE/`)
Like ATT but with an **additive** attention term instead of multiplicative.

### ATT-VarDrift model (`model_ATT_VarDrift/`)
ATT model extended with **inter-trial drift-rate variability** (`std_drift`).

### ATT-VarDrift-2D model (`model_ATT_VarDrift_2D/`)
ATT model extended with **inter-trial value variability** (2D noise).

### ATT+PD model (`model_ATT_PD/`)
ATT model extended with **post-decisional gaze dynamics**: after the decision,
gaze shifts to the chosen item with sensory and eye-movement latency.

### ATT-VarDrift+PD model (`model_ATT_VarDrift_PD/`)
Combines ATT-VarDrift with post-decisional gaze dynamics.

### aDDM original parameters (`model_aDDM_orig_params/`)
Simulates behavior using the original aDDM parameters from Krajbich et al. (2010).

### Comparison models (`Callaway2021/`, `Drugowitsch2021/`)
Plots predictions from Callaway et al. (2021) and Jang & Drugowitsch (2021)
against the Krajbich et al. (2010) behavioral data.

---

## Workflow

### Figures 2–4, 7 (empirical data figures)
Each folder contains a single `main.m`. Run from the folder:
```matlab
cd Fig2_both_aDDM_predictions;  main()
cd Fig3_OV_LastDwell;           main()
cd Fig4_DeltaDwell_vs_consistency; main()
cd Fig7_pre_post_gaze;          main()
```

### Figure 5 — PDG model
```matlab
% Fit to data
cd Fig5_model_PDG/fitting_flat_bounds
main()

% Simulate and plot
cd ../simulation_flat_bounds
run_make_external_params()   % set post-decisional gaze timing parameters
run_make_sim_data()          % simulate behavior + eye movements
run_do_plot()                % generate figure
```

### Figure 8 — τ_e sensitivity
```matlab
cd Fig8_sensitivity_tau_e
run_make_sim_tau_e()             % run simulations (slow)
run_plot_tau_e_sensitivity()     % generate figure
```

### Figure 10 — Multi-model comparison
```matlab
cd Fig10_multi_model_figure
run_precompute()   % precompute all model quantities (run once)
run_plot()         % generate figure
```

### ATT-family models (`model_ATT/`, `model_ATT_ADDITIVE/`, `model_ATT_VarDrift/`, `model_ATT_VarDrift_2D/`)
Each folder follows the same structure:
```matlab
cd model_ATT   % (or model_ATT_ADDITIVE, etc.)

% 1. Fit to data
run_do_fit(3, 1)   % flat bounds, real data

% 2. Simulate from best-fit parameters
run_eval_best_resample_ATT_nreps(2, 10)   % flat bounds, 10 repetitions

% 3. Generate figure
run_do_plot()
```
Or run all three steps at once:
```matlab
run_do_all()
```

### ATT+PD model
```matlab
% Prerequisites: model_ATT must be fit and simulated first
cd model_ATT_PD
run_make_external_params()   % estimate post-decisional timing
main(2)                      % flat bounds variant
```

### ATT-VarDrift+PD model
```matlab
% Prerequisites: model_ATT_VarDrift must be fit and simulated first
cd model_ATT_VarDrift_PD
main()
```

### Comparison models
```matlab
cd Callaway2021;    main()
cd Drugowitsch2021; main()
```

---

## Key functions

| File | Description |
|------|-------------|
| `functions/dtb_fp_cc_vec.m` | Solves the 1D Fokker-Planck equation (Chang-Cooper scheme) |
| `model_ATT/dtb_att_code/dtb_fp_cc_vec_dyndrifts.m` | Same, with time-varying drift (ATT models) |
| `model_ATT/dtb_att_code/wrapper_dtb_parametricbound_rt_extATT.m` | ATT model likelihood given fixation sequences |
| `Fig5_model_PDG/fitting_flat_bounds/wrapper_dtb_parametricbound_rt_scale_noise.m` | PDG model likelihood |
| `functions/fn_run_plot_best.m` | Generates the multi-panel model summary figure |
| `functions/sample_attention_switches_from_pd.m` | Samples fixation sequences from log-normal distributions |

---

## Data

`data/data_krajbich2010.mat` contains preprocessed data from Krajbich et al. (2010).
Variables: `vleft`, `vright` (item values), `choice` (1=right), `RT` (s),
`dv` (value difference), `group` (subject ID), `dwells` (fixation sequences).

`data/dwell_duration_pd.mat` contains fitted log-normal distributions for the
duration of first (`pd_first`) and subsequent (`pd_middle`) fixations.

`data/MultAddLastFix.mat` contains fixation and choice data from Smith & Krajbich (2018),
Chen & Krajbich (2016), and Gwinn & Krajbich (2016), used in Figs. 3–4.

`data/data_Callaway2021.mat` and `data/data_Drugowitsch2021.mat` contain model
simulations from the respective papers, precomputed for comparison.

---

## Contact

Ariel Zylberberg — ariel.zylberberg@gmail.com
