logcon <- file(snakemake@log[[1]], open = "wt")
sink(logcon)
sink(logcon, type = "message")

input <- snakemake@input
output <- snakemake@output
params <- snakemake@params

library(SeqArray)
gds <- seqOpen(input$gds_fn)
if ("variant_id" %in% names(input)) {
    seqSetFilter(gds, variant.id = readRDS(input$variant_id))
}
if ("sample_id" %in% names(input)) {
    seqSetFilter(gds, sample.id = readRDS(input$sample_id))
}

arguments <- list(
    gdsfile = gds,
    parallel = as.numeric(snakemake@threads)
)

arguments <- c(arguments, params$seqAlleleFreq_args)

maf <- tibble::tibble(
    id = as.character(seqGetData(gds, "variant.id")),
    maf = do.call(seqAlleleFreq, arguments)
)

saveRDS(maf, output[[1]])
