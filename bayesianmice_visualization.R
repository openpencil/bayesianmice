##*******************************************************************************
##  For complete background and details, please refer to:
##  Shankar, J. et al. Using Bayesian modelling to investigate factors governing 
##  antibiotic-induced Candida albicans colonization of the GI tract. 
##  Sci. Rep. 5, 8131; DOI:10.1038/srep08131 (2015).
##  
##  Additional Documentation is at:
##  http://openpencil.github.io/bayesianmice/
## 
##  Visualization was performed under the following environment:
## 
## > sessionInfo()
## R version 3.1.1 (2014-07-10)
## Platform: x86_64-apple-darwin13.1.0 (64-bit)
## 
## locale:
## [1] en_US.UTF-8/en_US.UTF-8/en_US.UTF-8/C/en_US.UTF-8/en_US.UTF-8
## 
## attached base packages:
## [1] grid      stats     graphics  grDevices utils     datasets  methods   base     
## 
## other attached packages:
## [1] RColorBrewer_1.0-5 plyr_1.8.1         scales_0.2.4       reshape_0.8.5     
## [5] ggplot2_1.0.0      data.table_1.9.2  
## 
## loaded via a namespace (and not attached):
## [1] colorspace_1.2-4 digest_0.6.4     gtable_0.1.2     labeling_0.3    
## [5] MASS_7.3-34      munsell_0.4.2    proto_0.3-10     Rcpp_0.11.2     
## [9] reshape2_1.4     stringr_0.6.2    tools_3.1.1
##
##
##*******************************************************************************

##### 1. Load required libraries and set work directories #####
path <- Sys.getenv("HOME")

## Sets the work directory to /home/bayesianmice
setwd(paste(path, "/bayesianmice", sep = ""))

## Install and load specified packages
installloadpkgs <- function(pkgs) {
    # check packages installed
    pkgs_miss <- pkgs[which(!pkgs %in% installed.packages()[, 1])]
    if (length(pkgs_miss) > 0) {
        install.packages(pkgs_miss)
    } else if (length(pkgs_miss) == 0) {
        message("\n ...Packages were already installed!\n")
    }
    # install packages not already loaded:
    pkgs_miss <- pkgs[which(!pkgs %in% installed.packages()[, 1])]
    if (length(pkgs_miss) > 0) {
        install.packages(pkgs_miss)
    }
    # load packages not already loaded:
    attached <- search()
    attached_pkgs <- attached[grepl("package", attached)]
    need_to_attach <- pkgs[which(!pkgs %in% gsub("package:", "", attached_pkgs))]
    if (length(need_to_attach) > 0) {
        # alternative to library
        for (i in 1:length(need_to_attach)) {
            require(need_to_attach[i], character.only = TRUE)
        }
    }
    if (length(need_to_attach) == 0) {
        message("\n ...Packages were already loaded!\n")
    }
}

installloadpkgs(c("data.table", "ggplot2", "grid", "reshape", "scales", "plyr", "RColorBrewer"))

##### 2. Load bayesianmice project data, annotations as well as BMA modeling results #####

## BMA results ##
betainfo <- readRDS("./data/bayesianmice_bma_model_results.RDS")

## Phyla names ##
allphyla <- readRDS("./data/phylainformation.RDS")

## Heatmap taxa order ##
bactfecalhm <- read.csv("./data/bact_fecal_heatmaporder.csv", as.is = T, header = F)
bactileumhm <- read.csv("./data/bact_ileum_heatmaporder.csv", as.is = T, header = F)
fungfecalhm <- read.csv("./data/fung_fecal_heatmaporder.csv", as.is = T, header = F)
fungileumhm <- read.csv("./data/fung_ileum_heatmaporder.csv", as.is = T, header = F)

## Final Unclassified resolution from BLAST ##
bactuncl <- read.csv("./data/bact_unclassified_blast.csv", as.is = T, header = F)
funguncl <- read.csv("./data/fung_unclassified_blast.csv", as.is = T, header = F)
colnames(bactuncl) <- c("oldname", "newname")
colnames(funguncl) <- c("oldname", "newname")
rownames(bactuncl) <- bactuncl$oldname
rownames(funguncl) <- funguncl$oldname
bactfunguncl <- rbind(bactuncl, funguncl)

## Sequence read data ##
finaldatalists <- readRDS("./data/finaldatalists.RDS")

## CFU data ##
cfubactall <- read.csv("./data/cfu_bact_alldays.csv", as.is = T, header = T)

## Cytokine expression data ##
cytodata <- read.csv("./data/cytokine_expression_data.csv", as.is = T, header = T)

##### 3. Formatting and colours for the visualization #####

## a. Light grey ggplot theme ##
lightertheme <- theme(text = element_text(family = "Helvetica", colour = "black", size = 12), 
                      panel.background = element_rect(fill = "#f5f5f4", colour = "#fbfbfc"), 
                      panel.border = element_rect(colour = "grey80", linetype = "solid", fill = NA), 
                      panel.grid.major = element_line(colour = "grey90", size = 0.08), 
                      panel.grid.minor = element_line(colour = "grey90", size = 0.08), 
                      panel.margin = unit(0.3, "lines"), 
                      plot.margin = unit(c(1.5, 2, 1, 1), "mm"), 
                      plot.title = element_text(size = 10, colour = "black"), 
                      plot.background = element_rect(fill = "transparent"), 
                      strip.background = element_rect(fill = "transparent", color = "transparent", size = 1), 
                      strip.text.x = element_text(size = 10, colour = "black"), 
                      strip.text.y = element_text(size = 10, colour = "black"), 
                      axis.text.x = element_text(size = 10, colour = "black"), 
                      axis.text.y = element_text(size = 10, colour = "black"), 
                      axis.title.y = element_text(size = 10, colour = "black", vjust = 0.5), 
                      axis.title.x = element_text(size = 10, colour = "black", vjust = 0.5), 
                      legend.position = "left", legend.background = element_rect(fill = "transparent"), 
                      legend.background = element_blank(), legend.key = element_blank(), 
                      legend.key.size = unit(0.5, "cm"))

