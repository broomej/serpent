#! /usr/bin/env Rscript

library(SeqArray)
library(SeqVarTools)
library(GENESIS)
input <- snakemake@input
output <- snakemake@output
params <- snakemake@params

n_pcs <- params$n_pcs
params$n_pcs <- NULL
vb <- params$variantBlock
params$variantBlock <- NULL
sk <- params$scaleKin
params$scaleKin <- NULL

pca <- readRDS(input$pca)

gds <- seqOpen(input$gds)
if (!is.null(input$variant_id)) {
    seqSetFilter(gds, variant.id = readRDS(input$variant_id))
}
seqData <- SeqVarData(gds)
iterator <- SeqVarBlockIterator(seqData, verbose = params$verbose,
                                variantBlock = vb)

arguments <- list(
    gdsobj = iterator,
    pcs = pca$vectors[, 1:n_pcs],
    training.set = pca$unrels
)

if (!is.null(input$sample_include)) {
    arguments$sample.include <- readRDS(input$sample_include)
}

if (length(params) > 0) {
    for (n in names(params)) {
        arguments[[n]] <- params[[n]]
    }
}
names(arguments) <- gsub("_", ".", names(arguments))

pcr <- do.call(pcrelate, arguments)
saveRDS(pcr, output$pcr)

pcr_mat <- pcrelateToMatrix(pcr, scaleKin = sk)
saveRDS(pcr_mat, output$grm)
