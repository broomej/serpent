#! /usr/bin/env Rscript
library(SeqVarTools)
library(SNPRelate)
library(dplyr)
library(magrittr)
opts <- commandArgs(trailingOnly = TRUE)

gds <- seqOpen(opts[1])
varmet <- tibble(
    id = seqGetData(gds, "variant.id"),
    annotation.id = seqGetData(gds, "annotation/id"),
    chr = seqGetData(gds, "chromosome"),
    pos = seqGetData(gds, "position"),
    allele = seqGetData(gds, "allele"),
    missing_rate = seqMissing(gds, per.variant = TRUE, parallel = TRUE),
    maf = seqAlleleFreq(gds, minor = TRUE, parallel = TRUE),
    snv = isSNV(gds)
)

saveRDS(varmet, opts[2])

var_pass_qc <- filter(varmet, missing_rate < 0.02, maf > 0.1, snv, chr != "X",
                      chr != "Y")
saveRDS(var_pass_qc$id, opts[3])

# Filter out regions correlated with PCs from LD pruning
pca_filt <- get(data(list = "pcaSnpFilters.hg38", package = "GWASTools"))
var_pass_qc$pcaSnpFilter <- TRUE
for (x in pca_filt$chrom) {
    region <- pca_filt[pca_filt$chrom == x, ]
    idx <- var_pass_qc$chr == x & 
        between(var_pass_qc$pos, region$start.base - 1, region$end.base + 1)
    var_pass_qc$pcaSnpFilter[idx] <- FALSE
}

pruned <- snpgdsLDpruning(
        gds,
        snp.id = filter(var_pass_qc, pcaSnpFilter)$id,
        method = "corr",
        ld.threshold = 0.1,
        num.thread = as.numeric(opts[5])) %>%
    unlist()

saveRDS(pruned, opts[4])
