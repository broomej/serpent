#! /usr/bin/env Rscript
# Snakemake doesn't like dots in names of inputs, outputs, etc. Replace
# underscores with dots to match arguments of seqBED2GDS.
input <- snakemake@input
# the S4 snakemake object duplicates inputs, one with names and one without.
# Remove the unnamed ones to pass to do.call.
input <- input[!(names(input) == "")]
names(input) <- gsub("_", ".", names(input))
arguments <- c(input, snakemake@params[[1]],
               out.gdsfn = snakemake@output$out_gdsfn)
do.call(SeqArray::seqBED2GDS, arguments)
sessionInfo()