## b. Colours ##
phylumbactcol <- c("#a6cee3", "#1f78b4", "#b2df8a", "#33a02c", "#fb9a99", 
                   "#e31a1c", "#fdbf6f", "#ff7f00", "#cab2d6", "#6a3d9a")
names(phylumbactcol) <- c("Actinobacteria", "Bacteroidetes", "Firmicutes", "Proteobacteria", "Cyanobacteria", 
                          "Unclassified", "Tenericutes", "Deferribacteres", "Cytokine", "Experimental")
phylumfungcol <- c("#225ea8", "#66bd63", "#dd3497", "#491C77", "#9C4B07")
names(phylumfungcol) <- c("Unclassified", "Basidiomycota", "Ascomycota", "Cytokine", "Experimental")

cytokinecol <- c("#309df3", "#a6d96a", "#9D6AD9", "#D96AA6", "#F38630", "#2c5197")
names(cytokinecol) <- c("2_TNF", "3_IFN", "4_IL22", "1_IL4", "6_IL17A", "5_IL21")

palettespec <- c("#addd8e", "#6A3D9A", "#FF7F00")
names(palettespec) <- c("1_control", "2_van", "3_psg")

palettespecfordiversity <- c("#addd8e", "#addd8e", "#addd8e", 
                             "#6A3D9A", "#6A3D9A", "#6A3D9A", 
                             "#FF7F00", "#FF7F00", "#FF7F00")
names(palettespecfordiversity) <- c("1_control_07d", "1_control_21d", "1_control_21dc", 
                                    "2_van_07d", "2_van_21d", "2_van_21dc", 
                                    "3_psg_07d", "3_psg_21d", "3_psg_21dc")

## Colourblind safe red-blue colours ##
redblue <- brewer.pal(11, "RdBu")[3:9]
rbx <- colorRampPalette(redblue)
redblueexpanded <- rbx(20)
genheatmapcols <- colorRampPalette(redblueexpanded)


##### 4. Load annotations #####
cytokine_array <- rev(c("IL17A", "IL21", "IL22", "IFN", "TNF", "IL4"))
antvars <- c("Controls (21d)", "van (21d)", "PSG (21d)", "Controls (+C.albicans)", 
             "van (+C.albicans)", "PSG (+C.albicans)", "van (7d)", "PSG (7d)")
names(antvars) <- c("controls_21d", "van_21d", "psg_21d", "controls_candida", "van_candida", "psg_candida", "van_7d", "psg_7d")
site_array <- c("ileum", "fecal")
species_array <- c("bact", "fung")
catarray <- c("controls_21d", "van_21d", "psg_21d", "controls_candida", "van_candida", "psg_candida", "van_7d", "psg_7d")
orggut <- expand.grid(species = species_array, site = site_array, stringsAsFactors = F)

##### 5. Load functions #####

## Covert string to sentence case ##
tosentencecase <- function(inputstring) {
    substr(inputstring, start = 1, 1) <- toupper(substr(inputstring, start = 1, 1))
    return(inputstring)
}

## Rescale values for heatmap ##
ourrescale <- function(x, to = c(0, 1), from = range(x, na.rm = TRUE)) {
    # upper and lower range are the same
    if (zero_range(from) || zero_range(to)) 
        return(x)
    out <- (x - from[1])/diff(from) * diff(to) + to[1]
    # (value - lowest in vector)/(range of vector) * desired range + lowest in desired range
}

## Add Phylum labels ##
gsubnamesphyla <- function(namestring) {
    new0 <- gsub("^\\d{2}:", "", namestring)
    new1 <- gsub("^x", "", new0)
    newname <- gsub("uncl", "UC", new1)
    out <- gsub("UC_", "UC ", newname)
    val <- gsub("Mitochondria_genus_incertae_sedis", "Mitochondria incertae sedis", out)
    newvar <- ifelse(val %in% rownames(bactfunguncl), bactfunguncl[val, "newname"], val)
    newn <- ifelse(val %in% antvars, val, sprintf("%s: {%s}", allphyla[val], newvar))
    if (length(grep("Candida", newn)) > 0) {
        final <- gsub("Unclassified(.*)", "Ascomycota\\1", newn)
    } else if (length(grep("Clostridium", newn)) > 0) {
        final <- gsub("Unclassified(.*)", "Firmicutes\\1", newn)
    } else {
        final <- newn
    }
    return(final)
}

## Clean up YAP genera names ##
gsubnames <- function(namestring) {
    new0 <- gsub("^\\d{2}:", "", namestring)
    new1 <- gsub("^x", "", new0)
    newname <- gsub("uncl", "UC", new1)
    out <- gsub("UC_", "UC ", newname)
    val <- gsub("Mitochondria_genus_incertae_sedis", "Mitochondria incertae sedis", out)
    newn <- ifelse(val %in% names(antvars), antvars[val], val)
    return(newn)
}

## Phylum labels for antibiotic models ##
gsubnamesphylaforanti <- function(namestring) {
    new0 <- gsub("^\\d{2}:", "", namestring)
    new1 <- gsub("^x", "", new0)
    newname <- gsub("uncl", "UC", new1)
    out <- gsub("UC_", "UC ", newname)
    val <- gsub("Mitochondria_genus_incertae_sedis", "Mitochondria incertae sedis", out)
    newvar <- ifelse(val %in% rownames(bactfunguncl), bactfunguncl[val, "newname"], val)
    newn <- ifelse(val %in% antvars, val, sprintf("%s: {%s}", allphyla[val], newvar))
    if (length(grep("Candida", newn)) > 0 & length(grep("Arthromitus", newn)) == 0) {
        final <- gsub("Unclassified(.*)", "Ascomycota\\1", newn)
    } else {
        final <- newn
    }
    return(final)
}

