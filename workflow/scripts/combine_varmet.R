input <- unique(snakemake@input)
output <- snakemake@output

library(dplyr)
library(purrr)

lapply(input, readRDS) %>%
    reduce(full_join, by = "id") %>%
    saveRDS(output[[1]])
