input <- snakemake@input
output <- snakemake@output
params <- snakemake@params
# The SeqArray functions expect some arguments with dots in their names, but
# that's an illegal character for Snakemake named params. Substitute
# underscores with dots.
names(params) <- gsub("_", ".", names(params))

library(SeqArray)
gds <- seqOpen(input$gds_fn)
if ("variant_id" %in% names(input)) {
    seqSetFilter(gds, readRDS(input$variant_id))
}
if ("sample_id" %in% names(input)) {
    seqSetFilter(gds, sample.id = readRDS(input$sample_id))
}

arguments <- list(
    gdsfile = gds,
    parallel = as.integer(snakemake@threads)
)

if (length(params) > 0) {
    for (n in names(params)) {
        arguments[[n]] <- params[[n]]
    }
}

if ("by.variant" %in% names(arguments)) {
    if (!arguments$by.variant) idtype <- "sample.id"
} else {
    idtype <- "variant.id"
}

ms <- tibble::tibble(
    id = as.character(seqGetData(gds, idtype)),
    missing_rate = do.call(seqMissing, arguments)
)

saveRDS(ms, output[[1]])
