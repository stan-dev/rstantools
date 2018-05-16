data {
  real x;
}

parameters {
  real<lower=0> sigma;
}

model {
  x ~ normal(0, sigma);
}
