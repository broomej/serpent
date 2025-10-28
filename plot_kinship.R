#! /usr/bin/env Rscript
input <- snakemake@input
output <- snakemake@output
library(ggplot2)

rel <- readRDS(input[[1]])
is_king <- "snpgdsIBDClass" %in% class(rel)

if(is_king){
	kinship <- SNPRelate::snpgdsIBDSelection(rel)
    x_axis <- "IBS0"
    y_axis <- "kinship"
} else {
	kinship <- rel$kinBtwn
    x_axis <- "k0"
    y_axis <- "kin"
}

p <- ggplot(kinship, aes_string(x_axis, y_axis)) +
    geom_hline(yintercept=2^(-seq(3,9,2)/2), linetype="dashed", color = "grey") +
    geom_point(alpha=0.2) +
    ylab("kinship estimate") +
    ggtitle("kinship")
ggsave(output[[1]], p)