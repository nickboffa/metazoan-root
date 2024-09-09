library(ggtree)
library(ape)
library(dplyr)
library(stringr)
library(treeio)

# Load the tree from the tree file
tree_file <- "/Users/nicholasboffa/Library/CloudStorage/OneDrive-AustralianNationalUniversity/Uni/2024/Semester_2/SCNC2101/metazoan-root/results/simion/NONREV_simion.treefile"
rootstrap_file <- "/Users/nicholasboffa/Library/CloudStorage/OneDrive-AustralianNationalUniversity/Uni/2024/Semester_2/SCNC2101/metazoan-root/results/simion/NONREV_simion.rootstrap.nex"
csv_file <- "/Users/nicholasboffa/Library/CloudStorage/OneDrive-AustralianNationalUniversity/Uni/2024/Semester_2/SCNC2101/metazoan-root/results/simion/TOP_simion.roottest.csv"

tree <- read.tree(tree_file)
label_tree <- read.beast(rootstrap_file)

root_adjacent_ids <- c(1, 114)
root_length <- 0.1

# Extract leaf labels
leaf_labels <- tree$tip.label

# Function to extract the first word (Phylum) and format it, remove it for plotting, and replace remaining underscores with spaces
get_phylum <- function(label) {
  group <- str_split(label, "_")[[1]][1]  # Extract the first part as 'group' before title-casing
  phylum <- str_to_title(group)  # Title case for the Phylum name
  shortened_label <- str_replace(label, paste0(group, "_"), "")
  shortened_label <- str_replace_all(shortened_label, "_", " ")  # Replace underscores in the remaining label with spaces
  return(list(phylum = phylum, shortened_label = shortened_label))
}

# Apply the function to all leaf labels
label_data <- sapply(leaf_labels, get_phylum, simplify = FALSE)
phyla <- sapply(label_data, function(x) x$phylum)
shortened_labels <- sapply(label_data, function(x) x$shortened_label)

# Assign colours based on Phylum
colour_palette <- scales::hue_pal()(length(unique(phyla)))
names(colour_palette) <- unique(phyla)

# Create a data frame for the tip labels with their corresponding colours and shortened labels
tip_data <- data.frame(label = leaf_labels, Phylum = phyla, shortened_label = shortened_labels) %>%
  mutate(colour = colour_palette[Phylum])

# Set root
tree$root.edge <- 1L  # Add root branch

# Extract rootstrap value for the root node (where id == 1)
rootstrap_value <- label_tree@data$rootstrap[which(label_tree@data$id == 0)]

# Load the CSV file
roottest_data <- read.csv(csv_file, comment.char='#')

# Filter rows where p-AU >= 0.05 and extract the corresponding 'id' values
bold_branch_ids <- roottest_data %>%
  filter(p.AU >= 0.05) %>%
  pull(ID)

# Add a binary 'branch_bold' column to label_tree@data based on whether 'id' is in bold_branch_ids
label_tree@data$branch_bold <- ifelse(label_tree@data$id %in% bold_branch_ids, 1, 0)

# Create the tree plot
p <- ggtree(tree) %<+% tip_data +
  geom_tiplab(aes(label = shortened_label, color = Phylum)) +  # Use shortened labels (with spaces) and colour by Phylum
  geom_rootedge(rootedge = root_length) +  # Add root branch
  geom_text2(aes(label = ifelse(as.numeric(label) < 100 & !is.na(as.numeric(label)), label, "")), 
             hjust = -0.2, color = 'red') +  # Plot node labels only if < 100
  geom_text2(data = label_tree, aes(x = branch, 
                                    label = ifelse(as.numeric(rootstrap) > 0 & id != root_adjacent_ids[1] & id != root_adjacent_ids[2] & id != 0, rootstrap, "")),
             vjust = -1,
             angle = 0, 
             branch = TRUE,
             color = 'blue') +
  geom_text2(data = label_tree, aes(x = branch - root_length / 2, label = ifelse(id == 0, rootstrap, "")),
             vjust = -1,
             angle = 0,
             branch = TRUE,
             color = 'blue') +  # Make the branches bold for ids with p-AU >= 0.05
  geom_tree(data=label_tree, aes(linewidth = branch_bold), show.legend = FALSE) +
  scale_linewidth_continuous(range = c(0.5, 1.5)) +  # Set the range for line thickness
  scale_color_manual(values = colour_palette) +  # Apply the colour palette
  theme_tree2() +
  coord_cartesian(xlim = c(-0.1, 1.1)) +
  theme(legend.position='bottom',
        text = element_text(size=10))


ggsave("/Users/nicholasboffa/Library/CloudStorage/OneDrive-AustralianNationalUniversity/Uni/2024/Semester_2/SCNC2101/metazoan-root/results/tree_images/R_simion.png", p, 
       width=1500, height=1000, limitsize=F)
