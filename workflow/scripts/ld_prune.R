input <- snakemake@input
output <- snakemake@output
params <- snakemake@params
# The SeqArray functions expect some arguments with dots in their names, but
# that's an illegal character for Snakemake named params. Substitute
# underscores with dots.
names(params) <- gsub("_", ".", names(params))

library(SeqArray)
gds <- seqOpen(input$gds_fn)
arguments <- list(
    gdsobj = gds
)
if ("sample_id" %in% names(input)) {
    arguments[["sample.id"]] <- readRDS(input$sample_id)
}
if ("snp_id" %in% names(input)) {
    arguments[["snp.id"]] <- readRDS(input$snp_id)
}

if ("seed" %in% names(params)) {
    set.seed(params[["seed"]])
    params[["seed"]] <- NULL
}

if (length(params) > 0) {
    for (n in names(params)) {
        arguments[[n]] <- params[[n]]
    }
}

pruned <- do.call(SNPRelate::snpgdsLDpruning, arguments) |>
    unlist()
saveRDS(pruned, snakemake@output[[1]])
