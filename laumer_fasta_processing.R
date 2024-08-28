library(seqinr)  # For reading and writing fasta files

# Define the Laumer name converter function
laumer.name.converter <- function(s){
  # Small function to manually convert Laumer et. al. 2018 and Laumer et. al. 2019 names
  
  laumer_names <- list("ACOE_Isop" = "Isodiametra_pulchra", "ANNE_Ctel" = "Capitella_teleta", "ARTH_Dmel" = "Drosophila_melanogaster",
                       "BRAC_Lana" = "Lingula_anatina", "BRAC_Ttvs" = "Terebratalia_transversa", "CEPH_Bflo" = "Branchiostoma_floridae",
                       "CNID_Aala" = "Alatina_alata", "CNID_Adig" = "Acropora_digitifera", "CNID_Aplm" = "Alcyonium_palmatum", 
                       "CNID_Atet" = "Abylopsis_tetragona", "CNID_Csow" = "Craspedacusta_sowerbyi", "CNID_Epal" = "Exaiptasia_pallida",
                       "CNID_Gven" = "Gorgonia_ventalina", "CNID_Hvul" = "Hydra_vulgaris", "CNID_Lcmp" = "Lucernariopsis_campanulata",
                       "CNID_Ltet" = "Liriope_tetraphylla", "CNID_Nvec" = "Nematostella_vectensis", "CNID_Phyd" = "Polypodium_hydriforme",
                       "CNID_Pnct" = "Pelagia_noctiluca", "CNID_Smel" = "Stomolophus_meleagris", "CRAN_Mmus" = "Mus_musculus",
                       "CTEN_Baby" = "Beroe_abyssicola", "CTEN_Cmet" = "Coeloplana_cf_meteoris", "CTEN_Edun" = "Euplokamis_dunlapae",
                       "CTEN_Mlei" = "Mnemiopsis_leidyi", "CTEN_Pbac" = "Pleurobrachia_bachei", "CTEN_Vmul" = "Vallicula_multiformis",
                       "ECHI_Spur" = "Strongylocentrotus_purpuratus", "MICR_Limn" = "Limnognathia_maerski", "MOLL_Cgig" = "Crassostrea_gigas",
                       "MOLL_Lott" = "Lottia_gigantea", "NEMA_Ppac" = "Pristionchus_pacificus", "NEMO_Nemw" = "Nemertoderma_westbladi",
                       "ONYC_Peri" = "Peripatoides_sp", "OUTC_Aspc" = "Acanthoeca_spectabilis", "OUTC_Chol" = "Codosiga_hollandica",
                       "OUTC_Dcos" = "Didymoeca_costata", "OUTC_Mbre" = "Monosiga_brevicolis", "OUTC_Sdol" = "Salpingoeca_dolichothecata",
                       "OUTC_Smac" = "Salpingoeca_macrocollata", "OUTC_Sros" = "Salpingoeca_rosetta", "OUTF_Amac" = "Allomyces_macrogynus",
                       "OUTF_Foxy" = "Fusarium_oxysporum", "OUTF_Mver" = "Mortierella_verticillata", "OUTF_Rall" = "Rozella_allomycis",
                       "OUTF_Rsol" = "Rhizophagus_irregularis", "OUTF_Spun" = "Spizellomyces_punctatus", "OUTI_Apar" = "Amoebidium_parasiticum",
                       "OUTI_Cowc" = "Capsaspora_owczarzaki", "OUTI_Falb" = "Fonticula_alba", "OUTI_Mvar" = "Ministeria_vibrans",
                       "OUTI_Sart" = "Sphaeroforma_artica", "OUTI_Ttra" = "Thecamonas_trahens", "PLAC_Tadh" = "Trichoplax_adhaerens",
                       "PLAC_TH11" = "Trichoplax_sp_11", "PLAC_TpH4" = "Trichoplax_sp_H4", "PLAC_TpH6" = "Trichoplax_sp_H6", 
                       "PLAT_Sman" = "Schistosoma_mansoni", "PORI_Aque" = "Amphimedon_queenslandica", "PORI_Avas" = "Aphrocallistes_vastus",
                       "PORI_Ccan" = "Corticium_candelabrum", "PORI_Ccla" = "Clathrina_coriacea", "PORI_Ccor" = "Clathrina_coriacea",
                       "PORI_Cele" = "Crella_elegans", "PORI_Cnuc" = "Chondrilla_caribensis", "PORI_Cvar" = "Cliona_varians",
                       "PORI_Easp" = "Euplectella_aspergillum", "PORI_Ifas" = "Ircinia_fasciculata", "PORI_Lcom" = "Leucosolenia_complicata",
                       "PORI_Ocar" = "Oscarella_carmela", "PORI_Pfic" = "Petrosia_ficiformis", "PORI_Psub" = "Pseudospongosorites_suberitoides",
                       "PORI_Scil" = "Sycon_ciliatum", "PORI_Scoa" = "Sycon_coactum", "PORI_Slac" = "Spongilla_lacustris",
                       "PORI_Snux" = "Sympagella_nux", "PRIA_Pcau" = "Priapulus_caudatus", "TARD_Rvar" = "Ramazzottius_varieornatus",
                       "XENO_XbJC" = "Xenoturbella_bocki")
  
  # Select the species name for the given code
  reconciled_s <- laumer_names[[s]]
  # Return the reconciled name or NA if not found
  if (!is.null(reconciled_s)) {
    return(reconciled_s)
  } else {
    return(s)
  }
}

