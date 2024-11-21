# The Project

This repository was created for a research project I completed in Semester 2, 2024, under the supervision of Prof. Rob Lanfear, in the Division of Ecology and Evolution at the Australian National University. It counts as one of the [Advanced Studies Course](https://programsandcourses.anu.edu.au/course/scnc2101) required for my [degree](https://programsandcourses.anu.edu.au/2023/program/aphsc).

In the project, I investigated the effectiveness of using nonreversible amino acid substitution models to determine whether Porifera, Ctenophora, or some other group is the true basal lineage of Metazoa. For a better understanding of the project, and the methods used, I highly recommend referring to my [final report](./final_report.docx). Descriptions of the project written before ([project_outline.md](./project_outline.md)) and after ([project_update_29-Aug-24.md](./project_update_29-Aug-24.md)) may also give useful context.  The aim of this README is just to act as a guide to all the analyses and data used for the report. 

The slides for the [accompanying presentation](https://www.canva.com/design/DAGUoxdjKBo/Q1LmcSBIyKlEGXpz_okdkg/edit?utm_content=DAGUoxdjKBo&utm_campaign=designshare&utm_medium=link2&utm_source=sharebutton) I gave are in Canva.

# File Structure Overview

For reference, the structure of all folders in this repository is:
```
.
├── IQ-TREE_analyses
│   ├── nonreversible_analyses
│   │   ├── laumer
│   │   │   ├── NONREV
│   │   │   ├── REV
│   │   │   ├── TOP
│   │   │   └── TOP_100k
│   │   ├── nonrib
│   │   │   ├── NONREV
│   │   │   ├── REV
│   │   │   ├── TOP
│   │   │   └── TOP_100k
│   │   ├── rib
│   │   │   ├── NONREV
│   │   │   ├── REV
│   │   │   ├── TOP
│   │   │   └── TOP_100k
│   │   └── simion
│   │       ├── DELTA
│   │       ├── NONREV
│   │       ├── REV
│   │       ├── TOP
│   │       ├── TOP_100k
│   │       └── TOP_10k
│   └── site_removal
│       ├── 1e-02
│       ├── 1e-03
│       ├── 1e-04
│       └── 1e-05
├── R_scripts
├── data
│   ├── outgroup_removed_data
│   ├── preprocessed_data
│   └── site_removed_data
│       └── simion
├── figures
│   └── unused_figures
├── published_trees
└── tables
```
# Data

## Dataset codes 

Each of the four datasets was given a code, to be used for file/folder naming.

| dataset               | datacode  |
|------------------------|-----------|
| Nosenko2013 nonribosomal | nonrib    |
| Nosenko2013 ribosomal    | rib       |
| Laumer2018              | laumer    |
| Simion2017              | simion    |


## Data Processing

[Raw data](./data/preprocessed_data) - i.e. multiple sequence alignments (MSAs) and corresponding partition files for each dataset - were given to me by Caitlin Cherryh (a PhD candidate in the group). I converted the MSA files to .fasta format (using Geneious and sequenceconversion.bugaco.com), and renamed the taxa in the files to the format "<Group>_Scientific_name", where 'Group' is one of Ctenophora, Porifera, Bilateria, Placozoa, or Cnidaria. This was done using [this script](/R_scripts/laumer_fasta_processing.R) for the Laumer2018 dataset and [this script](./R_scripts/nick_util_fasta_processing.R) for the others.

Finally, I manually deleted outgroup taxa in a text editor, with the help of a regex. The results of this process are [here](./data/outgroup_removed_data).

When investigating how the removal of important sites affects inferred tree topology, I used [this script](/R_scripts/site_remover.R) to remove varying fractions of the data, and saved the new alignments and partitions [here](/data/site_removed_data). The fraction of data removed is indicated in the filename in scientific notation - for example, the Simion2017 data, but with 1% of the data removed, is called `simion1e-02', as 1e-02=0.01=1%.

# Analyses

All analyses were run with IQ-TREE2, and as such are contained in [./IQ-TREE_analyses](./IQ-TREE_analyses). Even if not written, al analyses were run with `--seed 2222`, as well as the `--prefix`, and `-T` arguments. Every analysis is contained in its own folder - that is, all of the automatically generated files created by IQ-TREE in response to a given command-line prompt. The exact command-line used for every analysis can be found in its folder, at the top of the `.log` file.

## Main Analyses

The 5 types of analysis run on each dataset are described below (the DELTA analysis was only run for the Simion2017 dataset). The files for each analysis are housed in `./IQ-TREE_analyses/nonreversible_analyses/<datacode>/<Analysis Code>`. The 'Analysis Codes' correspond to a specific type of analysis, as described below:

Analysis Code | Description | Command-line 
--- | --- | ---
REV | Determining best RHAS and guide topology with ModelFinder-determined reversible models | `iqtree2 -s ALIGNMENT.fasta -p PARTITION.nex --prefix REV`
NONREV | Finding ML rooted tree, together with bootstrap and rootstrap supports | `iqtree2 -s ALIGNMENT.fasta -p REV.best_scheme.nex -t REV.treefile --model-joint NONREV -B 1000 --prefix NONREV` 
TOP | Topology tests (inc. AU test) on ML tree | `iqtree2 -s ALIGNMENT.fasta -p REV.best_scheme.nex -mdef NQ.<datacode>.nex --model-joint NQ.<datacode> --root-test -zb 1000 -au -te NONREV.treefile --prefix TOP`
TOP_100k | TOP but with 100k replicates | `iqtree2 -s ALIGNMENT.fasta -p REV.best_scheme.nex -mdef NQ.<datacode>.nex --model-joint NQ.<datacode> --root-test -zb 100000 -au -te NONREV.treefile --prefix TOP_100k`
DELTA | Computing ΔGLS and ΔSLS values per partition | `iqtree2 -s ALIGNMENT.fasta -p <datacode>_full_model.nex -mdef <datacode>_full_model.nex -m NQ.<datacode> -z <datacode>.trees -n 0 -wpl -wsl --prefix DELTA`

### Self-made files

NQ.<datacode>, NQ.<datacode>.nex, <datacode>_full_model.nex, and simion.trees were all created manually, as described in the [final report](./final_report.docx).

## Site removal analysis

For each of the (alignment + partition) files in [./data/site_removed_data](./data/site_removed_data) (corresponding to a specific number of sites removed from the Simion2017 dataset), the following analysis was run:

`iqtree2 --seed 2222 -s ALIGNMENT.fasta -p PARTITION.nex -t NONREV.treefile -mdef NQ.simion.nex -m NQ.simion -B 1000`

The results of these analyses are in [./IQ-TREE_analyses/site_removal](./IQ-TREE_analyses/site_removal), labelled to correspond to the datasets used.

# Figures and Tables

The two tables in the final report are in the same [Excel file](./tables/tables.xlsx). Figures 1, 2, 3, and 4 were created using [./R_scripts/tree_figure_creater.R](./R_scripts/tree_figure_creater.R), Figure 5 using [./R_scripts/gls_sls_graphing.R](./R_scripts/gls_sls_graphing.R), and Figure 6 using site_removed_tree_figure_creater.R.

## Published Trees

Though not included in the final report, for reference screenshots of the published trees associated with each dataset are contained in [./published_trees](./published_trees). These screenshots were given to me by Caitlin Cherryh.
