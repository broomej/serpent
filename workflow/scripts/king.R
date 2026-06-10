logcon <- file(snakemake@log[[1]], open = "wt")
sink(logcon)
sink(logcon, type = "message")

input <- snakemake@input
output <- snakemake@output
params <- snakemake@params

library(ggplot2)
library(SeqArray)

gds <- seqOpen(input$gds_fn)

if ("seed" %in% names(params)) {
    set.seed(params[["seed"]])
}

arguments <- list(
    gdsobj = gds,
    num.thread = as.numeric(snakemake@threads)
)

arguments <- c(arguments, params$snpgdsIBDKING_args)

if ("snp_id" %in% names(input)) {
    arguments[["snp.id"]] <- readRDS(input$snp_id)
}
if ("sample_id" %in% names(input)) {
    arguments[["sample.id"]] <- readRDS(input$sample_id)
}
if ("family_id" %in% names(input)) {
    arguments[["family.id"]] <- readRDS(input$family_id)
}

king <- do.call(SNPRelate::snpgdsIBDKING, arguments)

rownames(king$kinship) <- king$sample.id
colnames(king$kinship) <- king$sample.id

saveRDS(king, snakemake@output$king)
saveRDS(king$kinship, snakemake@output$grm)
