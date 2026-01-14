input <- snakemake@input
output <- snakemake@output

sexcheck <- read.table(input[[1]], header = TRUE, stringsAsFactors = FALSE)

pass <- dplyr::filter(sexcheck, STATUS == "OK")$IID
fail <- dplyr::filter(sexcheck, STATUS == "PROBLEM")$IID

if (length(fail) > 0) {
    saveRDS(fail, output$fail_sexcheck)
} else {
    message("No samples with STATUS == 'PROBLEM' found in sexcheck results.")
}

writeLines(table(sexcheck$STATUS, useNA = "ifany"), output$sexcheck_summary)
saveRDS(pass, output$pass_sexcheck)
