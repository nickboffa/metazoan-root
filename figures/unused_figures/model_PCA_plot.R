library(tidyverse)
library(ggrepel)

read_matrices <- function(filepath) {
  # Read the file content
  lines <- readLines(filepath)
  
  # Initialize variables
  matrices <- list()
  current_matrix <- NULL
  current_name <- NULL
  
  for (line in lines) {
    # Check if the line contains a matrix name
    if (grepl("^model NQ\\.", line)) {
      # Save the current matrix if it exists
      if (!is.null(current_name) && !is.null(current_matrix)) {
        # Remove the last row from the matrix
        matrices[[current_name]] <- as.matrix(current_matrix[-nrow(current_matrix),])
      }
      
      # Extract the matrix name (e.g., "abc" from "model NQ.abc")
      current_name <- gsub("^model |=", "", line)
      current_matrix <- NULL
    } else if (nchar(trimws(line)) > 0) {
      # Convert the line to a numeric vector and append it to the current matrix
      row_data <- as.numeric(strsplit(trimws(line), "\\s+")[[1]])
      if (is.null(current_matrix)) {
        current_matrix <- matrix(row_data, nrow = 1)
      } else {
        current_matrix <- rbind(current_matrix, row_data)
      }
    }
  }
  
  # Add the last matrix (if any)
  if (!is.null(current_name) && !is.null(current_matrix)) {
    matrices[[current_name]] <- as.matrix(current_matrix[-nrow(current_matrix),])
  }
  
  return(matrices)
}

# Example usage
file_path <- "/Users/nicholasboffa/Library/CloudStorage/OneDrive-AustralianNationalUniversity/Uni/2024/Semester_2/SCNC2101/metazoan-root/results/all_nq_models.nex"  # Replace with the actual file path
matrices <- read_matrices(file_path)


#### PCA

flatten_matrix <- function(mat) {
  as.vector(t(mat))  # Flatten the matrix by row-major order
}

# Assume 'matrices' is your list of matrices (from previous steps)
# Flatten all matrices and combine them into a data frame
flattened_data <- do.call(rbind, lapply(matrices, flatten_matrix))

# Perform PCA on the flattened data
pca_result <- prcomp(flattened_data, center = TRUE, scale. = TRUE)

# Extract the first two principal components for plotting
pca_data <- as.data.frame(pca_result$x[, 1:2])  # PC1 and PC2

# Create labels for each matrix (optional, if you have meaningful labels)
pca_data$label <- names(matrices)  # Label each point with matrix name

# Create a mapping of old labels to new labels
label_mapping <- c(
  "NQ.nonrib" = "Nosenko2013 nonribosomal",
  "NQ.rib" = "Nosenko2013 ribosomal",
  "NQ.laumer" = "Laumer2018",
  "NQ.simion" = "Simion2017"
)

# Apply the label mapping to a new column in the pca_data
pca_data$label_mapped <- ifelse(pca_data$label %in% names(label_mapping), 
                                label_mapping[pca_data$label], 
                                pca_data$label)

# Define the colors: One for the selected labels, another for the rest
pca_data$color_group <- ifelse(pca_data$label %in% names(label_mapping), "selected", "other")

pca_summary <- summary(pca_result)

# Extract the percentage of variance explained for PC1 and PC2
pc1_variance <- round(pca_summary$importance[2, 1] * 100, 2)
pc2_variance <- round(pca_summary$importance[2, 2] * 100, 2)


p <- ggplot(pca_data, aes(x = PC1, y = PC2, label = label_mapped, color = color_group)) +
  geom_point(size = 3) +
  geom_text_repel(vjust = 1.5, size = 3) +  # Add labels
  theme_minimal() +
  labs(x = paste0("PC1 (", pc1_variance, "%)"),
       y = paste0("PC2 (", pc2_variance, "%)")) +
  scale_color_manual(values = c("selected" = "red", "other" = "black")) +
  theme(legend.position = 'none')


# Display the plot
print(p)





# Set up the plotting window
par(mfrow = c(2,5))  # Adjust margins if needed

# Plot each matrix
for (i in 1:length(matrices)) {
  # Display matrix with image
  image(1:20, 1:20, matrices[[i]], main = names(matrices)[i], col = colorRampPalette(c("blue", "white", "red"))(256), xlab = "Column", ylab = "Row", axes = FALSE)
  axis(1, at = seq(0, 1, length.out = 5), labels = seq(1, 20, length.out = 5))
  axis(2, at = seq(0, 1, length.out = 5), labels = seq(1, 20, length.out = 5))
}

# Reset plotting layout
par(mfrow = c(1, 1), mar = c(5, 4, 4, 2) + 0.1)
