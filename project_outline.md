# Project Outline

## 1. The overall aims of your project (you can be brief, but provide links to key papers etc)
  
The relatively simpler morphology of sponges (porifera) and all other metazoans meant that they were traditionally considered to be the first species to split in the metazoan clade, in line with traditional intuitions a la the Great Chain of Being. However, Dunn et. al (2008; https://www.nature.com/articles/nature06614) determined that comb jellies (ctenophora) were the first to split, instigating a lengthy back-and-forth on which is the true root.

Invariably, studies have used the outgroup rooting method. However, Naser-Khdour et. al (2022; https://academic.oup.com/sysbio/article/71/4/959/6350503) recently demonstrated the efficacy of non-reversible amino acid models in rooting phylogenetic trees. This method has the advantage of removing the long branch of the outgroup from the tree, thus mitigating long branch attraction - an artifact thought to be contributing to the conflicting phylogenetic inferences. 

In this project, we aim to apply to apply this rooting method to the metazoan tree, and in doing so help to resolve some of the debate over the underlying causes of the conflicting signal.


## 2. What dataset(s) you will use and why

### Nosenko *et. al* 2013 
https://www.sciencedirect.com/science/article/pii/S1055790313000298?via%3Dihub#b0365

In their analysis, the two parts of the dataset (nonribosomal and ribosomal) led to the inference of two different tree topologies using the CAT model. The nonribosomal part recovered Ctenophore-sister, whilst ribosomal recovered Porifera-sister. Hence, it would be interesting to see whether using nonreversible models leads to both having the same answer this time. Additionally, the datasets are relatively small and so provide good opportunity to get my feet wet.

When reanalysing the Nosenko 2013 data, Li *et. al* (2021) found that their IQ-TREE analyses of the Nosenko 2013 data didn't conclusively support either relationship (in this case meaning bootstrap < 90%).

One thing to bear in mind is that Nosenko found that the ribosomal matrix showed much lower saturation than the non-ribosomal one.

### Laumer 2018
https://elifesciences.org/articles/36278#s3

This is a much bigger dataset than the Nosenko ones, and so should mean there is greater chance of picking up on the phylogenetic signal in the data. 
Unlike Laumer 2019, it also contains a partitioning scheme. Also, though Simion (2017) is the largest dataset, it is probably not computationally tractable - Laumer 2018 will hopefully be as large a dataset as ew can get whilst still being tractable.
## 3. A brief description of the dataset(s)

### Nosenko *et. al* 2013 

The data set has 71 species:
- 21 poriferans, 
- 2 placozoans
- 4 ctenophores
- 13 cnidarians,
- 21 bilaterians
- 3 choanoflagellates
- 2 ichthyosporeans
- 1 filasterean
- 4 fungi

Copying part of the table from the paper **below is for the data after they removed all outgroups except choanoflagellates (which somehow ended as 63 taxa despite 71-7=64?)**

| Gene matrix | n_Taxa | n_Genes | Matrix length (aa) | Variable site # | Allowed % missing data per taxon | Missing characters total (%) |
|-------------|---------|--------|--------------------|-----------------|----------------------------------|------------------------------|
| Ribosomal   | 63      | 87     | 14,615             | 10,445          | 95                               | 28                           |
| Non-ribosomal | 63	| 35	| 9187	| 6322	| 95	| 36 |

They have already done their best to remove paralogous genes, and genes with compositional biases across taxa.

### Laumer *et. al* 2018

We are using their 'BUSCO' matrix. It has 59 taxa, 94444aa long, 303 genes, 39.6% of sites are gaps/missing data, and the mean (sd) partition length is 311.70 (202.78). The aim of this matrix was to only contain 'complete, single-copy sequences'. There are:

-  6 ctenophores
- 15 poriferans
- 4 placozoans
- 13 cnidarians
- 14 bilaterians
- 7 outgroup taxa

Again, they have tested for paralogy. They also found that there is compositional bias across lineages in the data - mainly due to the compositional differences of Choanoflagellata and Placozoa compared to the rest of Metazoa.

## 4. Describe a small subset of the data that you can test your code on (e.g. 10 or 20 loci; and if your dataset has a lot of species, a subset of those, how many you'll choose, and how you'll select them)

Though the Nosenko non-ribosomal matrix is relatively small, it is still probably too large to quickly test code with. Hence, I would like to create a smaller dataset containing A) no outgroups, and B) a maximum of 4 species per clade, and C) 20 randomly sampled genes from the alignment. So in this test dataset there would be:

- 4 poriferans 
- 2 placozoans
- 4 ctenophores
- 4 cnidarians
- 4 bilaterians

For a total of 18 species and 20 genes. NB: I don't know how to go about creating this dataset aside from doing it all manually, with the help of random selections using R.


## 5. The plan for what commands you'll need to run your analysis, with a description of what each one does (e.g. IQ-TREE commands, ASTRAL commands). This can be an overview, but try to think through all the steps. Don't worry if you are unsure, just do your best. Feel free to try them out as you go, based on what you've learned in the tutorials. And if you need to do something that you don't know a command for (e.g. Select 10 species at random from your alignment) that's OK - just put what you want to do as a comment without code, and we can then all help each other figure out the best way to do things.


### For dataset \in {Nosenko2013_nonribosomal, Nosenko2013_ribosomal, Laumer2018}:

1. Remove outgroups from dataset

2. Find ML rooted tree, with rootstrap

```
# step 1
iqtree2 --seed 2222 -s ../test_data.fasta -p ../Nosenko2013_nonribosomal_partitions_formatted.nex -b 100 -T 7 --prefix rev_aa

# step 2: infer rooted tree with linked non-reversible models
iqtree2 --seed 2222 -s ../test_data.fasta -p rev_aa.best_scheme.nex --model-joint NONREV -b 100 -T 7 --prefix nonrev_aa
```

3. Perform AU test (and REEL?)
iqtree2 –s ../test_data.fasta –p rev_aa.best_scheme.nex -–model-joint NONREV --root-test –zb 1000 –au –te nonrev_aa.treefile --prefix TOP


### Things I need to keep in mind

When choosing genes and taxa, want to ensure that rates of evolution between them all are similar

- Li *et. al* (2021) found that the studies that tend to recover Porifera-sister use A) CAT models (especially with an unrestricted number of categories; in general more site categories -> more likely to get Porifera-sister), and B) choanoflagelletes as the only outgroup. By this logic it would be expected that we recover Ctenophore-sister, and so if we don't that's notable.

- Try to follow recommendations in https://www.ncbi.nlm.nih.gov/pmc/articles/PMC9452790/


## 6. What you will measure and why (i.e. How you will know if what you are doing is good / is working / etc.)

To see how well the root and topology is supported by the data, will measure both Rootstrap and Bootstrap/UFBoot support values.

Could also calculate concordance factors for each gene in the datasets, to see if there are any large conflicts between gene trees and the ML species tree. This has already been done for Laumer 2018, but could do it for Nosenko 2013.

To test the quality of the data, should measure compositional heterogeneity across taxa. I suppose this is done by measuring the aa frequencies in each taxa and comparing them somehow?



	

