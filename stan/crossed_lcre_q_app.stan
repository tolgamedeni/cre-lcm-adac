// crossed_lcre_q_app.stan -- application version of the quadrature model
// (prior scales for mu, the three SDs and tau_b are passed as data)
// (crossed_lcre_q_quad.stan) with two additions needed for real annotations:
//   * the number of valid runs varies by (item, model, prompt): R_imp is data
//     (runs whose answer could not be parsed are missing at random);
//   * an optional set of anchored items with known class (N_anchor may be 0):
//     for those items only the known-class likelihood contributes.
data {
  int<lower=1> N;
  int<lower=1> M;
  int<lower=1> P;
  array[N, M, P] int<lower=0> R_imp;          // valid runs
  array[N, M, P] int<lower=0> S;              // runs labelled 1 (S <= R_imp)
  int<lower=1> Q;
  vector[Q] x_q;
  vector[Q] log_w_q;
  int<lower=0, upper=N> N_anchor;
  array[N_anchor] int<lower=1, upper=N> anchor_idx;
  array[N_anchor] int<lower=0, upper=1> anchor_lab;
  real<lower=0> prior_mu_sd;                  // N(0, prior_mu_sd) on the class intercepts (2 in the simulations)
  real<lower=0> prior_s_sd;                   // half-normal(0, prior_s_sd) on s_th, s_ph, s_ps (1 in the simulations)
  real<lower=0> prior_tau_sd;                 // half-normal(0, prior_tau_sd) on tau_b (0.5 in the simulations)
}
transformed data {
  int MP = M * P;
  array[N, MP] int Sv;
  array[N, MP] int Rv;
  array[N] int known = rep_array(-1, N);
  for (i in 1:N) for (m in 1:M) for (p in 1:P) { Sv[i, (m - 1) * P + p] = S[i, m, p]; Rv[i, (m - 1) * P + p] = R_imp[i, m, p]; }
  for (j in 1:N_anchor) known[anchor_idx[j]] = anchor_lab[j];
}
parameters {
  real<lower=0, upper=1> pi1;
  ordered[2] mu;
  matrix[M - 1, 2] a_raw;
  matrix[P, 2] b_z;
  vector<lower=0>[2] tau_b;
  real<lower=0> s_th;
  real<lower=0> s_ph;
  real<lower=0> s_ps;
  matrix[N, M] ph_z;
  matrix[N, P] ps_z;
}
transformed parameters {
  matrix[M, 2] a;
  matrix[P, 2] b;
  a[1] = rep_row_vector(0, 2);
  if (M > 1) a[2:M] = a_raw;
  for (k in 1:2) b[, k] = tau_b[k] * b_z[, k];
}
model {
  pi1 ~ beta(1, 1);
  mu ~ normal(0, prior_mu_sd);
  to_vector(a_raw) ~ normal(0, 1);
  to_vector(b_z) ~ std_normal();
  tau_b ~ normal(0, prior_tau_sd);
  s_th ~ normal(0, prior_s_sd);
  s_ph ~ normal(0, prior_s_sd);
  s_ps ~ normal(0, prior_s_sd);
  to_vector(ph_z) ~ std_normal();
  to_vector(ps_z) ~ std_normal();
  {
    matrix[MP, 2] fixed;
    for (m in 1:M) for (p in 1:P) for (k in 1:2) fixed[(m - 1) * P + p, k] = mu[k] + a[m, k] + b[p, k];
    vector[2] log_pi = [log1m(pi1), log(pi1)]';
    for (i in 1:N) {
      vector[MP] u;
      for (m in 1:M) for (p in 1:P) u[(m - 1) * P + p] = s_ph * ph_z[i, m] + s_ps * ps_z[i, p];
      vector[2] lk;
      for (k in 1:2) {
        vector[Q] lq;
        for (q in 1:Q) lq[q] = log_w_q[q] + binomial_logit_lpmf(Sv[i] | Rv[i], fixed[, k] + u + s_th * x_q[q]);
        lk[k] = log_pi[k] + log_sum_exp(lq);
      }
      if (known[i] < 0) target += log_sum_exp(lk);
      else              target += lk[known[i] + 1];
    }
  }
}
generated quantities {
  vector[N] post1;
  vector[N] log_lik;
  array[N, MP] int S_rep;                     // posterior predictive replicate of the counts
  real v_res = square(pi()) / 3;
  real v_tot = square(s_th) + square(s_ph) + square(s_ps) + v_res;
  real share_item   = square(s_th) / v_tot;
  real share_model  = square(s_ph) / v_tot;
  real share_prompt = square(s_ps) / v_tot;
  real share_run    = v_res / v_tot;
  {
    matrix[MP, 2] fixed;
    for (m in 1:M) for (p in 1:P) for (k in 1:2) fixed[(m - 1) * P + p, k] = mu[k] + a[m, k] + b[p, k];
    vector[2] log_pi = [log1m(pi1), log(pi1)]';
    for (i in 1:N) {
      vector[MP] u;
      for (m in 1:M) for (p in 1:P) u[(m - 1) * P + p] = s_ph * ph_z[i, m] + s_ps * ps_z[i, p];
      vector[2] lk;
      for (k in 1:2) {
        vector[Q] lq;
        for (q in 1:Q) lq[q] = log_w_q[q] + binomial_logit_lpmf(Sv[i] | Rv[i], fixed[, k] + u + s_th * x_q[q]);
        lk[k] = log_pi[k] + log_sum_exp(lq);
      }
      if (known[i] < 0) { log_lik[i] = log_sum_exp(lk); post1[i] = exp(lk[2] - log_lik[i]); }
      else              { log_lik[i] = lk[known[i] + 1]; post1[i] = known[i]; }
      // replicate: draw class, item effect, then counts
      int c = bernoulli_rng(post1[i]);
      real th = normal_rng(0, s_th);
      for (j in 1:MP) S_rep[i, j] = binomial_rng(Rv[i, j], inv_logit(fixed[j, c + 1] + u[j] + th));
    }
  }
}
