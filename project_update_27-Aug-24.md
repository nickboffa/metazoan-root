# End of Winter Update


## Datasets




## Began Analysing Nosenko Datasets


 the commands you are using to do your analyses, and outlining how you plan to assess the results (e.g. plots, etc.) If you can provide example results from your initial small analyses, that will be very very useful!



## Results so far

### Nosenko2013 Nonribosomal Dataset

```
iqtree2 --seed 2222 -s ../Nosenko2013.nonrib.relabelled.outgroup_rem.fasta -p ../Nosenko2013_nonribosomal_partitions_formatted.nex -T 35 --prefix REV_nonrib
```

This gave the following REV_nonrib.treefile:

```
iqtree2 --seed 2222 -s ../Nosenko2013.nonrib.relabelled.outgroup_rem.fasta -p REV.best_scheme.nex -t REV.treefile --model-joint NONREV -B 1000 -T 35 --prefix NONREV_nonrib
```

Now 

### Nosenko2013 Ribosomal Dataset 


## Future Directions

### Use Larger Datasets (i.e. Laumer2018)
Upon seeing how odd the Nosenko2013 results were, I reviewed the rootstrap paper again, quickly finding several important points that I have so far completely ignored. Firstly, in the introduction (I've removed references)

"few studies have explored the accuracy of nonreversible substitution models to root phylogenetic trees. Most studies that have looked at this question in the past have focused on either simulated data sets or relatively small empirical data sets... no study has yet investigated the potential of amino acid substitution models in inferring the root placement of phylogenetic trees."

So the main contribution of the paper was to show the effectiveness of 1) nonreversible 2) amino acid substitution models using 3) large 4) empirical datasets to root phylogenies. The Nosenko2013 datasets, at <10,000 sites, is quite small. The datasets need to be large in order to 

Suha used genome-scale MSAs (>= 100,000 sites), and in Figure 3 and 5 demonstrated that the greater the number of parsimony-informative sites, the greater the rootstrap support


| Dataset              | Parsimony-informative Sites |
|----------------------|----------------------------|
| Nosenko2013 nonribosomal | 4558                       |
| Nosenko2013 ribosomal   | 8236                       |
| Laumer2018             | 72871                      |
| Simion2017             | 310886                     |


Of course, we weren't initially planning to

### Use the MaxSym test

Another finding of the rootstrap paper:

"Our results suggest that this may be the case for the data sets we analyzed: we show that removing loci that violate the stationarity and homogeneity assumptions improves the accuracy and statistical support for the placement of the root."

Following this recommendation, I should also try removing loci that fail the MaxSym test. Ideally, I would run each analysis twice (both before and after removing loci that fail MaxSym). However, 

## Assessing future results

### GLS and SLS

"To ascertain whether certain sites or loci had very strong effects on the placement of the root we follow the approach of Shen et al. (2017) and calculate the difference in site-wise log-likelihood scores (ΔSLS) and gene-wise log-likelihood scores (ΔGLS)"

As per Caitlin's research, I would expect that some sites

### BIC scores

Should make sure that the nonreversible model is actually a better fit than the reversible model by comparing the BIC scores for each.

## Problems
iqtree2 -s /Users/nicholasboffa/Library/CloudStorage/OneDrive-AustralianNationalUniversity/Uni/2024/Semester_2/SCNC2101/caitlin_files/whole_alignments/Simion2017.supermatrix_97sp_401632pos_1719genes.aa.alignment.fasta -m JC -n 0 -alninfo

Viewing sequences in Geneious is buggy, since the MSAs are quite large.



