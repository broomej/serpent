logcon <- file(snakemake@log[[1]], open = "wt")
sink(logcon)
sink(logcon, type = "message")

library(SeqArray)
library(SeqVarTools)
library(GENESIS)
input <- snakemake@input
output <- snakemake@output
params <- snakemake@params

n_pcs <- params$n_pcs
vb <- params$variantBlock
sk <- params$scaleKin

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
    training.set = pca$unrels,
    verbose = params$verbose
)

if (!is.null(input$sample_include)) {
    arguments$sample.include <- readRDS(input$sample_include)
}

arguments <- c(arguments, params$pcrelate_args)

pcr <- do.call(pcrelate, arguments)
saveRDS(pcr, output$pcr)

pcr_mat <- pcrelateToMatrix(pcr, scaleKin = sk)
saveRDS(pcr_mat, output$grm)