## Phylum labels for colonization models ##
gsubnamesphylaforcfu <- function(namestring) {
    new0 <- gsub("^\\d{2}:", "", namestring)
    new1 <- gsub("^x", "", new0)
    newname <- gsub("uncl", "UC", new1)
    out <- gsub("UC_", "UC ", newname)
    val <- gsub("Mitochondria_genus_incertae_sedis", "Mitochondria incertae sedis", out)
    newvar <- ifelse(val %in% rownames(bactfunguncl), bactfunguncl[val, "newname"], val)
    newn <- ifelse(val %in% names(antvars), antvars[val], sprintf("%s: {%s}", allphyla[val], newvar))
    if (length(grep("Candida", newn)) > 0) {
        final <- gsub("Unclassified(.*)", "Ascomycota\\1", newn)
    } else if (length(grep("Clostridium", newn)) > 0) {
        final <- gsub("Unclassified(.*)", "Firmicutes\\1", newn)
    } else if (length(grep("Bacteria", newn)) > 0) {
        final <- gsub("Unclassified(.*)", "Firmicutes\\1", newn)
    } else {
        final <- newn
    }
    return(final)
}

includepip <- function(var, value) {
    value <- as.character(value)
    if (var == "day" | var == "time") {
        value[value == "07"] <- paste("PIP", sprintf("%25s", "Day 7"), sep = "")
        value[value == "21"] <- paste("PIP", sprintf("%25s", "Day 21"), sep = "")
    }
    return(value)
}

cytolabels <- function(oldlabels) {
    newvar <- gsub("\\d{1}_(\\S+)@(.*)", sprintf("%s: (%s)", "\\2", "\\1"), oldlabels)
    return(newvar)
}

antilabels <- c("P", "V", "C")
names(antilabels) <- c("3_psg", "2_van", "1_control")
renameanti <- function(value) {
    value <- antilabels[value]
    return(value)
}

modifylabel <- function(var, value) {
    value <- as.character(value)
    if (var == "day" | var == "time") {
        value[value == "07"] <- "Day 7"
        value[value == "21"] <- "Day 21"
    } else if (var == "site") {
        value[value == "fecal"] <- "Fecal pellets"
        value[value == "ileum"] <- "Terminal ileum"
    } else if (var == "facetanti") {
        value <- gsub(".*\\((.*)\\)(.*)", "\\1\\2", value)
    }
    return(value)
}

modifylabelcfu <- function(var, value) {
    value <- as.character(value)
    if (var == "group") {
        value[value == "3_psg"] <- "PSG\n(P)"
        value[value == "2_van"] <- "Van.\n(V)"
        value[value == "1_control"] <- "Control\n(C)"
    }
    return(value)
}

modifylabelcyto <- function(var, value) {
    value <- as.character(value)
    if (var == "cytokineo") {
        value <- gsub("^\\d{2}", "", value)
        value <- ifelse(value == "IFN", "IFN~gamma", ifelse(value == "TNF", "TNF~alpha", value))
        value <- parse(text = value)
    }
    return(value)
}

modifylabeldiv <- function(var, value) {
    value <- as.character(value)
    if (var == "group") {
        value[value == "3_psg"] <- "PSG"
        value[value == "2_van"] <- "Van."
        value[value == "1_control"] <- "Control"
    } else if (var == "site") {
        value <- ""
    } else if (var == ".id") {
        value <- ifelse(value == "bact", "Bacteria", "Fungi")
    } else if (var == "day") {
        value[value == "07d"] <- "Day 7"
        value[value == "21d"] <- "Day 21"
        value[value == "21dc"] <- "Day 21\n+C.albicans"
    }
    return(value)
}

simpson <- function(row) {
    # 1/\sum_1^n(p^2)
    prop <- row/sum(row, na.rm = T)
    denom <- sum(prop^2)
    simpson <- 1/denom
}

##### 6. Run descriptive analysis and visualize it #####

## Preliminary Boxplots: C. albicans colonization ##
cfu_melt <- data.table(melt(cfubactall, id.vars = "SAMPLEID"))
cfuraw <- cfu_melt[grepl("zero_cfu", variable) & grepl("fecal", SAMPLEID)]
cfuraw[, `:=`(group, ifelse(grepl("control", SAMPLEID), "1_control", ifelse(grepl("van", SAMPLEID), "2_van", "3_psg"))), 
    ]
cfuraw[, `:=`(day, ifelse(grepl("_9$", SAMPLEID), "09d", ifelse(grepl("_21$", SAMPLEID), "21d", "14d")))]

cfuraw$site <- gsub("m\\d{1}\\@(fecal|ileum)\\@.*", "\\1", cfuraw$SAMPLEID)
cfuraw$sample <- gsub("@", "_", cfuraw$SAMPLEID)
cfuraw$treatment_group <- gsub("\\d{1}_(.*)", "\\1", cfuraw$group)
p <- ggplot(cfuraw, aes(x = day, y = value, fill = group))
p <- p + geom_boxplot(outlier.size = 2, fatten = 0.5, show_guide = F, alpha = 0.7, lwd = 0.4)
p <- p + facet_grid(~group, labeller = modifylabelcfu)
p <- p + scale_fill_manual(values = palettespec, name = "Treatment Group")
p <- p + ylab("log(CFU/g)") + xlab("Day")
p <- p + scale_x_discrete(labels = c(9, 14, 21))
p <- p + scale_y_continuous(limits = c(0, 9), breaks = seq(from = 0, to = ceiling(max(cfuraw$value)), 3))
p <- p + lightertheme
p <- p + theme(axis.title.x = element_text(vjust = -0.5), plot.margin = unit(c(1.5, 2, 3, 2), "mm"))
p <- p + ggtitle(label = "C. albicans colonization")
print(p)
# ggsave('cfu_vs_day_by_experiment.svg', plot=p, width=3, height=3, units='in', limitsize=F)


