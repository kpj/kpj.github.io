# rwrap: Seamlessly integrate R packages into Python

The world of data science is largely divided into the Python pioneers and R rascals (in a loving way) with a few honorable mentions.
These two camps strive for supremacy, each offering their own set of distinctive advantages. This shall not be a review of these, but simply highlight that the [tidyverse](https://www.tidyverse.org/) and [Bioconductor](https://www.bioconductor.org/) ecosystems make a strong case for R.
However, since Python is evidently the better language (citation needed), accessing the vast amount of R-specific functionality offered by Bioconductor packages directly from Python would be quite glamorous.

[rwrap](https://github.com/kpj/rwrap) aims at doing exactly that. By providing a wrapper around [rpy2](https://rpy2.github.io/) and adding many additional data conversion rules, it removes the need for loads of boilerplate code and makes using R packages in Python easier.

For example, running a Differential Gene Expression analysis and adding genomic annotations using the R packages [DESeq2](https://bioconductor.org/packages/release/bioc/html/DESeq2.html) and [biomaRt](https://bioconductor.org/packages/release/bioc/html/biomaRt.html) can now look like this in Python:

```python
import pandas as pd
from rwrap import DESeq2, biomaRt, base, stats


DESeq2
## <module 'DESeq2' from '/Library/Frameworks/R.framework/Versions/4.1/Resources/library/DESeq2'>
biomaRt
## <module 'biomaRt' from '/Library/Frameworks/R.framework/Versions/4.1/Resources/library/biomaRt'>


# retrieve count data (https://trace.ncbi.nlm.nih.gov/Traces/sra/?study=SRP009615)
df_counts = pd.read_csv(
    "http://duffel.rail.bio/recount/v2/SRP009615/counts_gene.tsv.gz", sep="\t"
).set_index("gene_id")
df_design = pd.DataFrame(
    {"condition": ["1", "2", "1", "2", "3", "4", "3", "4", "5", "6", "5", "6"]}
)

# run differential gene expression analysis
dds = DESeq2.DESeqDataSetFromMatrix(
    countData=df_counts, colData=df_design, design=stats.as_formula("~ condition")
)
dds = DESeq2.DESeq(dds)

res = DESeq2.results(dds, contrast=("condition", "1", "2"))
df_res = base.as_data_frame(res)

# annotate result
ensembl = biomaRt.useEnsembl(biomart="genes", dataset="hsapiens_gene_ensembl")
df_anno = biomaRt.getBM(
    attributes=["ensembl_gene_id_version", "gene_biotype"],
    filters="ensembl_gene_id_version",
    values=df_res.index,
    mart=ensembl,
).set_index("ensembl_gene_id_version")

df_res = df_res.merge(df_anno, left_index=True, right_index=True).sort_values("padj")
print(df_res.head())  # pd.DataFrame
##                      baseMean  log2FoldChange     lfcSE      stat        pvalue          padj          gene_biotype
## ENSG00000222806.1  158.010377       22.137400  2.745822  8.062214  7.492501e-16  2.853744e-11       rRNA_pseudogene
## ENSG00000255099.1   65.879611       21.835651  2.915452  7.489627  6.906949e-14  1.315359e-09  processed_pseudogene
## ENSG00000261065.1   92.351998       22.273400  3.144991  7.082182  1.419019e-12  1.351190e-08                lncRNA
## ENSG00000249923.1  154.037908       18.364027  2.636083  6.966407  3.251381e-12  2.476772e-08                lncRNA
## ENSG00000267658.1   64.371181      -19.545702  3.041247 -6.426871  1.302573e-10  8.268736e-07                lncRNA
```
