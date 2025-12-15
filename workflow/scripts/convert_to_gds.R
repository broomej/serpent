input <- snakemake@input
output <- snakemake@output
params <- snakemake@params

# The S4 snakemake object can duplicate inputs; remove unnamed ones.
if (any(names(input) == "")) {
    input <- input[!(names(input) == "")]
}

# *.vcf.gz.tbi index files are required by rule vcf_to_gds but they are not
# passed to seqVCF2GDS, so remove them here.
input <- input[!(names(input) == "tbi")]

# The SeqArray functions expect some arguments with dots in their names, but
# that's an illegal character for Snakemake named inputs/outputs/params.
# Substitute underscores with dots.
names(input) <- gsub("_", ".", names(input))
names(params) <- gsub("_", ".", names(params))
names(output) <- gsub("_", ".", names(output))

arguments <- c(input, output[[1]], params)
print(arguments)

vcf_in <- any("vcf.fn" %in% names(input))
bcf_in <- any("bcf.fn" %in% names(input))
bed_in <- any("bed.fn" %in% names(input))
bim_in <- any("bim.fn" %in% names(input))
fam_in <- any("fam.fn" %in% names(input))

if ((vcf_in + any(bed_in, bim_in, fam_in) + bcf_in) > 1) {
    stop("Supply either VCF, BCF, or PLINK bfiles, not a mix.")
}

if (vcf_in) {
    do.call(SeqArray::seqVCF2GDS, arguments)
} else if (bcf_in) {
    do.call(SeqArray::seqBCF2GDS, arguments)
} else if (all(c(bed_in, bim_in, fam_in))) {
    do.call(SeqArray::seqBED2GDS, arguments)
} else {
    stop("Input files must be either VCF, BCF, or PLINK bfiles.")
}
