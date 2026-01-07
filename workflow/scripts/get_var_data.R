input <- snakemake@input
output <- snakemake@output
params <- snakemake@params
library(SeqArray)

gds <- seqOpen(input$gds_fn)
if ("variant_id" %in% names(input)) {
    seqSetFilter(gds, variant.id = readRDS(input$variant_id))
}
if ("sample_id" %in% names(input)) {
    seqSetFilter(gds, sample.id = readRDS(input$sample_id))
}

var <- tibble::tibble(
    id = as.character(seqGetData(gds, "variant.id")),
    annotation.id = as.character(seqGetData(gds, "annotation/id")),
    chr = seqGetData(gds, "chromosome"),
    pos = seqGetData(gds, "position"),
    allele = seqGetData(gds, "allele")
)
pca_filt <- get(data(
    list = paste0("pcaSnpFilters.", params$build),
    package = "GWASTools"
))
var$pcaSnpFilter <- TRUE
for (x in pca_filt$chrom) {
    region <- pca_filt[pca_filt$chrom == x, ]
    idx <- var$chr == x &
        dplyr::between(var$pos, region$start.base - 1, region$end.base + 1)
    var$pcaSnpFilter[idx] <- FALSE
}

saveRDS(var, output[[1]])