## Preliminary Boxplots: Cytokine Expression ##
cytomelt <- melt(cytodata, measure.vars = cytokine_array)
colnames(cytomelt) <- c("sample", "cytokine", "value")
ggframe <- cytomelt

## Separate out days and antibiotic treatment ##
assigngroups <- function(samplenames) {
    groups <- ifelse(grepl("control.*7d", samplenames), "A7dcontrols", 
                     ifelse(grepl("van.*7d", samplenames), "B7dvan", 
                            ifelse(grepl("psg.*7d", samplenames), "C7dpsg", 
                                   ifelse(grepl("control.*(r4.*21d|r5.*21d|r6.*21d.*redone)", samplenames), "G21dcontrol+Candida", 
                                          ifelse(grepl("van.*(r4.*21d|r5.*21d|r6.*21d.*redone)", samplenames), "H21dvan+Candida", 
                                                 ifelse(grepl("psg.*(r4.*21d|r5.*21d|r6.*21d.*redone)", samplenames), "I21dpsg+Candida", 
                                                        ifelse(grepl("control.*r6.*21d", samplenames), "D21dcontrols", 
                                                               ifelse(grepl("van.*r6.*21d", samplenames), "E21dvan",
                                                                      ifelse(grepl("psg.*r6.*21d", samplenames), "F21dpsg", "undefined")))))))))
    return(groups)
}
ordercytokines <- function(cytonames) {
    renamed <- ifelse(grepl("IL17A", cytonames), "01IL17A", 
                      ifelse(grepl("IL21", cytonames), "02IL21", 
                             ifelse(grepl("IL22", cytonames), "03IL22", 
                                    ifelse(grepl("IFN", cytonames), "04IFN", 
                                           ifelse(grepl("TNF", cytonames), "05TNF", 
                                                  ifelse(grepl("IL4", cytonames), "06IL4", 
                                                         ifelse(grepl("th17", cytonames), "01Th17", 
                                                                ifelse(grepl("th1", cytonames), "02Th1", "undefined"))))))))
    return(renamed)
}

ggframe <- data.table(ggframe)
ggframe$group <- assigngroups(ggframe$sample)
ggframe$gut <- gsub(".*(fecal|ileum).*", "\\1", ggframe$sample)
ggframe$day <- ifelse(grepl("Candida", ggframe$group), "Day 21\n+C. albicans", 
                      ifelse(grepl("7d", ggframe$group), "Day  7", "Day 21"))
ggframe$anti <- ifelse(grepl("control", ggframe$sample), "1_control", 
                       ifelse(grepl("van", ggframe$sample), "2_van", 
                              ifelse(grep("psg", ggframe$sample), "3_psg", "undefined")))

ggframe$site <- gsub("m\\d{1}_(.*)_(psg|van|control|flu|amp).*", "\\1", ggframe$sample)
ggframe$mouse <- gsub("(m\\d{1})_(.*)_(psg|van|control|flu|amp).*", "\\1", ggframe$sample)
ggframe$treatment <- gsub("(m\\d{1})_(.*)_(psg|van|control|flu|amp).*(7d|21d).*", "\\3", ggframe$sample)
ggframe$repeatornot <- ifelse(grepl("repeatredone", ggframe$sample), "repeatredone", 
                              ifelse(grepl("repeat", ggframe$sample), "repeat", "first"))
ggframe$run <- gsub("(m\\d{1})_(.*)_(psg|van|control|flu|amp)_(r\\d{1})_(7d|21d).*", "\\4", ggframe$sample)
ggframe <- ggframe[site == "ileum_mucosa"]

ggplotit <- function(ggframe) {
    ggmelt <- ggframe
    ggmelt$group <- assigngroups(ggmelt$sample)
    ggmelt <- ggmelt[which(ggmelt$group != "undefined"), ]
    ggmelt$cytokineo <- ordercytokines(ggmelt$cytokine)
    cp <- ggplot(ggmelt, aes(x = anti, y = value, fill = anti))
    cp <- cp + geom_boxplot(outlier.size = 1, show_guide = F, fatten = 0.5, lwd = 0.4)
    cp <- cp + facet_grid(cytokineo ~ day, labeller = modifylabelcyto)
    cp <- cp + lightertheme
    cp <- cp + scale_fill_manual(values = palettespec)
    cp <- cp + scale_x_discrete(labels = renameanti)
    cp <- cp + theme(axis.text.x = element_text(size = 12, hjust = 0.5, colour = "black"))
    cp <- cp + theme(strip.text.y = element_text(angle = 360, face = "bold"))
    cp <- cp + xlab("Treatment Group") + ylab("log(mRNA expression level)")
    cp <- cp + theme(axis.title.x = element_text(vjust = -0.2))
    cp <- cp + ggtitle(label = "Cytokine expression levels")
    # ggsave('cytokine_expression_boxplots.svg', plot=cp, width=9, height=17.7, units='cm', limitsize=F)
    return(cp)
}

ggplotit(ggframe = ggframe)

## Preliminary Boxplots: Microbiome Diversity ##
simporg <- sapply(species_array, function(org) {
    fprob <- sprintf("fecal_6_prob_%s_yapcyto_ones", org)
    iprob <- sprintf("ileum_6_prob_%s_yapcyto_ones", org)
    fcount <- sprintf("fecal_6_count_%s_cytocfu_ones", org)
    icount <- sprintf("ileum_6_count_%s_cytocfu_ones", org)
    fprobdata <- finaldatalists[[fprob]]
    iprobdata <- finaldatalists[[iprob]]
    fcountdata <- finaldatalists[[fcount]]
    icountdata <- finaldatalists[[icount]]
    calcsimpson <- function(datacount, dataprob) {
        datasub <- datacount[rownames(dataprob), ]
        # remove taxa which are zero throughout all samples
        datasub <- datasub[, which(colSums(datasub) > 0)]
        # calculate inverse simpson diversity index
        yapsimp <- apply(datasub, 1, simpson)
        return(yapsimp)
    }
    fsimp <- calcsimpson(datacount = fcountdata, dataprob = fprobdata)
    isimp <- calcsimpson(datacount = icountdata, dataprob = iprobdata)
    fdiv <- data.frame(simp = fsimp, site = "fecal")
    fdiv$sample <- rownames(fdiv)
    idiv <- data.frame(simp = isimp, site = "ileum")
    idiv$sample <- rownames(idiv)
    alldiv <- rbind(fdiv, idiv)
}, simplify = F)
simply <- ldply(simporg)
ggframe <- data.frame(simply)
ggframe$group <- ifelse(grepl("psg", ggframe$sample), "3_psg", 
                        ifelse(grepl("van", ggframe$sample), "2_van", "1_control"))
