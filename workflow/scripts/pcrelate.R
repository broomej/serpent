#! /usr/bin/env Rscript

library(SeqArray)
library(SeqVarTools)
library(GENESIS)
input <- snakemake@input
output <- snakemake@output
params <- snakemake@params

gds <- seqOpen(input$gds)
mypcair <- readRDS(input$pca)
# replace following line with args to snpgdsIBDKING to read in sample/variant filters if provided
seqSetFilter(gds, variant.id = readRDS(input$var))
seqData <- SeqVarData(gds)
iterator <- SeqVarBlockIterator(seqData, verbose = TRUE, variantBlock = 5000)
pcr <- pcrelate(
    iterator,
    pcs = mypcair$vectors[, seq(params$n_pcs)],
    training.set = mypcair$unrels,
    small.samp.correct = TRUE
)

saveRDS(pcr, output$pcr)
pcr_mat <- pcrelateToMatrix(
    pcr,
    scaleKin = params$scale_kin
)

saveRDS(pcr_mat, output$grm)
