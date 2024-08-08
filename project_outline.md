# Project Outline

## 1. The overall aims of your project (you can be brief, but provide links to key papers etc)
  
The relatively simpler morphology of sponges (porifera) and all other metazoans meant that they were traditionally considered to be the first species to split in the metazoan clade, in line with traditional intuitions a la the Great Chain of Being. However, Dunn et. al (2008; https://www.nature.com/articles/nature06614) determined that comb jellies (ctenophora) were the first to split, instigating a lengthy back-and-forth on which is the true root. Most recently, Schultz et. al (2023; https://www.nature.com/articles/s41586-023-05936-6) claimed that synteny supports the ctenophora-sister hypothesis.

Invariably, studies have used the outgroup rooting method. However, Naser-Khdour et. al (2022) recently demonstrated the efficacy of non-reversible amino acid models in rooting phylogenetic trees. This method has the advantage of removing the long branch of the outgroup from the tree, thus mitigating long branch attraction - an artifact thought to be contributing to the conflicting phylogenetic inferences. In this project, we aim apply this rooting method to the metazoan tree.
	
## 3. What dataset(s) you will use and why

### Nosenko *et. al* 2013 
https://www.sciencedirect.com/science/article/pii/S1055790313000298?via%3Dihub#b0365

The two parts of the dataset (nonribosomal and ribosomal) led to the inference of two different tree topologies using the CAT model. Hence, it will be interesting to see whether using nonreversible models leads to both having the same answer this time.



The nonribosomal and ribosomal Nosenko 2013 dataset, and time allowing the Laumer 2018 dataset.


### Laumer 2018

A bigger dataset; contains a partitioning scheme (unlike Laumer 2019)



## 5. A brief description of the dataset(s)

### Nosenko *et. al* 2013 

Copying part of the table from the paper:

| Gene matrix | n_Taxa | n_Genes | Matrix length (aa) | Variable site # | Allowed % missing data per taxon | Missing characters total (%) |
|-------------|---------|--------|--------------------|-----------------|----------------------------------|------------------------------|
| Ribosomal   | 63      | 87     | 14,615             | 10,445          | 95                               | 28                           |
| Non-ribosomal | 63	| 35	| 9187	| 6322	| 95	| 36 |

They have already done their best to remove paralogous genes


## 6. Describe a small subset of the data that you can test your code on (e.g. 10 or 20 loci; and if your dataset has a lot of species, a subset of those, how many you'll choose, and how you'll select them)

If I choose the




## 7. The plan for what commands you'll need to run your analysis, with a description of what each one does (e.g. IQ-TREE commands, ASTRAL commands). This can be an overview, but try to think through all the steps. Don't worry if you are unsure, just do your best. Feel free to try them out as you go, based on what you've learned in the tutorials. And if you need to do something that you don't know a command for (e.g. Select 10 species at random from your alignment) that's OK - just put what you want to do as a comment without code, and we can then all help each other figure out the best way to do things.

**Clean Data**

* Remove all outgroup taxa from datasets.
* Choose taxa / genes with similar rates of evolution

**Analyse Nosenko 2013 dataset**

Run the NONREV model on the dataset, using the partition given by Caitlin 

	*iqtree2 -s Nosenko2013_nonribosomal_nooutgroup.phy -p Nosenko2013_nonribosomal_partitions_formatted.nex --model-joint NONREV -B 1000 -T AUTO --prefix nrv_nos_nr* (nonreversible Nosenko non-ribosomal)
	*iqtree2 -s Nosenko2013_nonribosomal_nooutgroup.phy -p Nosenko2013_nonribosomal_partitions_formatted.nex --model-joint NONREV -B 1000 -T AUTO --prefix nrv_nos_nr* 

**Analyse

When choosing genes and taxa, want to ensure that rates of evolution between them all are similar


## 8. What you will measure and why (i.e. How you will know if what you are doing is good / is working / etc.)

"All IQ-TREE analyses, apart from unresolved analyses (for Moroz2014_3d and all Nosenko 2013 matrices), supported Ctenophora-sister (fig. 3B). No IQ-TREE analyses supported Porifera-sister"
   * Rootstrap support values
   * Bootstrap/UFBoot support values
	