ggframe$day <- ifelse(grepl("r6_21d_repeatredone", ggframe$sample), "21dc", 
                      ifelse(grepl("r[45]_21d", ggframe$sample), "21dc", 
                             ifelse(grepl("r6_21d", ggframe$sample), "21d", "07d")))
ggframe$site <- ifelse(grepl("fecal", ggframe$sample), "Fecal", "Ileum")
ggframe$groupday <- paste(ggframe$group, ggframe$day, sep = "_")
maxy <- max(ggframe$simp)
miny <- min(ggframe$simp)


plotdiversity <- function(gut, graphtitle) {
    ggset <- subset(x = ggframe, site == gut)
    dday <- ggplot(ggset, aes(y = simp, x = group, fill = groupday))
    dday <- dday + geom_boxplot(outlier.size = 1, show_guide = F, fatten = 0.5, lwd = 0.4)
    dday <- dday + facet_grid(.id ~ day, labeller = modifylabeldiv)
    dday <- dday + xlab("Treatment Group") + ylab("Diversity Index")
    dday <- dday + scale_fill_manual(values = palettespecfordiversity)
    dday <- dday + scale_x_discrete(labels = renameanti)
    dday <- dday + scale_y_continuous(limits = c(miny, maxy + 0.5), breaks = round(seq(miny, maxy + 0.5, by = 5), 0))
    dday <- dday + theme(axis.text.x = element_text(size = 12, hjust = 0.5, colour = "black"))
    dday <- dday + lightertheme
    dday <- dday + theme(axis.title.x = element_text(vjust = -0.2))
    dday <- dday + ggtitle(label = graphtitle)
    # ggsave(sprintf('diversity_vs_day_%s.svg', gut),plot=dday, width=9, height=10, units='cm')
    return(dday)
}
plotdiversity(gut = "Fecal", graphtitle = "Fecal Pellets")
plotdiversity(gut = "Ileum", graphtitle = "Terminal Ileum")

##### 7. Visualize the level of heterogeneity across the experiments #####

betaipscatter <- function(type, species, xgut = "", ptitle, cwidth, cheight) {
    datasub <- data.frame(betainfo[[type]])
    if (xgut != "") {
        datasub <- subset(x = datasub, site == xgut)
    }
    if (type == "anti") {
        datasub <- subset(x = datasub, anti != "psgvan")
    }
    if (type == "cyto") {
        datasub$cytokine <- gsub(".*_level6_(.*)_(7|21)$", "\\1", datasub$filename)
    }
    datasub$phyla <- allphyla[datasub$clean]
    datasub$phyla <- ifelse(datasub$clean %in% cytokine_array, "Cytokine", 
                            ifelse(!(datasub$clean %in% names(allphyla)) & !(datasub$clean %in% cytokine_array), "Experimental", datasub$phyla))
    datasub <- subset(datasub, org == species)
    datasub$phylagen <- sprintf("%s {%s}", datasub$phyla, datasub$clean)
    datasub[is.na(datasub)] <- 0
    datasub$day <- ifelse(grepl("7", datasub$filename), "07", "21")
    p <- ggplot(datasub, aes(x = probcent, y = median))
    p <- p + geom_hline(yintercept = 0, linetype = "dashed", colour = "grey30")
    p <- p + geom_point(aes(size = 0.7, colour = phyla))
    if (type == "cfu") {
        p <- p + facet_grid(facetlabels ~ ., labeller = modifylabel)
    } else if (type == "anti") {
        p <- p + facet_grid(facetanti ~ day, labeller = modifylabel)
    } else if (type == "cyto") {
        p <- p + facet_grid(cytokine ~ site + day, labeller = modifylabel)
    }
    if (type == "cyto" | type == "cfu") {
        p <- p + scale_x_continuous(breaks = seq(from = 0, to = max(datasub$probcent, na.rm = T), by = 20))
    } else {
        p <- p + scale_x_continuous(breaks = seq(from = 0, to = max(datasub$probcent, na.rm = T), by = 10))
    }
    p <- p + ylab("Median effect size") + xlab("Posterior Inclusion Probability (PIP, in %)")
    if (species == "bact") {
        p <- p + scale_colour_manual(values = phylumbactcol, name = "Category")
    } else {
        p <- p + scale_colour_manual(values = phylumfungcol, name = "Category")
    }
    p <- p + guides(colour = guide_legend(override.aes = list(size = 5)),
                    size = F)
    p <- p + lightertheme
    p <- p + theme(axis.title.x = element_text(vjust = -0.1),
                   strip.text.y = element_text(angle = 360),
                   legend.position = "left")
    p <- p + ggtitle(label = ptitle)
    # ggsave(filename = sprintf('heterogeneity_%s_%s.svg', type, species), plot = p, width = cwidth, height = cheight, units= 'in', limitsize = F)
    return(p)
}

# Width 1 + 2 + 3/4 || (3.75/5.5)*8.5 height 4 + 0.5 || (4.5/6.75)*8.5
betaipscatter(type = "anti", species = "bact", ptitle = "Effect of PSG and vancomycin on bacteria", cwidth = 5.8, cheight = 5.7)
### Heterogeneity in the effect of PSG and vancomycin on bacteria ###


