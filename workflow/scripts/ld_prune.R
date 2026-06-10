logcon <- file(snakemake@log[[1]], open = "wt")
sink(logcon)
sink(logcon, type = "message")

input <- snakemake@input
output <- snakemake@output
params <- snakemake@params

library(SeqArray)
gds <- seqOpen(input$gds_fn)
arguments <- list(
    gdsobj = gds
)
if ("sample_id" %in% names(input)) {
    arguments[["sample.id"]] <- readRDS(input$sample_id)
}
if ("snp_id" %in% names(input)) {
    arguments[["snp.id"]] <- readRDS(input$snp_id)
}

if ("seed" %in% names(params)) {
    set.seed(params[["seed"]])
}

if (!is.null(snakemake@threads)) {
    arguments[["num.thread"]] <- snakemake@threads
}

arguments <- c(arguments, params$snpgdsLDpruning_args)

pruned <- do.call(SNPRelate::snpgdsLDpruning, arguments) |>
    unlist()
saveRDS(pruned, snakemake@output[[1]])
