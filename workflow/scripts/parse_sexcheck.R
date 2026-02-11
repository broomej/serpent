input <- snakemake@input
output <- snakemake@output
library(dplyr)

sexcheck <- read.table(input[[1]], header = TRUE, stringsAsFactors = FALSE)

pass <- filter(sexcheck, STATUS == "OK")$IID
fail <- filter(sexcheck, STATUS == "PROBLEM")$IID

if (length(fail) == 0) {
    message("No samples with STATUS == 'PROBLEM' found in sexcheck results.")
}

saveRDS(fail, output$fail)
saveRDS(pass, output$ok)
count(sexcheck, STATUS) %>%
    write.table(output$summary, quote = FALSE, sep = "\t", row.names = FALSE)