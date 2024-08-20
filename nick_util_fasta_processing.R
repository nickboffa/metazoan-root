## caitlinch/metazoan-mixtures/code/util_fasta_processing.R
# This script processes and updates the taxa names for estimated maximum likelihood fastas (so all fastas from all datasets are consistent)
# Caitlin Cherryh 2023


#### 1. Input parameters ####
## Specify parameters:
# iqtree_file_dir    <- Directory for IQ-fasta output (.log, .iqtree and .fastafile files from IQ-fasta runs)
# renamed_fasta_dir   <- Directory for results and plots
# repo_dir           <- Location of caitlinch/metazoan-mixtures github repository

iqtree_file_dir      <- "/Users/nicholasboffa/Library/CloudStorage/OneDrive-AustralianNationalUniversity/Uni/2024/Semester_2/SCNC2101/metazoan-root/outgroup_removed_data/" # make end in /
renamed_fasta_dir     <- "/Users/nicholasboffa/Library/CloudStorage/OneDrive-AustralianNationalUniversity/Uni/2024/Semester_2/SCNC2101/metazoan-root/outgroup_removed_data/" # make end in /
repo_dir        <- "/Users/nicholasboffa/Library/CloudStorage/OneDrive-AustralianNationalUniversity/Uni/2024/Semester_2/SCNC2101/caitlyn-metazoan-mixtures/" # DON'T CHANGE



#### 2. Prepare functions, variables and packages ####
# Open packages
library(ape) # for `read.fasta` and `write.fasta`
library(TreeTools) # for `as.multiPhylo`
library(seqinr)

# Source functions and taxa lists
source(paste0(repo_dir, "code/func_naming.R"))

update.fasta.taxa <- function(fasta_file, naming_reconciliation_df, output.clade.names = FALSE, save.updated.fasta = FALSE, output.directory = NA) {
  # Function to update taxa names in fasta files
  
  # Identify which dataset and alignment this fasta matches
  fasta_dataset <- strsplit(basename(fasta_file), "\\.")[[1]][1]
  fasta_matrix <- strsplit(basename(fasta_file), "\\.")[[1]][2]
  
  # Filter the reconciliation data frame for relevant taxa
  fasta_taxa_df <- naming_reconciliation_df[naming_reconciliation_df$dataset == fasta_dataset & naming_reconciliation_df$alignment == fasta_matrix,]
  
  # Read the fasta file
  fasta_sequences <- read.fasta(fasta_file)
  
  # Get sequence names
  fasta_names <- names(fasta_sequences)
  
  # Find matching rows in the reconciliation data frame
  keep_rows <- which((fasta_taxa_df$original_name %in% fasta_names) == TRUE)
  fasta_taxa_df <- fasta_taxa_df[keep_rows,]
  
  # Reorder the data frame to match the order of sequence names
  fasta_taxa_df <- fasta_taxa_df[match(fasta_names, fasta_taxa_df$original_name),]
  
  # Update sequence names
  if (output.clade.names == FALSE) {
    # Replace with full species names
    names(fasta_sequences) <- fasta_taxa_df$relabelled_names
  } else if (output.clade.names == TRUE) {
    # Replace with clade and species name
    names(fasta_sequences) <- paste0(toupper(fasta_taxa_df$clade), "_", fasta_taxa_df$relabelled_names)
  }
  
  # Save the updated fasta file if required
  if ((save.updated.fasta == TRUE) & (!is.na(output.directory))) {
    # Create the new file name
    split_fasta_file <- strsplit(basename(fasta_file), "\\.")[[1]]
    new_fasta_file <- paste0(output.directory, paste(head(split_fasta_file, -1), collapse = "."), ".relabelled.", tail(split_fasta_file, 1))
    
    # Write the updated fasta
    write.fasta(sequences = fasta_sequences, names = names(fasta_sequences), file.out = new_fasta_file)
  }
  
  # Return the updated fasta sequences
  return(fasta_sequences)
}


# Open the renaming csv
taxa_df <- read.csv(paste0(repo_dir, "Cherryh_MAST_metazoa_taxa_reconciliation.csv"), stringsAsFactors = FALSE)

#### 3. Update the taxa labels in each fasta ####
# Extract the full list of fastas
all_files <- paste0(iqtree_file_dir, list.files(iqtree_file_dir))
all_fasta_files <- grep("\\.fasta", all_files, value = T)
# Rename all fastas
all_fastas_list <- lapply(all_fasta_files, update.fasta.taxa, naming_reconciliation_df = taxa_df, 
                    output.clade.names = TRUE, save.updated.fasta = TRUE, output.directory = renamed_fasta_dir)
all_fastas <- as.multiPhylo(all_fastas_list)


