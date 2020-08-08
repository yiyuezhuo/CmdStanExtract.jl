![CmdStanExtract](https://github.com/yiyuezhuo/CmdStanExtract/workflows/CmdStanExtract/badge.svg)

# CmdStanExtract

Provide `rstan/pystan`-like `extract` for `CmdStan.jl`.

This package will not do `shuffle` for samples, since many suspect why is done for `rstan/pystan` which impede the possibility to find coverage problem by barely looking on (naive) trace plot (I personally must call `ArviZ` to draw trace plot and find it very annoying).

## Usage

```julia
# Some CmdStan setup...
rc, chn, cnames = stan(stanmodel, standata)
extract(chn, cnames) # 
```

Eight-schools

```julia
using CmdStan
using CmdStanExtract

eightschools ="
data {
    int<lower=0> J; // number of schools
    real y[J]; // estimated treatment effects
    real<lower=0> sigma[J]; // s.e. of effect estimates
}
parameters {
    real mu;
    real<lower=0> tau;
    real eta[J];
}
transformed parameters {
    real theta[J];
    for (j in 1:J)
        theta[j] <- mu + tau * eta[j];
}
model {
    eta ~ normal(0, 1);
    y ~ normal(theta, sigma);
}
"

schools8data = Dict("J" => 8,
    "y" => [28,  8, -3,  7, -1,  1, 18, 12],
    "sigma" => [15, 10, 16, 11,  9, 11, 10, 18],
    "tau" => 25
)

global stanmodel, rc, chn, chns, cnames, tmpdir
tmpdir = mktempdir()

stanmodel = Stanmodel(name="schools8", model=eightschools,
tmpdir=tmpdir);

rc, chn, cnames = stan(stanmodel, schools8data)

ex_dict = extract(chn, cnames)
keys(ex_dict)
#=
Base.KeySet for a Dict{String,Array} with 11 entries. Keys:
  "accept_stat__"
  "tau"
  "mu"
  "theta"
  "divergent__"
  "energy__"
  "eta"
  "treedepth__"
  "n_leapfrog__"
  "lp__"
  "stepsize__"
=#

size(ex_dict["tau"])
# (1000, 4) # (draws, chains)

size(ex_dict["theta"])
# (8, 1000, 4) # (size..., draws, chains)

mean(ex_dict["theta"], dims=(2,3))
#=
8×1×1 Array{Float64,3}:
[:, :, 1] =
 11.387164502072487
  7.826174302174989
  6.001198451883997
  7.619045541185006
  5.1535167093724965
  6.135485434667978
 10.592773512799969
  8.31159470832773
=#
```