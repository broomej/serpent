logcon <- file(snakemake@log[[1]], open = "wt")
sink(logcon)
sink(logcon, type = "message")

input <- snakemake@input
output <- snakemake@output
params <- snakemake@params

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

arguments <- c(arguments, params$heterozygosity_args)
htz <- do.call(heterozygosity, arguments)
out <- tibble::tibble(
    id = as.character(names(htz)),
    heterozygosity = htz
)

saveRDS(out, output[[1]])
