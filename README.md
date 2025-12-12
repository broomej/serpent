# Serpent: A Snakemake implementation of GENetic EStimation and Inference in Structured samples (GENESIS)

## Usage

Clone this repo as a submodule in your Snakemake project in the appropriate
location, typically `[PROJECT]/workflow/scripts`.

## Testing

### Test data

Test data were generated from
[example data provided on the TOPMed Imputation Server](https://topmedimpute.readthedocs.io/en/latest/workshops/ASHG2023/Session2/).
Data downloaded from this page were lifted from hg19 to hg38, imputed, and
phased on the TIS and bundled in this repo. Data were filtered on the TIS using
an Rsq threshold of 0.3.

```sh
unzip chr_20.zip # Enter password included in automatic notification from TIS

# Index the bgzipped VCF file

tabix chr20.dose.vcf.gz


bcftools view --regions chr20:4686456-4786456 chr20.dose.vcf.gz | \
    bgzip -c > \
    test.vcf.gz
tabix test.vcf.gz

```

## References

> Gogarten, S.M., Sofer, T., Chen, H., Yu, C., Brody, J.A., Thornton, T.A., Rice, K.M., and Conomos, M.P. (2019). Genetic association testing using the GENESIS R/Bioconductor package. _Bioinformatics_. doi:10.1093/bioinformatics/btz567.

> Köster, J., Mölder, F., Jablonski, K. P., Letcher, B., Hall, M. B., Tomkins-Tinch, C. H., Sochat, V., Forster, J., Lee, S., Twardziok, S. O., Kanitz, A., Wilm, A., Holtgrewe, M., Rahmann, S., & Nahnsen, S. _Sustainable data analysis with Snakemake_. F1000Research, 10:33, 10, 33, **2021**. https://doi.org/10.12688/f1000research.29032.2.

TOPMed Study — Taliun, D. et al. (2019) Sequencing of 53,831 diverse genomes from the NHLBI TOPMed Program. Biorxiv, doi:10.1101/563866
Imputation Server — Das, S., Forer, L., Schönherr, S., Sidore, C., Locke, A. E., Kwong, A., Vrieze, S. I., Chew, E. Y., Levy, S., McGue, M., Schlessinger, D., Stambolian, D., Loh, P.-R., Iacono, W. G., Swaroop, A., Scott, L. J., Cucca, F., Kronenberg, F., Boehnke, M., … Fuchsberger, C. (2016). Next-generation genotype imputation service and methods. Nature Genetics, 48(10), 1284–1287.
Minimac Imputation — Fuchsberger, C., Abecasis, G. R., & Hinds, D. A. (2014). minimac2: faster genotype imputation. Bioinformatics, 31(5), 782–784.
