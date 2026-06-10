logcon <- file(snakemake@log[[1]], open = "wt")
sink(logcon)
sink(logcon, type = "message")

input <- snakemake@input
output <- snakemake@output
params <- snakemake@params
parallel <- params$parallel

library(SeqVarTools)
library(dplyr)
library(magrittr)
gds <- seqOpen(input$gds_fn)
if ("variant_id" %in% names(input)) {
    seqSetFilter(gds, variant.id = readRDS(input$variant_id))
}
if ("sample_id" %in% names(input)) {
    seqSetFilter(gds, sample.id = readRDS(input$sample_id))
}

if ("seed" %in% names(params)) {
    set.seed(params[["seed"]])
}

hwe_pmt <- hwe(gds, permute = TRUE, parallel = parallel) %>%
    arrange(p)

hwe <- hwe(gds, permute = FALSE, parallel = parallel) %>%
    arrange(p) %>%
    mutate(id = as.character(variant.id))
hwe$p_perm <- hwe_pmt$p
saveRDS(hwe, output[[1]])
