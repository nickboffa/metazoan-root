library(tidyverse)
library(data.table)
library(cowplot)
library(patchwork)
library(ggtext)

# CLEANING 
partlh_url <- "/Users/nicholasboffa/Library/CloudStorage/OneDrive-AustralianNationalUniversity/Uni/2024/Semester_2/SCNC2101/metazoan-root/results/simion/DELTA_simion.partlh"
sitelh_url <- "/Users/nicholasboffa/Library/CloudStorage/OneDrive-AustralianNationalUniversity/Uni/2024/Semester_2/SCNC2101/metazoan-root/results/simion/DELTA_simion.sitelh"

raw_partlh_data <- read.table(partlh_url, sep = " ", skip=1)
partlh_data <- t(raw_partlh_data)

raw_sitelh_data <- fread(sitelh_url, sep = " ", skip = 1)
sitelh_data <- transpose(raw_sitelh_data)

clean <- function(data) {
  df <- as_tibble(data)
  colnames(df) <- c("T1", "T2", "T3", "T4")
  
  # Remove the first row now that it's used as column names
  df <- df[-1, ]

  df[] <- lapply(df, as.numeric)
  
  df$t1_t2 <- df$T1 - df$T2
  df$t1_t3 <- df$T1 - df$T3
  df$t1_t4 <- df$T1 - df$T4
  df$t2_t3 <- df$T2 - df$T3
  df$t2_t4 <- df$T2 - df$T4
  df$t3_t4 <- df$T3 - df$T4
  return(df)
}


sls_df <- clean(sitelh_data)
gls_df <- clean(partlh_data)
gls_df <- gls_df[-(1:5), ] # remove initial NA columns

#write_csv(sls_df, "/Users/nicholasboffa/Library/CloudStorage/OneDrive-AustralianNationalUniversity/Uni/2024/Semester_2/SCNC2101/metazoan-root/results/gls/cleaned_data/simion_sls.csv")
#write_csv(gls_df, "/Users/nicholasboffa/Library/CloudStorage/OneDrive-AustralianNationalUniversity/Uni/2024/Semester_2/SCNC2101/metazoan-root/results/gls/cleaned_data/simion_gls.csv")

# HISTOGRAMS
create_histogram_plot <- function(col_name, data) {
  delta_l <- data |>
    pull(.data[[col_name]]) |> 
    sum()
  h1 <- str_to_upper(substr(col_name, 1,2))
  h2 <- str_to_upper(substr(col_name, 4,5))
  plot_title <- paste0(h1, " v ", h2, ": \u0394Log-L = ", round(delta_l, 1))
  
  ggplot(data, aes(x = .data[[col_name]])) +
    geom_histogram(fill="grey", binwidth=0.05) +
    
    scale_y_continuous(trans = 'log1p', breaks = c(0, 10^(0:10)), limits=c(0, 1e+03)) +
    theme_minimal_hgrid() +
    
    # Add vertical line for mean
    geom_vline(aes(xintercept = mean(.data[[col_name]])), color = 'black', linetype = 'dashed') +
    
    # Set x-axis breaks and limits
    scale_x_continuous(breaks = seq(-1, 1, 0.2), limits = c(-1.2, 1.2)) +
    
    labs(x = expression(Delta ~ "SLS"), y = "Count", title = plot_title) +
    
    # Adjust axis ticks and text
    theme(
      axis.line.x = element_blank(),
      axis.ticks.x = element_line(color = "black", size = 0.5),  # Show x-axis ticks
      axis.ticks.length = unit(5, "pt"),  # Adjust tick length
      axis.text.x = element_text(vjust = 0),  # Move x-axis text up
      legend.position = "none",  # Remove legend for fill colors
    )
}

create_histogram_plot("t1_t4", data=sls_df)

  
# SEGMENT PLOT

