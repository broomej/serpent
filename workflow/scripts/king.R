input <- snakemake@input
output <- snakemake@output
params <- snakemake@params
names(params) <- gsub("_", ".", names(params))

library(ggplot2)
library(SeqArray)

gds <- seqOpen(input$gds_fn)

if ("seed" %in% names(params)) {
    set.seed(params[["seed"]])
    params[["seed"]] <- NULL
}

arguments <- list(
    gdsobj = gds,
    num.thread = as.numeric(snakemake@threads)
)

if (length(params) > 0) {
    for (n in names(params)) {
        arguments[[n]] <- params[[n]]
    }
}

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
