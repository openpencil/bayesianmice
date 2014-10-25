---
layout: default
title: The YAP Workflow
---
---
**The YAP Bioinformatics Workflow Engine**

<span style="color:gray;">Author: [Sebastian Szpakowski][shpakoo]</span>
!TOC

##### Computationally efficient 16S and ITS Reads Processing and Taxonomic Classification

Taxonomic classification of the 16S and ITS sequences was performed using [YAP][YAP], a computationally optimized bioinformatics workflow.  The workflow was run on a distributed computing cluster managed by the [Univa Grid Engine][Univa].

######Preliminary Processing and Quality Checks
Within YAP, the 454 sequencer-generated SFF files were converted into FASTA and qual files using [sffinfo from the Roche SFF Tools software package][sffinfo]. After demultiplexing the sequences with mothur([^1]), quality filtering of the sequences was performed using mothur’s implementation of PyroNoise([^2],[^3]). Sequences shorter than 220 bases were discarded([^4]) and sequences spanning the V4 and the V5 regions of the 16S rDNA were retained. Duplicate sequences were collapsed and 454 hybrid sequences were removed with CD-HIT-454([^5a],[^6]). The sequences were then aligned against the 16S SILVA database to verify their 16S origins and to ensure that the sequences were correctly positioned on the V4 and V5 regions([^7]). Using the uchime implementation in mothur and the 16S SILVA database, multi-organism hybrid-sequences and chimeras were discarded([^8]). Segments with coverage lower than 90% of the maximum coverage were trimmed from the sequences.

###### Clustering and Taxonomic Assignment
CD-HIT-EST, a module of the CD-HIT suite, was used to cluster the sequences at the 97% similarity level to produce operational taxonomic units (OTU)([^5b],[^9]). Taxonomical classification of the final set of reads was performed using mothur’s implementation of a naive Bayes classifier([^10]) trained on a normalized RDP training dataset([^11]). Sequence counts for any given taxon were obtained by summing the cluster sizes of all OTUs that were classified as that taxon.

##### Resolution of unclassified sequences
For OTUs that remained unclassified at the genus level after processing through YAP, genus labels were assigned using the NCBI Megablast algorithm([^12a]). Final genus labels were the ones with the lowest E-value. In addition, for sequences assigned to a given genus of interest, for example, Candida, the most predominant species-level taxonomic labels were identified using the NCBI Megablast algorithm([^12b]). Predominant species were the ones that were most frequent within a particular genus, belonged to the largest OTU clusters, occurred in the largest number of mice samples and obtained the lowest E-value in the Megablast algorithm.

##### 16S and ITS Databases.  

Within the YAP workflow, high quality databases were used to a) verify the origin of the 16S and ITS sequences, b) check for chimeras and c) assign taxonomies. For bacterial 16S processing and assignment, the SILVA database([^13]) and a training dataset from the RDP project([^14]) were used. For ITS, a custom database was built as described below. A seed database of the entire fungal ribosomal region was first constructed. This seed database consisted of 236 diverse ribosomal sequences and was obtained by running NT BLAST on a 7785 nucleotide long, annotated ribosomal region of Aspergillus fumigatus Af293([^15],[^12c]). The seed database was aligned using T-coffee([^16]). Next, a total of 155,136 unique ITS sequences were retrieved from the NCBI public database. The program MUSCLE was used to align these ITS sequences to the seed database and orient them in the 5’ to 3’ direction ([^17]). Over 5% of sequences were re-oriented. Based on the alignment scores, either the original or the reverse complements of these sequences were retained for further processing. To improve taxonomic classification, identical sequences as well as substrings were clustered using CD-HIT in two iterations ([^5c]). The first iteration, with 100% sequence identity, yielded 149,266 clusters. The second iteration, using 97% sequence identity, yielded 39,548 species level clusters. After two iterations of clustering, annotations were reassigned for 2,153 sequences. A total of 10,226 sequences were still taxonomically identified as “uncultured”. In the final step, the NCBI sequence IDs of the properly oriented exemplars of the clusters were queried against the NCBI taxonomy database to obtain the maximum possible resolution of taxonomic levels for the poorly annotated sequences ([^18]).

