#! /usr/bin/env Rscript

library(ggplot2)
library(SeqArray)
gds <- seqOpen(snakemake@input$gds)
if ("variant_id" %in% names(input)) {
    seqSetFilter(gds, variant.id = readRDS(input$variant_id))
}
if ("sample_id" %in% names(input)) {
    seqSetFilter(gds, sample.id = readRDS(input$sample_id))
}

king <- SNPRelate::snpgdsIBDKING(
    gds,
    snp.id = readRDS(snakemake@input$var),
    type = "KING-robust",
    num.thread = as.integer(snakemake@threads)
)

rownames(king$kinship) <- king$sample.id
colnames(king$kinship) <- king$sample.id

saveRDS(king, snakemake@output$king)
saveRDS(king$kinship, snakemake@output$grm)
