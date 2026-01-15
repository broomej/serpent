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
    params[["seed"]] <- NULL
}

hwe_pmt <- hwe(gds, permute = TRUE, parallel = parallel) %>%
    select(variant.id, p_perm = p)

hwe(gds, permute = FALSE, parallel = parallel) %>%
    left_join(hwe_pmt, by = "variant.id") %>%
    mutate(id = as.character(variant.id)) %>%
    saveRDS(output[[1]])
