# Serpent: A Snakemake implementation of GENetic EStimation and Inference in Structured samples (GENESIS)

## Usage

Clone this repo as a submodule in your Snakemake project in the appropriate
location, typically `[PROJECT]/workflow/scripts`.

## Testing

### Test data

Test data were downloaded and subsetted from the 1000 Genomes Project with the
following commands:

```sh
source_file=ALL.chr22.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf.gz
outfile=test_data_1KG.vcf.gz
wget ftp://ftp-trace.ncbi.nih.gov/1000genomes/ftp/release/20130502/$source_file
wget ftp://ftp-trace.ncbi.nih.gov/1000genomes/ftp/release/20130502/$source_file.tbi

bcftools view --regions 22:16050070-16050170 $source_file | \
    bgzip -c > \
    $outfile
tabix $outfile

rm $source_file $source_file.tbi
```

## References

> Gogarten, S.M., Sofer, T., Chen, H., Yu, C., Brody, J.A., Thornton, T.A., Rice, K.M., and Conomos, M.P. (2019). Genetic association testing using the GENESIS R/Bioconductor package. _Bioinformatics_. doi:10.1093/bioinformatics/btz567.

> Köster, J., Mölder, F., Jablonski, K. P., Letcher, B., Hall, M. B., Tomkins-Tinch, C. H., Sochat, V., Forster, J., Lee, S., Twardziok, S. O., Kanitz, A., Wilm, A., Holtgrewe, M., Rahmann, S., & Nahnsen, S. _Sustainable data analysis with Snakemake_. F1000Research, 10:33, 10, 33, **2021**. https://doi.org/10.12688/f1000research.29032.2.

> The 1000 Genomes Project Consortium. A global reference for human genetic variation. Nature 526, 68–74 (2015)