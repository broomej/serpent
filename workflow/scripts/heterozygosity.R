input <- snakemake@input
output <- snakemake@output
params <- snakemake@params
# The SeqArray functions expect some arguments with dots in their names, but
# that's an illegal character for Snakemake named params. Substitute
# underscores with dots.
names(params) <- gsub("_", ".", names(params))

library(SeqVarTools)
gds <- seqOpen(input$gds_fn)
if ("variant_id" %in% names(input)) {
    seqSetFilter(gds, variant.id = readRDS(input$variant_id))
}
if ("sample_id" %in% names(input)) {
    seqSetFilter(gds, sample.id = readRDS(input$sample_id))
}
arguments <- list(
    gdsobj = gds,
    parallel = as.numeric(snakemake@threads),
    use.names = TRUE
)

if (length(params) > 0) {
    for (n in names(params)) {
        arguments[[n]] <- params[[n]]
    }
}

htz <- do.call(heterozygosity, arguments)
out <- tibble::tibble(
    id = as.character(names(htz)),
    heterozygosity = htz
)

saveRDS(out, output[[1]])
