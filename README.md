# Rooting the Metazoan Tree with Nonreversible Models

Investigating the effectiveness of nonreversible amino acid substitution models in determine whether Porifera-sister, Ctenophora-sister, or something else is the true rooted topology of the Metazoan tree.

# File Structure

## Data

"Raw" data, as given to me by Caitlin Cherryh, is in `/data/preprocessed_data`. I then converted these files to .fasta format (Geneious and online website), used `/R_scripts/nick_util_fasta_processing.R` to rename the taxa in the files to the format "<Phylum>_Scientific_name". Finally, I manually deleted outgroup taxa in a text editor, with the help of a regex. The results of this process are in `/data/outgroup_removed_data`. There is also a test dataset there, which contains 16 species from the nonribosomal Nosenko2013 dataset, for testing the workflow on my computer.

When investigating how the removal of important sites affects inferred tree topology, I used `/R_scripts/site_remover.R` to remove varying fractions of the data, and save the new alignments and partitions to `/data/site_removed_data`. The fraction of data removed is indicated in the filename in scientific notation - for example, the Simion2017 data, but with 1% of the data removed, is called `simion1e-02', as 1e-02=0.01=1%.

### Dataset codes 

Each dataset was given a code, to be used in naming files and folders

datacode | dataset | source 
--- | --- | --- 
nonrib | Nosenko2013 nonribosomal | x 
rib | Nosenko2013 ribosomal | x
laumer | Laumer2018 | x
simion | Simion2017 | x 

## Results

Even if not written, al anallyses were run with `--seed 2222`, `--prefix`, `-T`. Prefixes follow those in the supplementary info of Suha's paper.

File Prefix | Description | Command-line 
--- | --- | ---
REV | Determining best RHAS and guide topology with ModelFinder-determined reversible models | `iqtree2 -s ALIGNMENT.fasta -p PARTITION.nex --prefix REV`
NONREV | Finding ML rooted tree, together with bootstrap and rootstrap supports | `iqtree2 -s ALIGNMENT.fasta -p REV.best_scheme.nex -t REV.treefile --model-joint NONREV -B 1000 --prefix NONREV` 
TOP | Topology tests (inc. AU test) on ML tree | `iqtree2 -s ALIGNMENT.fasta -p REV.best_scheme.nex -mdef NQ.<datacode>.nex --model-joint NQ.<datacode> --root-test -zb 1000 -au -te NONREV.treefile --prefix TOP`
DELTA | Computing ΔGLS and ΔSLS values per partition | `iqtree2 -s ALIGNMENT.fasta -p <datacode>_full_model.nex -mdef <datacode>_full_model.nex -m NQ.<datacode> -z <datacode>.trees -n 0 -wpl -wsl --prefix DELTA`

### Self-made files

NQ.simion, simion.trees, simion_full_model.nex
