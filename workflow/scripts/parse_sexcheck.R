input <- snakemake@input
output <- snakemake@output

sexcheck <- read.table(input[[1]], header = TRUE, stringsAsFactors = FALSE)

pass <- dplyr::filter(sexcheck, STATUS == "OK")$IID
fail <- dplyr::filter(sexcheck, STATUS == "PROBLEM")$IID

if (length(fail) == 0) {
    message("No samples with STATUS == 'PROBLEM' found in sexcheck results.")
}

saveRDS(fail, output$fail)
writeLines(table(sexcheck$STATUS, useNA = "ifany"), output$summary)
saveRDS(pass, output$ok)
