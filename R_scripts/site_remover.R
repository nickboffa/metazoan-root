#### This script allows the removal of specific sites from both a .fasta multiple sequence alignment and .nex partition file

library(seqinr)
library(tidyverse)
library(ape)

#### Edit MSA
## Takes in a FASTA file, removes specified sites (columns) by index, and writes output file

remove_site <- function(msa, site) {
  for (species in names(msa)) {
    msa[[species]] <- msa[[species]][-site]
  }
  return(msa)
}

remove_sites <- function(msa, sites) {
  for (site in sites) {
    msa <- remove_site(msa, site)
  }
  return(msa)
}


edit_fasta <- function(sites, filepath) { # filepath of msa
  msa <- seqinr::read.fasta(filepath, seqtype="AA")
  msa <- remove_sites(msa, sites)
  
  # Write the new FASTA file
  output_filepath <- sub(".fasta$", "_edited.fasta", filepath)
  seqinr::write.fasta(raw_msa, names=names(raw_msa), nbchar=10^10,
                      file.out = output_filepath)
}

msa_path <- "/Users/nicholasboffa/Library/CloudStorage/OneDrive-AustralianNationalUniversity/Uni/2024/Semester_2/SCNC2101/metazoan-root/outgroup_removed_data/Simion2017.relabelled.outgroup_rem.fasta"


#### Edit partition file
## Changes .nex partition file so that charset ranges reflect removed sites

edit_partition <- function(sites, filepath, output_filepath=FALSE) {
  # Read the nexus file as text
  nexus_content <- readLines(filepath)
  
  # Extract the charset lines and parse them
  charset_lines <- nexus_content[grepl("charset", nexus_content)]
  ranges <- do.call(rbind, lapply(charset_lines, function(line) {
    # Extract start and end positions
    matches <- regmatches(line, gregexpr("\\d+", line))
    as.integer(matches[[1]][2:3])
  }))
  
  # Adjust ranges
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
  
  # Get the adjusted ranges
  adjusted_ranges <- adjust_ranges(ranges, sites)
  
  # Construct the new partition file content
  new_partition_lines <- c("#nexus", "begin sets;")
  for (i in 1:nrow(adjusted_ranges)) {
    gene_name <- sprintf("gene_%04d", i)
    start <- adjusted_ranges[i, 1]
    end <- adjusted_ranges[i, 2]
    new_partition_lines <- c(new_partition_lines, sprintf("\tcharset %s = %d - %d;", gene_name, start, end))
  }
  new_partition_lines <- c(new_partition_lines, "end;")
  
  # Write the new partition file
  if (is.character(output_filepath)) {
    output_filepath <- sub(".nex$", "_edited.nex", filepath)  # default output filepath
  }
  writeLines(new_partition_lines, output_filepath)
}

# Example Usage
filepath <- "/Users/nicholasboffa/Library/CloudStorage/OneDrive-AustralianNationalUniversity/Uni/2024/Semester_2/SCNC2101/metazoan-root/outgroup_removed_data/Simion2017_partitions_formatted.nex"
output_filepath <- "/Users/nicholasboffa/Library/CloudStorage/OneDrive-AustralianNationalUniversity/Uni/2024/Semester_2/SCNC2101/metazoan-root/Simion_edited.nex"
edit_partition(c(2, 1200), filepath, output_filepath = output_filepath)
