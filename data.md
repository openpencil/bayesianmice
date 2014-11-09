---
layout: default
title: Data
active: data
---
---

**Data**

!TOC

#### Data Description
Characteristics of data from the mouse microbiome study. _C. albicans_ colonization level was measured by counting the Colony forming units (CFU) following quantitative culture of the fecal pellets. Cytokine mRNA expression (mRNA) was measured in the terminal ileum samples. Bacterial 16S and Fungal ITS were amplified from both the terminal ileum (TI) sections and the fecal pellets (FP). These amplicons were then sequenced by 454 pyrosequencing and taxonomically classified with [a tailored bioinformatic pipeline][Docs][^1].

#### Datasets
| Data type | Original  | Processed | Dimension | GI site|
|----------|--------------------|----------------|-----------|---------------|
| [16S]({{ site.baseurl }}/assets/bayesianmice_16s_fecal_dataset_10252014JS.csv) |Counts | \\(log\\) (Relative abundances) | 344 | Fecal pellets|
| [16S]({{ site.baseurl }}/assets/bayesianmice_16s_ileum_dataset_10252014JS.csv) |Counts | \\(log\\) (Relative abundances) | 344 | Terminal ileum|
| [ITS]({{ site.baseurl }}/assets/bayesianmice_its_fecal_dataset_10252014JS.csv) |Counts | \\(log\\) (Relative abundances) | 109 | Fecal pellets|
| [ITS]({{ site.baseurl }}/assets/bayesianmice_its_ileum_dataset_10252014JS.csv) |Counts | \\(log\\) (Relative abundances) | 109 | Terminal ileum|
| [mRNA]({{ site.baseurl }}/assets/bayesianmice_cmrna_dataset_10252014JS.csv) |Expression levels | \\(log\\) (GAPDH norm.)| 6 | Terminal ileum|
| [CFU]({{ site.baseurl }}/assets/bayesianmice_cfu_dataset_10252014JS.csv) |Counts | \\(log \left( \frac{CFU}{\text{g fecal matter}}\right)\\) |1 | Fecal pellets|
| Antibiotics | | | ||
| \\(\pm\\) _C. albicans_ | | | ||
|\\(+\\) Length Rx| Categorical|Indicators |5 |-|
||||||

<br/>
#### References
[^1]: Szpakowski S. YAP: A Computationally Efficient Workflow for Taxonomic Analyses of Bacterial 16S and Fungal ITS Sequences. GitHub. 2013.


<!--URL-->
[Docs]: {{ site.baseurl }}/yap_workflow.html
