---
layout: default
title: bayesianmice - Heterogeneity
---
---
**Visualizing Heterogeneity**

Figure 3a, 3b, 4a, 4b | Heterogeneity in effects across the antibiotic, cytokine and colonization models.


Plot below show the median effect size of each variable (bacteria, fungi, experimental) against its posterior inclusion probability (PIP) in the following BMA models:
!TOC

PIP is expressed in %. The effect size of a microbe is its regression coefficient in the model and depends on its relative abundance under antibiotic treatment (PSG or Van.) relative to controls (Cntrl), after adjusting for all the other covariables in the model. We show only the effects that were statistically significant i.e. the corresponding Bayesian 95% CIs did not include zero. Higher PIPs indicate higher consistency in antibiotic effects. PIPs can range from 0% (not consistent) to 100% (very highly consistent). All models were built at the genus level. Each point in the graph denotes a genus coloured by its phylum membership.

---
#### Antibiotic models

![Heterogeneity in the effect of PSG and vancomycin on the bacterial community.](assets/figures/heterogeneity_anti_bact.svg)

![Heterogeneity in the effect of PSG and vancomycin on fungal community.](assets/figures/heterogeneity_anti_fung.svg)

---

#### Cytokine models
![Heterogeneity in the effect of bacteria and antibiotics on cytokines.](assets/figures/heterogeneity_cyto_bact.svg)

![Heterogeneity in the effect of fungi and antibiotics on cytokines.](assets/figures/heterogeneity_cyto_fung.svg)

---
#### Colonization models
![Heterogeneity in the effect of bacteria and cytokines on _C. albicans_ colonization.](assets/figures/heterogeneity_cfu_bact.svg)

![Heterogeneity in the effect of fungi and cytokines on _C. albicans_ colonization.](assets/figures/heterogeneity_cfu_fung.svg)
