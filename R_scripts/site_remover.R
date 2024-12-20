#### This script allows the removal of specific sites from both a .fasta multiple sequence alignment and .nex partition file

library(tidyverse)
library(seqinr)
library(ape)

#### Determine sites for removal 

dataset <- "simion"
sls_df <- read_csv("~/Library/CloudStorage/OneDrive-AustralianNationalUniversity/Uni/2024/Semester_2/SCNC2101/metazoan-root/results/gls_sls/cleaned_data/simion_sls.csv")
sls_df$site <- as.integer(rownames(sls_df))

# Removes the sites in top and bottom p/2% of Delta_SLS values
get_sites <- function(p, col_name = "t1_t3") {
  # Determine the number of sites to select for the bottom and top p/2%
  num_sites <- round(nrow(sls_df) * (p / 2))
  
  # Arrange the DataFrame by the specified column
  sorted_df <- sls_df[order(sls_df[[col_name]]), ]
  
  # Get the first and last `num_sites` rows from the 'site' column
  bottom_sites <- sorted_df$site[seq_len(num_sites)]
  top_sites <- sorted_df$site[seq(nrow(sorted_df) - num_sites + 1, nrow(sorted_df))]
  
  # Combine the selected sites
  sites <- sort(union(bottom_sites, top_sites))
  
  return(sites)
}

#### Edit MSA
### edit_fasta() takes in a FASTA file, removes specified sites (columns) by their index using remove_sites(), and writes output file

remove_sites <- function(msa, sites) {
  # Remove all specified sites at once for each species
  for (species in names(msa)) {
    msa[[species]] <- msa[[species]][-sites]
  }
  return(msa)
}

edit_fasta <- function(sites, filepath, output_filepath = FALSE) { # filepath of msa
  msa <- seqinr::read.fasta(filepath, seqtype = "AA")
  msa <- remove_sites(msa, sites)

  # Write the new FASTA file
  if (!is.character(output_filepath)) {
    output_filepath <- sub(".fasta$", "_edited.fasta", filepath) # default output filepath
  }
  
  seqinr::write.fasta(msa,
    names = names(msa), nbchar = 10^10,
    file.out = output_filepath
  )
}

#### Edit partition file
## Changes .nex partition file so that charset ranges reflect removed sites

edit_partition <- function(sites, filepath, output_filepath = FALSE) {
  # Read the nexus file as text
  nexus_content <- readLines(filepath)

  # Get the range of each gene (e.g. 120-150 indicates the sites in that gene)
  charset_lines <- nexus_content[grepl("charset", nexus_content)]
  ranges <- do.call(rbind, lapply(charset_lines, function(line) {
    matches <- regmatches(line, gregexpr("\\d+", line))
    as.integer(matches[[1]][2:3])
  }))

  # Adjust ranges based on removed sites
  removed_sites <- sites
  adjust_ranges <- function(ranges, removed_sites) {
    removed_sites <- sort(unique(removed_sites))
    current_site_index <- 1
    shift <- 0
    adjusted_ranges <- matrix(NA, nrow = nrow(ranges), ncol = 2)

    for (i in 1:nrow(ranges)) {
      start <- ranges[i, 1]
      end <- ranges[i, 2]
      old_shift <- shift

      any_site_in_range <- FALSE
      
      # Update the shift if removed sites fall within this range
      for (n_site in seq_along(sites)) {
        current_site_in_range <- (start <= sites[n_site]) && (sites[n_site] <= end)
        shift <- shift + current_site_in_range

        if (current_site_in_range == 1) {
          any_site_in_range <- TRUE
        }
      }

      if (any_site_in_range) {
        new_start <- start - old_shift
      } else {
        new_start <- start - shift
      }
      new_end <- end - shift


      # Store the adjusted range
      adjusted_ranges[i, ] <- c(new_start, new_end)
    }

    return(adjusted_ranges)
  }
  adjusted_ranges <- adjust_ranges(ranges, sites)

  # Construct the new partition file
  new_partition_lines <- c("#nexus", "begin sets;")
  for (i in 1:nrow(adjusted_ranges)) {
    gene_name <- sprintf("gene_%04d", i)
    start <- adjusted_ranges[i, 1]
    end <- adjusted_ranges[i, 2]
    new_partition_lines <- c(new_partition_lines, sprintf("\tcharset %s = %d - %d;", gene_name, start, end))
  }
  new_partition_lines <- c(new_partition_lines, "end;")

  # Write the new partition file to path
  if (!is.character(output_filepath)) {
    output_filepath <- sub(".nex$", "_edited.nex", filepath) # default output filepath
  }
  writeLines(new_partition_lines, output_filepath)
}

#### Write files
## Saves .nex and .fasta files for varying amounts of removed data to specified locations

original_msa <- "~/Library/CloudStorage/OneDrive-AustralianNationalUniversity/Uni/2024/Semester_2/SCNC2101/metazoan-root/data/outgroup_removed_data/Simion2017.relabelled.outgroup_rem.fasta"
original_nex <- "~/Library/CloudStorage/OneDrive-AustralianNationalUniversity/Uni/2024/Semester_2/SCNC2101/metazoan-root/data/outgroup_removed_data/Simion2017_partitions_formatted.nex"

output_base <- "~/Library/CloudStorage/OneDrive-AustralianNationalUniversity/Uni/2024/Semester_2/SCNC2101/metazoan-root/data/site_removed_data/simion/simion_"

for (p in 10^(-5:-2)) {
  print(paste("Running", p))
  
  p_sci <- format(p, scientific = TRUE)
  p_formatted <- gsub("\\.", "-", p_sci)
  
  output_msa <- paste0(output_base, p_formatted, ".fasta")
  output_nex <- paste0(output_base, p_formatted, ".nex") 
  
  sites <- get_sites(p, col_name="t1_t3")
  
  edit_fasta(sites, filepath=original_msa, output_filepath=output_msa)
  edit_partition(sites, filepath=original_nex, output_filepath=output_nex)
}