<!--Websites-->
[shpakoo]: http://scholar.google.com/citations?user=iudoLVMAAAAJ "Sebastian Szpakowski"

[YAP]: https://github.com/shpakoo/YAP "Szpakowski S. YAP: A Computationally Efficient Workflow for Taxonomic Analyses of Bacterial 16S and Fungal ITS Sequences . GitHub; 2013."

[Univa]: http://www.univa.com/products/grid-engine "Univa Products: Grid Engine Software for Workload Scheduling and Management."

[sffinfo]: goo.gl/SHvf6e "sffinfo command from the Roche SFF Tools software package"

[mothur]: http://www.mothur.org/ "mothur: open-source, platform-independent,community-supported software for describing and comparing microbial communities."

[CD-HIT-454]:http://weizhong-lab.ucsd.edu/cd-hit/


#### References
[^1]: Schloss PD, Westcott SL, Ryabin T, Hall JR, Hartmann M, Hollister EB, et al. Introducing mothur: open-source, platform-independent, community-supported software for describing and comparing microbial communities. Appl Environ Microbiol. American Society for Microbiology; 2009 Dec 1;75(23):7537–41. Available from: http://dx.doi.org/10.1128/AEM.01541-09

[^2]: Quince C, Lanzen A, Davenport RJ, Turnbaugh PJ. Removing noise from pyrosequenced amplicons. BMC Bioinformatics . 2011 Jan 28;12(1):38+. Available from: http://dx.doi.org/10.1186/1471-2105-12-38

