#! /usr/bin/env Rscript

library(ggplot2)
library(magrittr)
library(dplyr)

input <- snakemake@input
output <- snakemake@output
params <- snakemake@params

n_pairs <- params$n_pairs
params$n_pairs <- NULL
ggroup <- params$pc_pairs_group
params$pc_pairs_group <- NULL
id_name <- params$id_name
params$id_name <- NULL
pairs_prfx <- params$pairs_prfx
params$pairs_prfx <- NULL

gds <- SeqArray::seqOpen(input$gds_fn)
arguments <- list(
    gdsobj = gds,
    divobj = readRDS(input$divobj),
    kinobj = readRDS(input$kinobj),
    num.cores = as.integer(snakemake@threads)
)

if (!is.null(input$unrel_set)) {
    arguments$unrel.set <- readRDS(input$unrel_set)
}
if (!is.null(input$sample_include)) {
    arguments$sample.include <- readRDS(input$sample_include)
}
if (!is.null(input$snp_include)) {
    arguments$snp.include <- readRDS(input$snp_include)
}

if (length(params) > 0) {
    for (n in names(params)) {
        arguments[[n]] <- params[[n]]
    }
}

names(arguments) <- gsub("_", ".", names(arguments))

pca <- do.call(GENESIS::pcair, arguments)

saveRDS(pca, output$pcair)
saveRDS(pca$vectors, output$pcs)
saveRDS(pca$unrels, output$unrels)
saveRDS(pca$rels, output$rels)
pcs <- as.data.frame(pca$vectors[pca$unrels, ])

n <- ncol(pcs)
names(pcs) <- paste0("PC", 1:n)
pcs$sample.id <- row.names(pcs)

dat <- data.frame(pc = seq(n), varprop = pca$varprop[seq(n)])
p <- ggplot(dat, aes(x = factor(pc), y = 100 * varprop)) +
    geom_point() +
    theme_bw() +
    xlab("PC") +
    ylab("Percent of variance accounted for")
ggsave(output$scree, plot = p, width = 6, height = 6)

npr <- min(n_pairs, n)

if ("pheno" %in% names(input)) {
    pheno <- readRDS(input$pheno)[, c(id_name, ggroup)]
    pcs %<>% left_join(pheno, c(sample.id = id_name))
}
for (i in 1:(npr - 1)) {
    p <- ggplot(
        pcs,
        aes_string(x = names(pcs)[i + 1L], y = names(pcs)[i], color = ggroup)
    ) +
        geom_point(alpha = 0.5, size = 1) +
        theme_bw()
    outname <- sprintf("%s_PC%s_PC%s.png", pairs_prfx, i, i + 1L)
    ggsave(outname, p, width = 6, height = 6)
}
