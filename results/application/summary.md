# Application: policy-topic coding of US congressional bills (Section 5)

Generated 2026-09-26 13:45. 800 bills (200 validation, 600 working, 30 anchored), 3 models (anthropic, gemini, ollama), 5 prompts, 3 runs; 36000 labels, 0.03% missing.
CRE-LCM: quadrature (15 nodes), 4 chains x 1500 iterations (750 warm-up), Dawid-Skene initialisation; unanchored fit 94.2 min, max R-hat 1.457; anchored fit 90.9 min, max R-hat 1.035. Models fitted to the LLM labels of all 800 bills; CAP labels used only for the 30 anchors and for evaluation.

## Agreement

| model | n_config | fleiss_kappa | mean_pairwise_agreement | pct_label_1 | pct_missing |
|---|---|---|---|---|---|
| anthropic | 15.000 | 0.848 | 0.938 | 28.592 | 0.000 |
| gemini | 15.000 | 0.972 | 0.988 | 32.777 | 0.083 |
| ollama | 15.000 | 0.844 | 0.940 | 25.883 | 0.000 |
| all 45 configurations | 45.000 | 0.842 | 0.935 | 29.083 | 0.028 |

## Evaluation against CAP

| method | set | n | accuracy | brier | sens | spec | prev_hat | true_prev |
|---|---|---|---|---|---|---|---|---|
| Majority vote | validation | 200.000 | 0.970 | 0.030 | 0.970 | 0.970 | 0.340 | 0.330 |
| Majority vote | working, non-anchored | 570.000 | 0.954 | 0.046 | 0.952 | 0.955 | 0.309 | 0.291 |
| Dawid--Skene | validation | 200.000 | 0.960 | 0.040 | 1.000 | 0.940 | 0.370 | 0.330 |
| Dawid--Skene | working, non-anchored | 570.000 | 0.956 | 0.044 | 0.976 | 0.948 | 0.321 | 0.291 |
| CRE-LCM | validation | 200.000 | 0.970 | 0.031 | 1.000 | 0.955 | 0.361 | 0.330 |
| CRE-LCM | working, non-anchored | 570.000 | 0.960 | 0.039 | 0.946 | 0.965 | 0.300 | 0.291 |
| CRE-LCM, 5\% anchored | validation | 200.000 | 0.970 | 0.030 | 1.000 | 0.955 | 0.359 | 0.330 |
| CRE-LCM, 5\% anchored | working, non-anchored | 570.000 | 0.960 | 0.038 | 0.940 | 0.968 | 0.297 | 0.291 |

Dawid-Skene: prevalence 0.331, mean sensitivity 0.866, mean specificity 0.994. CAP prevalence in the sample: 0.300.

## Variance shares (CRE-LCM)

| quantity | q_mean | q_lo | q_hi | q_ess | q_rhat | anchored_mean | anchored_lo | anchored_hi |
|---|---|---|---|---|---|---|---|---|
| pi1 | 0.315 | 0.284 | 0.347 | 1159.536 | 1.013 | 0.311 | 0.281 | 0.343 |
| s_th | 5.635 | 4.945 | 6.455 | 8.351 | 1.420 | 5.579 | 4.994 | 6.202 |
| s_ph | 3.066 | 2.691 | 3.473 | 208.406 | 1.023 | 3.120 | 2.746 | 3.536 |
| s_ps | 2.887 | 2.583 | 3.223 | 64.630 | 1.052 | 2.867 | 2.582 | 3.176 |
| share_item | 0.600 | 0.525 | 0.673 | 8.050 | 1.457 | 0.593 | 0.534 | 0.648 |
| share_model | 0.179 | 0.136 | 0.230 | 16.167 | 1.183 | 0.186 | 0.147 | 0.230 |
| share_prompt | 0.159 | 0.124 | 0.199 | 9.599 | 1.343 | 0.157 | 0.129 | 0.189 |
| share_run | 0.063 | 0.052 | 0.074 | 12.193 | 1.246 | 0.063 | 0.054 | 0.074 |

## Per-configuration sensitivity / specificity

