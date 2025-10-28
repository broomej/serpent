#! /usr/bin/env Rscript
gdsfile <- snakemake@input$gdsfile
params <- snakemake@params
hwe_thresh <- snakemake@params$hwethresh
maf_min <- snakemake@params$maf_min
ld_thresh <- snakemake@params$ldthresh
num_thread <- as.integer(snakemake@threads)

library(magrittr)
library(dplyr)
library(SeqVarTools)
library(ggplot2)
gds <- seqOpen(gdsfile)

varmet <- tibble(
    id = seqGetData(gds, "variant.id"),
    annotation.id = seqGetData(gds, "annotation/id"),
    chr = seqGetData(gds, "chromosome"),
    pos = seqGetData(gds, "position"),
    allele.tmp = seqGetData(gds, "allele"),
    missing_rate = seqMissing(gds, per.variant = TRUE, parallel = TRUE),
    maf = seqAlleleFreq(gds, minor = TRUE, parallel = TRUE)
) %>%
    mutate(
    allele = gsub(",<NON_REF>|,\\*", "", allele.tmp),
    snv = grepl("^[ATGC],[ATGC]$", allele),
    ) %>%
    select(-allele.tmp)
if (length(grep("NON_REF|\\*", varmet$allele) > 0)) {
    stop("NON_REFs are still in the metadata")
}

# hwe() returns all NA for p and f for some reason. Using the
# functions it calls under the hood does calculate the values though.
calc_p_f <- function(x) {
    counts <- select(x, nAA, nAa, naa)
    p <- GWASExactHW::HWExact(counts)
    f <- SeqVarTools:::.f(counts)
    out <- cbind(variant.id = x$variant.id, counts, p_hwe = p, f_hwe = f)
    return(out)
}

set.seed(51)
seqSetFilter(gds, filter(varmet, snv)$id)
hw_pmt<- hwe(gds, permute = TRUE, parallel = TRUE) %>%
    calc_p_f()
hw <- hwe(gds, permute = FALSE, parallel = TRUE) %>%
    calc_p_f() 
seqResetFilter(gds)
p <- data.frame(obs=sort(hw$p_hwe),
                exp=sort(hw_pmt$p_hwe)) %>%
    ggplot(aes(-log10(exp), -log10(obs))) +
    geom_point() +
    geom_abline(intercept=0, slope=1, color="red") +
    geom_hline(yintercept = hwe_thresh) +
    xlab(expression(paste(-log[10], "(expected P)"))) +
    ylab(expression(paste(-log[10], "(observed P)"))) +
    theme_bw()
ggsave(snakemake@output$hwe_plot)
varmet %<>% left_join(hw, c(id = "variant.id"))
saveRDS(varmet, snakemake@output$varmet)


var_pass_qc <- filter(
    varmet,
    (-log10(p_hwe) < hwe_thresh | is.na(p_hwe)),
    snv
)
saveRDS(var_pass_qc$id, snakemake@output$var_pass_qc)

pca_filt <- get(data(list = "pcaSnpFilters.hg38", package = "GWASTools"))
var_pass_qc$pcaSnpFilter <- TRUE
for (x in pca_filt$chrom) {
    region <- pca_filt[pca_filt$chrom == x, ]
    idx <- var_pass_qc$chr == x & 
        between(var_pass_qc$pos, region$start.base - 1, region$end.base + 1)
    var_pass_qc$pcaSnpFilter[idx] <- FALSE
}

pruned <- SNPRelate::snpgdsLDpruning(
    gds,
    snp.id = filter(var_pass_qc, pcaSnpFilter)$id,
    method = "corr",
    ld.threshold = ld_thresh,
    num.thread = num_thread) %>%
    unlist()
saveRDS(pruned, snakemake@output$pruned)