# Function to prepend clade names to taxa
prepend_clade_to_taxa <- function(taxa_name, taxa_clade_df) {
  # Search for the corresponding clade for the taxa
  clade <- taxa_clade_df$clade[taxa_clade_df$relabelled_names == taxa_name][1]
  
  # If clade exists, return the name with clade prepended
  if (length(clade) > 0) {
    return(paste0(toupper(clade), "_", taxa_name))
  } else {
    return(taxa_name)  # Return original name if no clade found
  }
}

# Function to rename fasta taxa with clade names using Laumer and func_naming
rename_fasta_with_clades <- function(fasta_file, naming_reconciliation_df, output_file) {
  # Read the fasta file
  fasta_sequences <- read.fasta(fasta_file, as.string = TRUE)
  
  # Get the original names of the sequences
  original_names <- names(fasta_sequences)
  
  # Apply the Laumer name converter to all sequence names
  updated_names <- sapply(original_names, laumer.name.converter)
  
  # Apply clade names (phylum names) using the reconciliation data frame
  updated_names_with_clades <- sapply(updated_names, prepend_clade_to_taxa, taxa_clade_df = naming_reconciliation_df)
  
  # Update the names in the fasta sequences
  names(fasta_sequences) <- updated_names_with_clades
  
  # Write the updated fasta to the output file
  write.fasta(sequences = fasta_sequences, names = updated_names_with_clades, file.out = output_file)
  
  # Return success message
  return(paste("Fasta file processed and saved to", output_file))
}

# Example usage:
# rename_fasta_with_clades("input_file.fasta", naming_reconciliation_df = taxa_df, "output_file_relabelled_with_clades.fasta")


# Example usage:
rename_fasta_with_clades("/Users/nicholasboffa/Library/CloudStorage/OneDrive-AustralianNationalUniversity/Uni/2024/Semester_2/SCNC2101/metazoan-root/outgroup_removed_data/abc/Laumer2018.Tplx_BUSCOeuk.aa.alignment.fasta", 
                  "/Users/nicholasboffa/Library/CloudStorage/OneDrive-AustralianNationalUniversity/Uni/2024/Semester_2/SCNC2101/metazoan-root/outgroup_removed_data/abc/Laumer2018.Tplx_BUSCOeuk.aa.alignment.relabelled.fasta",
                  naming_reconciliation_df = taxa_df)
