input <- snakemake@input
output <- snakemake@output
params <- snakemake@params
# The SeqArray functions expect some arguments with dots in their names, but
# that's an illegal character for Snakemake named params. Substitute
# underscores with dots.
names(params) <- gsub("_", ".", names(params))

library(SeqArray)
gds <- seqOpen(input[[1]])
arguments <- list(
    gdsfile = gds,
    parallel = as.numeric(snakemake@threads)
)

if (length(params) > 0) {
    for (n in names(params)) {
        arguments[[n]] <- params[[n]]
    }
}

maf <- tibble::tibble(
    id = seqGetData(gds, "variant.id"),
    maf = do.call(seqAlleleFreq, arguments)
)

saveRDS(maf, output[[1]])
