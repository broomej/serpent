input <- snakemake@input
output <- snakemake@output
params <- snakemake@params



kinship <- readRDS(input$king) |> SNPRelate::snpgdsIBDSelection()

dplyr::filter(kinship, kinship >= params$threshold) |>
    saveRDS(output$dups)
dplyr::filter(kinship, kinship < params$threshold) |>
    saveRDS(output$dups_removed)