betaipscatter(type = "anti", species = "fung", ptitle = "Effect of PSG and vancomycin on fungi", cwidth = 5.8, cheight = 5.7)
### Heterogeneity in the effect of PSG and vancomycin on fungi ###


# Width 1 + 1 + 3/4 || (2.75/5.5)*8.5 height 2 + 0.5 || (2.5/6.75)*8.5
betaipscatter(type = "cfu", species = "bact", ptitle = "Effect of bacteria and cytokines on colonization", cwidth = 4.75, 
    cheight = 3.1)
### Heterogeneity in the effect of bacteria and cytokines on colonization ###

betaipscatter(type = "cfu", species = "fung", ptitle = "Effect of fungi and cytokines on colonization", cwidth = 4.75, cheight = 3.1)
### Heterogeneity in the effect of fungi and cytokines on colonization ###

# Width 1 + 4 + 1/2 || (5.5/3.75)*7.3 height 6 + 0.75
betaipscatter(type = "cyto", species = "bact", ptitle = "Effect of bacteria and antibiotics on cytokines", cwidth = 8.5, cheight = 8.5)
### Heterogeneity in the effect of bacteria and antibiotics on cytokines ###

betaipscatter(type = "cyto", species = "fung", ptitle = "Effect of fungi and antibiotics on cytokines", cwidth = 8.5, cheight = 8.5)
### Heterogeneity in the effect of fungi and antibiotics on cytokines ###

##### 8. Scaled abundances following antibiotic treatment #####
antiheatmap <- function(org, site) {
    namestring <- sprintf("%s_6_prob_%s_yapcytocfu_ones", site, org)
    print(namestring)
    proportions <- finaldatalists[[namestring]]
    prop <- proportions[, -(which(colnames(proportions) == "logcfu_per_gram"))]
    # Limit to only microbes of interest
    bmavars <- get(sprintf("%s%shm", org, site))
    relvars <- grep("^#", bmavars$V1, invert = T, value = T)
    common <- relvars[which(relvars %in% colnames(prop))]
    relprop <- sapply(relvars, function(var) {
        if (var %in% colnames(prop)) {
            out <- prop[, var]
        } else {
            out <- rep(0, nrow(prop))
        }
        names(out) <- rownames(prop)
        return(out)
    })
    relprop <- data.frame(relprop)
    colnames(relprop) <- paste(sprintf("%02d", seq(ncol(relprop), 1)), colnames(relprop), sep = ":")
    graphtitle <- sprintf("%s\n(%s)", tosentencecase(ifelse(org == "bact", "Scaled Bacterial Abundances", "Scaled Fungal Abundances")), 
        tosentencecase(ifelse(site == "fecal", "Fecal Pellets", "Terminal Ileum")))
    relprop$sample <- rownames(relprop)
    ggframe <- melt(relprop, id.vars = "sample")
    names(ggframe) <- c("sample", "taxa", "value")
    ggframe$taxa <- as.character(ggframe$taxa)
    ggframe$group <- ifelse(grepl("control.*7d", ggframe$sample), "A7dcontrols", ifelse(grepl("van.*7d", ggframe$sample), 
        "B7dvan", ifelse(grepl("psg.*7d", ggframe$sample), "C7dpsg", ifelse(grepl("control.*(r4.*21d|r5.*21d|r6.*21d.*redone)", 
            ggframe$sample), "G21dcontrol+Candida", ifelse(grepl("van.*(r4.*21d|r5.*21d|r6.*21d.*redone)", ggframe$sample), 
            "H21dvan+Candida", ifelse(grepl("psg.*(r4.*21d|r5.*21d|r6.*21d.*redone)", ggframe$sample), "I21dpsg+Candida", 
                ifelse(grepl("control.*r6.*21d", ggframe$sample), "D21dcontrols", ifelse(grepl("van.*r6.*21d", ggframe$sample), 
                  "E21dvan", ifelse(grepl("psg.*r6.*21d", ggframe$sample), "F21dpsg", "undefined")))))))))
    
    ggframe <- data.table(ggframe)
    ggframe[, `:=`(meanval, mean(value)), by = list(taxa, group)]
    numpalette <- 100
    # Scaled value is: (x - xmin) / (xmax - xmin) # Preserves the original magnitude of the intervals betweeen values.
    ggframe[, `:=`(rescale, ourrescale(meanval, to = c(1/numpalette, 1))), by = list(taxa)]
    ggframe[, `:=`(group2, ifelse(grepl("control", sample), "Controls", ifelse(grepl("psg", sample), "PSG", "Vancomycin"))), ]
    ggframe[, `:=`(day, ifelse(grepl("7d", group), "07", "21")), ]
    # Plot it
    p <- ggplot(ggframe, aes(x = group, y = taxa))
    p <- p + geom_tile(aes(fill = rescale), colour = "white")
    myPalette <- colorRampPalette(rev(brewer.pal(9, "YlGnBu")))
    numpalette <- 10000
    if (length(setdiff(relvars, common)) > 0) {
        p <- p + scale_fill_gradientn(colours = c("#FFFFFF", rev(genheatmapcols(numpalette))), limits = c(0, 1), 
                                      breaks = c(0, 0.5, 1), guide = guide_colourbar(title = "Relative\nAbundance"))
    } else {
        p <- p + scale_fill_gradientn(colours = rev(genheatmapcols(numpalette)), limits = c(0, 1), 
                                      breaks = c(0, 0.5, 1), guide = guide_colourbar(title = "Relative\nAbundance"))
    }
    p <- p + theme_grey()
    p <- p + xlab("") + ylab("")
    p <- p + scale_x_discrete(labels = c("C", "V", "P"))
    p <- p + scale_y_discrete(labels = gsubnamesphyla)
    p <- p + ggtitle(graphtitle)
    p <- p + lightertheme
    p <- p + facet_grid(. ~ day, labeller = modifylabel, scales = "free", space = "free")
    p <- p + theme(axis.text.x = element_text(colour = "black"),
                   axis.text.y = element_text(face = "italic"), 
                   legend.title = element_blank(),
                   legend.position = "bottom", 
                   legend.text = element_text(face = "italic"))
    # ggsave(sprintf('scaledabundance_%s_%s.pdf', org, site), plot=p, width=cwidth, height=cheight, units='in', limitsize=F)
    return(p)
}


