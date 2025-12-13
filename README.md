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
an Rsq threshold of 0.3. The data were filtered using slightly less stringent
threshold than in the example workflow, then 2,000 variants were selected from
the middle of the file, so the example datasets committed in this repo can be
as small as possible. They were then separated into two cohorts and regions.

```sh
cd data
unzip chr_20.zip # Enter password included in automatic notification from TIS
tabix chr20.dose.vcf.gz
tabix chr20.info.gz

bcftools query -f '%ID\n' \
    -i 'INFO/AVG_CS < 0.95 || INFO/R2 < 0.49 || (INFO/MAF < 0.05 && INFO/R2 < 0.8)' \
    chr20.dose.vcf.gz > \
    temp_exclude.txt

zcat chr20.dose.vcf.gz | grep '^#CHROM' | cut -f 10- | tr '\t' '\n' > temp_all_samples.txt
split -l 26 temp_all_samples.txt cohort
mv cohortaa cohorta
mv cohortab cohortb
echo "chr20\t38368034\t38774586" > region1
echo "chr20\t38774587\t39130810" > region2

parallel 'bcftools view \
            -e "ID=@temp_exclude.txt" \
            -S {1} \
            -R {2} \
            chr20.dose.vcf.gz | \
        bgzip > \
        {1}_{2}.vcf.gz; tabix {1}_{2}.vcf.gz' ::: \
    cohorta cohortb ::: \
    region1 region2

bcftools view -r chr20:38368034-39130810 chr20.info.gz | \
    bgzip > \
    test.info.gz
tabix test.info.gz
rm *temp* cohorta cohortb region1 region2
```

## References

> Gogarten, S.M., Sofer, T., Chen, H., Yu, C., Brody, J.A., Thornton, T.A., Rice, K.M., and Conomos, M.P. (2019). Genetic association testing using the GENESIS R/Bioconductor package. _Bioinformatics_. doi:10.1093/bioinformatics/btz567.

> Köster, J., Mölder, F., Jablonski, K. P., Letcher, B., Hall, M. B., Tomkins-Tinch, C. H., Sochat, V., Forster, J., Lee, S., Twardziok, S. O., Kanitz, A., Wilm, A., Holtgrewe, M., Rahmann, S., & Nahnsen, S. _Sustainable data analysis with Snakemake_. F1000Research, 10:33, 10, 33, **2021**. https://doi.org/10.12688/f1000research.29032.2.

TOPMed Study — Taliun, D. et al. (2019) Sequencing of 53,831 diverse genomes from the NHLBI TOPMed Program. Biorxiv, doi:10.1101/563866
Imputation Server — Das, S., Forer, L., Schönherr, S., Sidore, C., Locke, A. E., Kwong, A., Vrieze, S. I., Chew, E. Y., Levy, S., McGue, M., Schlessinger, D., Stambolian, D., Loh, P.-R., Iacono, W. G., Swaroop, A., Scott, L. J., Cucca, F., Kronenberg, F., Boehnke, M., … Fuchsberger, C. (2016). Next-generation genotype imputation service and methods. Nature Genetics, 48(10), 1284–1287.
Minimac Imputation — Fuchsberger, C., Abecasis, G. R., & Hinds, D. A. (2014). minimac2: faster genotype imputation. Bioinformatics, 31(5), 782–784.