| model | prompt | sens | sens_lo | sens_hi | spec | spec_lo | spec_hi | sens_h | spec_h | sens_ds | spec_ds |
|---|---|---|---|---|---|---|---|---|---|---|---|
| anthropic | 1.000 | 0.879 | 0.845 | 0.908 | 0.977 | 0.965 | 0.987 | 0.917 | 0.948 | 0.922 | 0.991 |
| anthropic | 2.000 | 0.935 | 0.910 | 0.955 | 0.989 | 0.979 | 0.994 | 0.912 | 0.964 | 0.896 | 0.997 |
| anthropic | 3.000 | 0.753 | 0.709 | 0.794 | 0.984 | 0.973 | 0.991 | 0.765 | 0.977 | 0.741 | 0.999 |
| anthropic | 4.000 | 0.807 | 0.763 | 0.850 | 0.977 | 0.963 | 0.986 | 0.725 | 0.954 | 0.735 | 0.990 |
| anthropic | 5.000 | 0.854 | 0.817 | 0.884 | 0.970 | 0.956 | 0.981 | 0.924 | 0.934 | 0.935 | 0.979 |
| gemini | 1.000 | 0.981 | 0.968 | 0.990 | 0.987 | 0.978 | 0.993 | 0.979 | 0.952 | 0.981 | 0.996 |
| gemini | 2.000 | 0.992 | 0.984 | 0.997 | 0.994 | 0.988 | 0.997 | 0.961 | 0.959 | 0.950 | 0.996 |
| gemini | 3.000 | 0.948 | 0.924 | 0.969 | 0.991 | 0.984 | 0.995 | 0.971 | 0.948 | 0.980 | 0.995 |
| gemini | 4.000 | 0.964 | 0.944 | 0.979 | 0.986 | 0.976 | 0.993 | 0.983 | 0.950 | 0.992 | 0.996 |
| gemini | 5.000 | 0.975 | 0.960 | 0.987 | 0.981 | 0.970 | 0.990 | 0.983 | 0.943 | 0.996 | 0.993 |
| ollama | 1.000 | 0.821 | 0.781 | 0.859 | 0.984 | 0.975 | 0.991 | 0.811 | 0.967 | 0.784 | 0.990 |
| ollama | 2.000 | 0.898 | 0.862 | 0.930 | 0.992 | 0.985 | 0.996 | 0.949 | 0.967 | 0.922 | 0.996 |
| ollama | 3.000 | 0.665 | 0.622 | 0.707 | 0.989 | 0.981 | 0.994 | 0.654 | 0.969 | 0.647 | 0.994 |
| ollama | 4.000 | 0.733 | 0.687 | 0.780 | 0.984 | 0.972 | 0.991 | 0.799 | 0.965 | 0.785 | 0.994 |
| ollama | 5.000 | 0.790 | 0.744 | 0.826 | 0.978 | 0.965 | 0.988 | 0.731 | 0.973 | 0.719 | 1.000 |

## Posterior predictive check (agreement counts per bill)

| stat | observed | replicated_mean |
|---|---|---|
| mean count | 13.084 | 12.745 |
| SD of counts | 18.803 | 18.627 |
| share of bills with 0-5 | 0.651 | 0.661 |
| share with 40-45 | 0.204 | 0.206 |
| share with 15-30 (ambiguous) | 0.056 | 0.049 |

## Per-chain means (unanchored fit)

| parameter | X1 | X2 | X3 | X4 |
|---|---|---|---|---|
| pi1 | 0.316 | 0.317 | 0.311 | 0.316 |
| mu[1] | -14.542 | -14.603 | -14.370 | -14.516 |
| mu[2] | 6.980 | 6.936 | 7.447 | 6.980 |
| s_th | 6.050 | 5.307 | 5.663 | 5.521 |

## Temperature-0 sensitivity (prompt 1)

| model | acc_vs_CAP_T0 | acc_vs_CAP_T07_P1 | within_model_T07_P1_agreement |
|---|---|---|---|
| anthropic | 0.939 | 0.938 | 0.993 |
| gemini | 0.960 | 0.960 | 1.000 |
| ollama | 0.919 | 0.920 | 0.980 |

| pair | agreement_T0 |
|---|---|
| anthropic vs gemini | 0.964 |
| anthropic vs ollama | 0.927 |
| gemini vs ollama | 0.916 |

Figures: figures/Fig5 (calibration), figures/Fig6 (posterior predictive check). Tables: results/application/table8-11*.tex.
