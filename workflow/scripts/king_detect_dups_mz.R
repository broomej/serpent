logcon <- file(snakemake@log[[1]], open = "wt")
sink(logcon)
sink(logcon, type = "message")

input <- snakemake@input
output <- snakemake@output
params <- snakemake@params



kinship <- readRDS(input$king) |> SNPRelate::snpgdsIBDSelection()

dplyr::filter(kinship, kinship >= params$threshold) |>
    saveRDS(output$dups)
dplyr::filter(kinship, kinship < params$threshold) |>
    saveRDS(output$dups_removed)
