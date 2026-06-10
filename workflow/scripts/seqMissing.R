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
    parallel = as.integer(snakemake@threads)
)
arguments <- c(arguments, params$seqMissing_args)


idtype <- "variant.id"
if ("per.variant" %in% names(arguments)) {
    if (!arguments$per.variant) {
        idtype <- "sample.id"
    }
}

ms <- tibble::tibble(
    id = as.character(seqGetData(gds, idtype)),
    missing_rate = do.call(seqMissing, arguments)
)

saveRDS(ms, output[[1]])