create_segment_plot <- function(col_name, data) {
  df_sorted <- data |> 
    arrange(-.data[[col_name]]) |> 
    mutate(row_index = row_number()) |> 
    mutate(is_positive = .data[[col_name]] >= 0)
  
  # Find the row index where the value is <= 0
  cutoff_index1 <- max(df_sorted$row_index[df_sorted[[col_name]] > 0])
  cutoff_index2 <- min(df_sorted$row_index[df_sorted[[col_name]] < 0])
  delta_l <- df_sorted |>
    pull(.data[[col_name]]) |> 
    sum()
  
  h1 <- str_to_upper(substr(col_name, 1,2))
  h2 <- str_to_upper(substr(col_name, 4,5))
  plot_title <- paste0(
    "<span style='color:green;'>", h1, "</span> v ",
    "<span style='color:red;'>", h2, "</span>",
    ": \u0394Log-L = ", round(delta_l, 1)
  )
  
  ggplot(df_sorted, aes(x = row_index, yend = .data[[col_name]], color = is_positive)) +
    geom_segment(aes(xend = row_index, y = 0)) +  # Vertical lines
    scale_color_manual(values = c("red", "forestgreen")) +
    cowplot::theme_minimal_hgrid() +
    
    # Set y-axis label with Greek Delta
    labs(x="Sites", y = expression(Delta ~ "SLS"), title=plot_title) +
    
    # Remove x-axis and x-axis label
    theme(
      axis.line.x = element_blank(),
      axis.text.x = element_blank(),
      axis.ticks.x = element_blank(),
      plot.title = ggtext::element_markdown()  # Enable HTML-like text rendering in title
    ) +
    guides(color = "none") +
    geom_vline(xintercept = cutoff_index1, linetype = "dashed", color="forestgreen") +
    annotate(
      "text", x = 0, y = 1.1, 
      label = paste0(100*round(cutoff_index1/nrow(df_sorted), 2), "% favour ", h1),
      hjust = -0.1, color='darkgreen'
    ) +
    geom_vline(xintercept = cutoff_index2, linetype = "dashed", color="red") +
    annotate(
      "text", x = 0, y = 0.8, 
      label = paste0(100*round((nrow(df_sorted)-cutoff_index2)/nrow(df_sorted), 2), "% favour ", h2),
      hjust = -0.1, color='red'
    )
}

create_segment_plot("t1_t2", data=gls_df)

create_unordered_segment_plot <- function(col_name, data=df) {
  df_idx <- data |>
    mutate(row_index = row_number()) |>
    mutate(is_positive = .data[[col_name]] >= 0)
    
  ggplot(df_idx, aes(x = row_index, yend = .data[[col_name]], color=is_positive)) +
    geom_segment(aes(x = row_index, xend = row_index, y = 0)) +  # Vertical lines
    scale_color_manual(values = c("red", "forestgreen")) +
    cowplot::theme_minimal_hgrid() +
    
    # Set y-axis label with Greek Delta
    labs(x="Sites", y = expression(Delta ~ "SLS")) +
    
    # Remove x-axis and x-axis label
    theme(
      axis.line.x = element_blank(),
      axis.text.x = element_blank(),
      axis.ticks.x = element_blank()
    ) +
    ylim(-1.1, 1.1) +
    guides(color = "none")
}

create_grid <- function(graph_plotter, data) {
  pairwise_comparisons <- c("t1_t2", "t1_t3", "t1_t4", "t2_t3", "t2_t4", "t3_t4")
  
  plots <- lapply(pairwise_comparisons, graph_plotter, data = data)
  
  empty_plot <- ggplot() + theme_void()
  
  plot_grid_upper <- (
    plots[[1]] + plots[[2]] + plots[[3]] +
      empty_plot + plots[[4]] + plots[[5]] +
      empty_plot + empty_plot + plots[[6]]
  ) + plot_layout(ncol = 3)
  
  print(plot_grid_upper)
}

create_grid(create_segment_plot, data=gls_df)

create_grid(create_histogram_plot, data=gls_df)

