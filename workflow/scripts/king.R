#! /usr/bin/env Rscript

library(ggplot2)
gds <- SeqArray::seqOpen(snakemake@input$gds)
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
