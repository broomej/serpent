input <- snakemake@input
output <- snakemake@output
params <- snakemake@params

library(SeqArray)
gds <- seqOpen(input[[1]])
arguments <- list(
    gdsfile = gds,
    per.variant = TRUE,
    parallel = as.numeric(snakemake@threads)
)

if (length(params) > 0) {
    for (n in names(params)) {
        arguments[[n]] <- params[[n]]
    }
}

var_ms <- tibble::tibble(
    id = seqGetData(gds, "variant.id"),
    missing_rate = do.call(seqMissing, arguments)
)

saveRDS(var_ms, output[[1]])