[^3]: Schloss PD, Gevers D, Westcott SL. Reducing the effects of PCR amplification and sequencing artifacts on 16S rRNA-based studies. PLoS One . Public Library of Science; 2011 Dec 14;6(12):e27310+. Available from: http://dx.doi.org/10.1371/journal.pone.0027310
[^4]: Engelbrektson A, Kunin V, Wrighton KC, Zvenigorodsky N, Chen F, Ochman H, et al. Experimental factors affecting PCR-based estimates of microbial species richness and evenness. ISME J . Nature Publishing Group; 2010 May 21;4(5):642–7. Available from: http://dx.doi.org/10.1038/ismej.2009.153
[^5a]: Huang Y, Niu B, Gao Y, Fu L, Li W. CD-HIT Suite: a web server for clustering and comparing biological sequences. Bioinformatics . Oxford University Press; 2010 Mar 1;26(5):680–2. Available from: http://dx.doi.org/10.1093/bioinformatics/btq003
[^5b]: Huang Y, Niu B, Gao Y, Fu L, Li W. CD-HIT Suite: a web server for clustering and comparing biological sequences. Bioinformatics . Oxford University Press; 2010 Mar 1;26(5):680–2. Available from: http://dx.doi.org/10.1093/bioinformatics/btq003
[^5c]: Huang Y, Niu B, Gao Y, Fu L, Li W. CD-HIT Suite: a web server for clustering and comparing biological sequences. Bioinformatics . Oxford University Press; 2010 Mar 1;26(5):680–2. Available from: http://dx.doi.org/10.1093/bioinformatics/btq003
[^6]: Niu B, Fu L, Sun S, Li W. Artificial and natural duplicates in pyrosequencing reads of metagenomic data. BMC Bioinformatics . BioMed Central; 2010 Apr 13;11(1):1–11. Available from: http://dx.doi.org/10.1186/1471-2105-11-187
[^7]: Pruesse E, Quast C, Knittel K, Fuchs BM, Ludwig W, Peplies J, et al. SILVA: a comprehensive online resource for quality checked and aligned ribosomal RNA sequence data compatible with ARB. Nucleic Acids Res . Oxford University Press; 2007 Oct 18;35(21):7188–96. Available from: http://dx.doi.org/10.1093/nar/gkm864
[^8]: Haas BJ, Gevers D, Earl AM, Feldgarden M, Ward DV, Giannoukos G, et al. Chimeric 16S rRNA sequence formation and detection in Sanger and 454-pyrosequenced PCR amplicons. Genome Res . Cold Spring Harbor Laboratory Press; 2011 Mar 1;21(3):494–504. Available from: http://dx.doi.org/10.1101/gr.112730.110
[^9]: Hamady M, Knight R. Microbial community profiling for human microbiome projects: Tools, techniques, and challenges. Genome Res . Cold Spring Harbor Laboratory Press; 2009 Jul 1;19(7):1141–52. Available from: http://dx.doi.org/10.1101/gr.085464.108
[^10]: Wang Q, Garrity GM, Tiedje JM, Cole JR. Na"ive Bayesian Classifier for Rapid Assignment of rRNA Sequences into the New Bacterial Taxonomy. Appl Environ Microbiol . Center for Microbial Ecology, Michigan State University, East Lansing, MI 48824, USA.: American Society for Microbiology; 2007 Aug 15;73(16):5261–7. Available from: http://dx.doi.org/10.1128/aem.00062-07
[^11]: Lan Y, Wang Q, Cole JR, Rosen GL. Using the RDP classifier to predict taxonomic novelty and reduce the search space for finding novel organisms. PLoS One . 2012 Mar 5;7(3):e32491. Available from: http://dx.doi.org/10.1371/journal.pone.0032491
[^12a]: Camacho C, Coulouris G, Avagyan V, Ma N, Papadopoulos J, Bealer K, et al. BLAST+: architecture and applications. BMC Bioinformatics . 2009 Dec 15;10(1):421+. Available from: http://dx.doi.org/10.1186/1471-2105-10-421
[^12b]: Camacho C, Coulouris G, Avagyan V, Ma N, Papadopoulos J, Bealer K, et al. BLAST+: architecture and applications. BMC Bioinformatics . 2009 Dec 15;10(1):421+. Available from: http://dx.doi.org/10.1186/1471-2105-10-421
[^12c]: Camacho C, Coulouris G, Avagyan V, Ma N, Papadopoulos J, Bealer K, et al. BLAST+: architecture and applications. BMC Bioinformatics . 2009 Dec 15;10(1):421+. Available from: http://dx.doi.org/10.1186/1471-2105-10-421
[^13]: Quast C, Pruesse E, Yilmaz P, Gerken J, Schweer T, Yarza P, et al. The SILVA ribosomal RNA gene database project: improved data processing and web-based tools. Nucleic Acids Res . Oxford University Press; 2013 Jan 1;41(Database issue):D590–D596. Available from: http://dx.doi.org/10.1093/nar/gks1219
[^14]: Cole JR, Wang Q, Cardenas E, Fish J, Chai B, Farris RJ, et al. The Ribosomal Database Project: improved alignments and new tools for rRNA analysis. Nucleic Acids Res . Oxford University Press; 2009 Jan 1;37(Database issue):D141–D145. Available from: http://dx.doi.org/10.1093/nar/gkn879
[^15]: Arnaud MB, Cerqueira GC, Inglis DO, Skrzypek MS, Binkley J, Chibucos MC, et al. The Aspergillus Genome Database (AspGD): recent developments in comprehensive multispecies curation, comparative genomics and community resources. Nucleic Acids Res . Oxford University Press; 2012 Jan 1;40(Database issue):D653–D659. Available from: http://dx.doi.org/10.1093/nar/gkr875
[^16]: Notredame C, Higgins DG, Heringa J. T-Coffee: A novel method for fast and accurate multiple sequence alignment. J Mol Biol . National Institute for Medical Research, The Ridgeway, London, NW7 1AA, UK. cedric.notredame@europe.com; 2000 Sep 8;302(1):205–17. Available from: http://dx.doi.org/10.1006/jmbi.2000.4042
[^17]: Edgar RC. MUSCLE: multiple sequence alignment with high accuracy and high throughput. Nucleic Acids Res . bob@drive5.com: Oxford University Press; 2004 Mar 19;32(5):1792–7. Available from: http://dx.doi.org/10.1093/nar/gkh340
[^18]: Benson DA, Karsch-Mizrachi I, Lipman DJ, Ostell J, Sayers EW. GenBank. Nucleic Acids Res . 2009 Jan 1;37(Database issue):D26–31. Available from: http://dx.doi.org/10.1093/nar/gkn723
