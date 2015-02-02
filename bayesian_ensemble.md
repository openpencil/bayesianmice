---
layout: default
title: The YAP Workflow
---
---
**Ensemble Bayesian modeling**

!TOC

##### Preliminary data processing

After confirming that each of the two independent experimental
replicates showed similar trends, sequence count data and the cytokine
expression data from these two independent replications were combined
for all the downstream analytical steps. The analyses that included the bacterial
microbiome was performed using 30 mice; 10 in each treatment group while
those with the fungal microbiome was performed on 36 mice; 12 in each
treatment group. The GAPDH normalized cytokine mRNA expression levels
and genera level relative abundances of sequences were log transformed
to bring the numerical attributes of the dataset into the same dynamic range.

##### Bayesian model averaging
All multivariable statistical models were estimated using Bayesian model
averaging (BMA)[^1]. with a spike-and-slab prior
distribution[^2] implemented in the [BoomSpikeSlab][Boom] R
package[^3],[^4]. The spike prior is based on an
assumption that a sparse set of variables can explain the response. It
consists of a Bernoulli distribution that specifies whether or not a
variable is selected as influential. The slab prior is a Gaussian
distribution that models the effect sizes of the variables, conditional
on their being chosen as influential.

</br>
BMA combines information from these two priors and uses a Markov Chain
Monte Carlo procedure to compute a space of likely variable
configurations that explain the response[^5]. The
10,000 most likely models from this space are retained. The median
effect size and its associated 95% Bayesian CI for each variable was
computed using the distribution of its regression coefficient across the
10,000 models. The Bayesian 95% CI was free of distributional
assumptions. The initial 1,000 models were excluded as burn-in[^6].
The posterior inclusion probability (PIP) for each
variable is the proportion of the models that selected the variable as
influential. In our findings, the median effect size and its 95%
Bayesian CI and the PIP are presented as the two formal measures of
statistical significance and consistency for each variable.

##### BMA model specifications
Three separate sets of BMA models were estimated: a) logistic regression
with antibiotic treatment (PSG or vancomycin) as response and controls
as reference; linear regression with b) log(mRNA cytokine expression) as
response, and c) colonization levels measured in log(CFU) as response.
These models were used to evaluate a) impact of antibiotics on specific
microbiota and the immune response, b) influence of specific microbiota
on cytokine mRNA expression c) the role of specific microbiota and
cytokine mRNA expression on the level of _C. albicans_
colonization. In each model, antibiotic treatment, exposure to _C.
albicans_, and time-points of sampling were included as indicator
variables. Mice in control groups served as the reference baseline. Each
bacterial model~ was estimated from 30 mice, 10 in each treatment group
(controls, vancomycin and PSG). Each fungal model was estimated from 36
mice, 12 in each treatment group. All data analyses were performed in
the [R language for statistical computing][RLang][^7].

##### References
[^1]: Hoeting, J. A., Madigan, D., Raftery, A. E. & Volinsky, C. T. Bayesian Model Averaging: A Tutorial. Stat. Sci. 14, 382--417 (1999).

[^2]: George, E. I. & Mcculloch, R. E. Approaches for Bayesian variable selection. in Statistica Sinica, 7, 339--373 (1997).

[^3]: Scott, S. L. & Varian, H. R. Predicting the Present with Bayesian Structural Time Series. IJMNO 5, 4+ (2013).

[^4]: Scott, S. L. _BoomSpikeSlab_: MCMC for spike-and-slab regression. (CRAN, 2014).

[^5]: George, E. I. & Mcculloch, R. E. Approaches for Bayesian variable selection. in Statistica Sinica, 7, 339--373 (1997).

[^6]: Scott, S. L. & Varian, H. R. Predicting the Present with Bayesian Structural Time Series. IJMNO 5, 4+ (2013).

[^7]: R Development Core Team. _R: A Language and Environment for Statistical Computing_.(R Foundation for Statistical Computing, 2014).

<!-- Websites -->
[Boom]: http://CRAN.R-project.org/package=BoomSpikeSlab "Bayesian Object Oriented Modeling for spike-and-slab regression."
[RLang]: http://www.R-project.org/ "The R language and environment for statistical computing."


<!--Google Analytics Code-->
[![Analytics](https://ga-beacon.appspot.com/UA-59204692-1/bayesianmice/gh-pages/bayesian_ensemble?pixel)](https://github.com/igrigorik/ga-beacon)