antiheatmap(org = "bact", site = "fecal")
antiheatmap(org = "bact", site = "ileum")
antiheatmap(org = "fung", site = "fecal")
antiheatmap(org = "fung", site = "ileum")

##### 9. Visualize effect sizes #####

## Plot cytokine effect sizes ##
cytoci <- betainfo$cyto[lower95 * upper95 >= 0 & iprob >= 0.45 & grepl("level6", filename)]
cytoci[, `:=`(org, gsub("cytomodels_(bact|fung)_(ileum|fecal)_level6_(.*)_(21|7)$", "\\1", filename)), ]
cytoci[, `:=`(gut, gsub("cytomodels_(bact|fung)_(ileum|fecal)_level6_(.*)_(21|7)$", "\\2", filename)), ]
cytoci[, `:=`(cleanvar, gsub("^x", "", variable)), ]

cytoci[, `:=`(cytokine, gsub(".*level6_(.*)_(21|7)$", "\\1", filename)), ]
cytoci[, `:=`(day, ifelse(grepl("_7$", filename), "07", "21")), ]
cytoci[, `:=`(cytonum, paste(match(cytokine, cytokine_array), cytokine, sep = "_")), ]
cytoci[, `:=`(cleanvar, gsubnames(variable)), ]

cytoci[, `:=`(phyla, ifelse(cleanvar %in% antvars, cleanvar, gsubnamesphylaforanti(cleanvar))), ]
cytoci[, `:=`(cytonumvar, paste(cytonum, cleanvar, sep = "_")), ]
cytoci[, `:=`(cytophylavar, ifelse(is.na(phyla), cytonumvar, sprintf("%s@%s", cytonum, phyla))), ]
cytoci[, `:=`(facetlabels, tosentencecase(ifelse(gut == "fecal", "Fecal Pellets", "Terminal Ileum"))), ]
cytoci$dotsize <- 50
minlower <- min(cytoci$lower95) - 0.8
maxupper <- max(cytoci$upper95)
xbreaks <- seq(from = -3, to = 3, by = 3)
xlimits <- c(-1, 3)
xlimits[1] <- min(range(xbreaks)[1] - 0.1, minlower)
xlimits[2] <- max(range(xbreaks)[2] + 0.1, maxupper)
cytoci$probx <- xlimits[1] + 0.1
cytoci$probprint <- ceiling(cytoci$iprob * 100)
cytokinenoil4 <- setdiff(cytokine_array, "IL4")

## Plot the forest plot for cytokines ##
cytoplotit <- function(species) {
    cytodata <- cytoci[org == species]
    cytodata <- cytodata[iprob > 0.47]
    somevar <- cytodata[1, ]
    somevar[, `:=`(probx = 100, probprint = "", median = median * 100, upper95 = upper95 * 100, lower95 = lower95 * 100), 
        ]
    # Manipulation to make dotsize saner.
    somevar[, `:=`(dotsize, 100), ]
    cytorg <- rbind(cytodata, somevar)
    p <- ggplot(data = cytorg, aes(x = median, y = cytophylavar))
    p <- p + geom_point(aes(size = dotsize, fill = cytonum, colour = cytonum), shape = 21, show_guide = F)
    p <- p + geom_errorbarh(aes(xmin = lower95, xmax = upper95, colour = cytonum, size = 0.7), height = 0.667, show_guide = T)
    p <- p + geom_vline(xintercept = 0, linetype = "dashed", colour = "grey30")
    p <- p + scale_x_continuous(breaks = xbreaks, limits = xlimits)
    p <- p + facet_grid(facetlabels ~ day, labeller = includepip, scales = "free", space = "free")
    p <- p + geom_text(aes(x = probx + 0.35, label = probprint), size = 4)
    p <- p + scale_y_discrete(labels = cytolabels, drop = T)
    p <- p + scale_size_continuous(breaks = seq(from = 0, to = 100, by = 20), labels = seq(from = 0, to = 100, by = 20), 
        limits = c(0, 100))
    p <- p + lightertheme
    p <- p + xlab("Effect size on cytokines") + ylab("")
    p <- p + guides(colour = guide_legend(override.aes = list(size = 3), 
                                          label.theme = element_text(size = 10, angle = 0, face = "italic"), 
                                          title.theme = element_text(size = 10, angle = 0, face = "bold"),
                                          size=F))
    p <- p + theme(strip.text.y = element_text(angle = 360, size = 10),
                   axis.text.y = element_text(colour = "black", face = "italic", size = 10),
                   legend.position = "top")
    p <- p + scale_colour_manual(name = "Cytokines", values = cytokinecol, 
                                 breaks = sort(setdiff(unique(cytoci$cytonum), "1_IL4"), decreasing = T), 
                                 labels = c("IL17A", "IL21", "IL22", "IFN", "TNF"))
    p <- p + scale_fill_manual(name = "Cytokines", values = cytokinecol, 
                               breaks = sort(setdiff(unique(cytoci$cytonum), "1_IL4"), decreasing = T), 
                               labels = c("IL17A", "IL21", "IL22", "IFN", "TNF"))
    calheight <- (1 + 2 + nrow(cytodata)) * 0.26 + 1
    if (species == "fung") {
        calwidth <- 6.5
    } else {
        calwidth <- 7.4
    }
    p <- p + ggtitle(ifelse(species == "bact", "Bacterial Model", "Fungal Model"))
    # ggsave(sprintf('forestplot_cyto_%s.svg', species), plot=p, width=calwidth, height=calheight, units='in', limitsize=F)
    return(p)
}
cytoplotit(species = "bact")
cytoplotit(species = "fung")

