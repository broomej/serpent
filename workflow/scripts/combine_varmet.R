logcon <- file(snakemake@log[[1]], open = "wt")
sink(logcon)
sink(logcon, type = "message")

input <- unique(snakemake@input)
output <- snakemake@output

library(dplyr)
library(purrr)

lapply(input, readRDS) %>%
    reduce(full_join, by = "id") %>%
    saveRDS(output[[1]])
