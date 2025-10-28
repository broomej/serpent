#! /usr/bin/env Rscript

library(ggplot2)
library(GGally)

input <- snakemake@input
output <- snakemake@output
params <- snakemake@params
kinthresh <- params$kinthresh
divthresh <- params$kinthresh
num_thread <- as.integer(snakemake@threads)
divmat <- readRDS(input$div)
kinmat <- readRDS(input$kin)

if (is.null(input$unrels)) {
    unrels <- NULL
} else {
    unrels <- readRDS(input$unrels)
}

gds <- SeqArray::seqOpen(input$gds)
pca <- GENESIS::pcair(
    gds,
    kinobj = kinmat,
    kin.thresh = kinthresh,
    divobj = divmat,
    div.thresh = divthresh,
    snp.include = readRDS(input$var),
    unrel.set = unrels,
    num.cores = num_thread
)

saveRDS(pca, output$pcair)
saveRDS(pca$vectors, output$pcs)
saveRDS(pca$unrels, output$unrels)
saveRDS(pca$rels, output$rels)

pcs <- as.data.frame(pca$vectors[pca$unrels,])
n <- ncol(pcs)
names(pcs) <- paste0("PC", 1:n)
pcs$sample.id <- row.names(pcs)

dat <- data.frame(pc = seq(n), varprop=pca$varprop[seq(n)])
p <- ggplot(dat, aes(x=factor(pc), y=100*varprop)) +
    geom_point() +
    theme_bw() +
    xlab("PC") +
    ylab("Percent of variance accounted for")
ggsave(output$scree, plot=p, width=6, height=6)

npr <- min(params$n_pairs, n)
p <- ggpairs(pcs,
    columns = 1:npr,
    lower = list(continuous = wrap("points", alpha = 0.5)),
    diag = list(continuous = "densityDiag"),
    upper = list(continuous = "blank"),
    legend = c(npr, npr)
)

ggsave(output$pairs, p, width=12, height=12, units="in")