## Plot the forest plot for colonization ##
givecfufpdata <- function(species, place, dataname) {
    modelsummary <- betainfo$cfu[org == species & gut == place]
    if (species == "bact" & place == "fecal") {
        threshold <- 0.1
    } else if (species == "bact" & place == "ileum") {
        threshold <- 0.04
    } else {
        threshold <- 0.01
    }
    cfuci <- modelsummary[lower95 * upper95 >= 0 & iprob >= threshold]
    if (nrow(cfuci) > 0) {
        numvars <- min(5, nrow(cfuci))
        cfuten <- cfuci[1:min(5, nrow(cfuci))]
        relvars <- cfuten[, c("variable", "iprob"), with = F]
        cfuten[, `:=`(ordervar, sprintf("%02d:%s", seq(from = nrow(cfuten), to = 1, by = -1), variable)), ]
        cfuten[, `:=`(probcent, round(iprob * 100, 0)), ]
        cfuten[, `:=`(probprint, sprintf("%0.1f", iprob * 100)), ]
        cfuten[, `:=`(org, gsub("cfumodels_(bact|fung)_(ileum|fecal)_.*", "\\1", filename)), ]
        cfuten[, `:=`(gut, gsub("cfumodels_(bact|fung)_(ileum|fecal)_.*", "\\2", filename)), ]
        cfuten[, `:=`(facetlabels, tosentencecase(ifelse(place == "fecal", "Fecal Pellets", "Terminal Ileum"))), ]
        cfuten[, `:=`(clean, gsubnames(ordervar)), ]
        cfuten[, `:=`(simplecol, ifelse(median >= 0, "plus1", "minus1")), ]
        return(cfuten)
    } else {
        print(sprintf("%s:All CIs zerocrossing.", dataname))
        return(list())
    }
}

topcfu <- sapply(1:nrow(orggut), function(numrow) {
    org <- orggut[numrow, 1]
    gut <- orggut[numrow, 2]
    namedata <- paste(org, gut, sep = "_")
    givecfufpdata(species = org, place = gut, dataname = namedata)
}, simplify = F)

## Bind all data ##
allcfu <- rbindlist(topcfu)

## Run visualization function ##
allcfufung <- allcfu[org == "fung"]
allcfubact <- allcfu[org == "bact"]

plotcfufp <- function(species, xgut = "") {
    allcfu <- get(sprintf("allcfu%s", species))
    allcfu[, `:=`(dotsize, 50), ]
    minlower <- min(allcfu$lower95) - 0.3
    maxupper <- max(allcfu$upper95)
    xbreaks <- seq(-1, 2, by = 1)
    xlimits <- c(-1, 2)
    xlimits[1] <- min(range(xbreaks)[1] - 0.1, minlower)
    xlimits[2] <- 2.5
    allcfu$probx <- xlimits[1] + 0.05
    if (xgut != "") {
        allcfu <- allcfu[gut == xgut]
    }
    somevar <- allcfu[1, ]
    # create multiple columns in data.table
    somevar[, `:=`(probx = 100, probprint = "", median = median * 100, upper95 = upper95 * 100, lower95 = lower95 * 100), 
        ]
    somevar[, `:=`(dotsize, 100), ]
    cfumad <- rbind(allcfu, somevar)
    numvars <- nrow(allcfu)
    fp <- ggplot(data = cfumad, aes(x = median, y = ordervar))
    fp <- fp + geom_vline(xintercept = 0, linetype = "dashed", colour = "grey30")
    fp <- fp + geom_point(aes(size = dotsize, fill = simplecol, colour = simplecol), shape = 21, show_guide = F)
    fp <- fp + geom_errorbarh(aes(xmin = lower95, xmax = upper95, colour = simplecol, size = 0.5), height = 0.667, show_guide = F)
    fp <- fp + facet_grid(facetlabels ~ ., scales = "free", space = "free")
    fp <- fp + scale_size_continuous(breaks = seq(from = 0, to = 100, by = 20))
    fp <- fp + scale_x_continuous(breaks = xbreaks, limits = xlimits)
    fpcolour <- c("grey30", "grey30")
    names(fpcolour) <- c("minus1", "plus1")
    fp <- fp + scale_colour_manual(values = fpcolour, guide = F)
    fp <- fp + scale_fill_manual(values = fpcolour, guide = F)
    fp <- fp + scale_y_discrete(labels = gsubnamesphylaforcfu)
    if (species == "fung") {
        fp <- fp + geom_text(aes(x = probx + 0.1, label = probprint), size = 3.5)
    } else {
        fp <- fp + geom_text(aes(x = probx - 0.01, label = probprint), size = 3.5)
    }
    plottitle <- ifelse(species == "bact", "Bacterial Model", "Fungal Model")
    fp <- fp + xlab("") + ylab("")
    fp <- fp + lightertheme
    fp <- fp + theme(strip.text.y = element_text(angle = 360),
                     axis.text.y = element_text(size = 10, colour = "black", face = "italic"),
                     plot.margin = unit(c(1, 0, -4, 0), "mm"),
                     panel.margin = unit(5, "mm"))
    if (species == "bact") {
        calheight <- (1 + numvars) * 0.3
        calwidth <- 6
        fp <- fp + ggtitle(label = sprintf("%s\n%-60s", plottitle, "PIP"))
    } else if (species == "fung") {
        calwidth <- 5.5
        calheight <- (1 + numvars) * 0.3
        fp <- fp + ggtitle(label = sprintf("%s\n%-55s", plottitle, "PIP"))
    }
    # ggsave(sprintf('forestplot_cfu_%s.svg', species), plot=fp, width=calwidth, height=calheight, units='in', limitsize=F)
    return(fp)
}
plotcfufp(species = "bact")
plotcfufp(species = "fung")

### Finis ### 