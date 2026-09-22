// crossed_lcre_a_classscale.stan  -- variant (a)
// As crossed_lcre.stan, but the item ambiguity effect theta_i enters with a
// CLASS-SPECIFIC scale s_th[k] (Qu, Tan & Kutner 1996, Biometrics 52:797-810):
//   logit P(Y = 1 | c_i = k) = mu_k + a_mk + b_pk + s_th[k] * z_i + phi_im + psi_ip
// The shared standard-normal factor z_i is loaded differently in each class,
// which lets the data decide how much "everyone says 1" reflects ambiguity in
// class 0 versus class 1 rather than forcing one common scale.

data {
  int<lower=1> N;
  int<lower=1> M;
  int<lower=1> P;
  int<lower=1> R;
  array[N, M, P] int<lower=0, upper=R> S;
}

parameters {
  real<lower=0, upper=1> pi1;
  ordered[2] mu;
  matrix[M - 1, 2] a_raw;
  matrix[P, 2] b_z;
  vector<lower=0>[2] tau_b;
  vector<lower=0>[2] s_th;             // class-specific item ambiguity SD
  real<lower=0> s_ph;
  real<lower=0> s_ps;
  vector[N] th_z;
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
  mu ~ normal(0, 2);
  to_vector(a_raw) ~ normal(0, 1);
  to_vector(b_z) ~ std_normal();
  tau_b ~ normal(0, 0.5);
  s_th ~ normal(0, 1);
  s_ph ~ normal(0, 1);
  s_ps ~ normal(0, 1);
  th_z ~ std_normal();
  to_vector(ph_z) ~ std_normal();
  to_vector(ps_z) ~ std_normal();

  for (i in 1:N) {
    vector[2] lp = [log1m(pi1), log(pi1)]';
    for (m in 1:M) for (p in 1:P) {
      real u = s_ph * ph_z[i, m] + s_ps * ps_z[i, p];
      for (k in 1:2)
        lp[k] += binomial_logit_lpmf(S[i, m, p] | R, mu[k] + a[m, k] + b[p, k] + s_th[k] * th_z[i] + u);
    }
    target += log_sum_exp(lp);
  }
}

generated quantities {
  vector[N] post1;
  vector[N] log_lik;
  real v_res = square(pi()) / 3;
  // prevalence-weighted item variance so that shares remain comparable
  real v_th = (1 - pi1) * square(s_th[1]) + pi1 * square(s_th[2]);
  real v_tot = v_th + square(s_ph) + square(s_ps) + v_res;
  real share_item   = v_th / v_tot;
  real share_model  = square(s_ph) / v_tot;
  real share_prompt = square(s_ps) / v_tot;
  real share_run    = v_res / v_tot;
  for (i in 1:N) {
    vector[2] lp = [log1m(pi1), log(pi1)]';
    for (m in 1:M) for (p in 1:P) {
      real u = s_ph * ph_z[i, m] + s_ps * ps_z[i, p];
      for (k in 1:2)
        lp[k] += binomial_logit_lpmf(S[i, m, p] | R, mu[k] + a[m, k] + b[p, k] + s_th[k] * th_z[i] + u);
    }
    log_lik[i] = log_sum_exp(lp);
    post1[i] = exp(lp[2] - log_lik[i]);
  }
}
