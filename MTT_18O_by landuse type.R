#--------------MTT vs land use type----------------------

# Load libraries
library(readxl)
library(ggplot2)

#directory
#set working directory
setwd("C:/Users/Ruli's computer/OneDrive/Documents/Soil&Water lab/R-scripts")

#create pdf for plots to go to !
pdf_dir <- "C:/Users/Ruli's computer/OneDrive/Documents/Soil&Water lab/R-scripts"

# Load the data from the Excel file
landuse <- read_excel("LWMR_SiteStats.xlsx")

# Create the plot
plot_MTTlanduse <- ggplot(data = landuse, aes(x = Mean18O, y = MTT, shape = LandUse, fill = LandUse, color = LandUse)) +
  geom_point(alpha = 0.8, size = 3) +  # Grey points can be added here if needed
  geom_smooth(method = "lm", se = FALSE, aes(group = LandUse), color = "black") + 
  scale_shape_manual(values = c(
    "Precipitation" = 21,  # Circle with fill
    "Urban" = 22,          # Square with fill
    "Forested" = 24,          # Triangle up with fill
    "Agriculture" = 23,     # Diamond with fill
    "Urban/Agriculture" = 19     # Diamond with fill
  )) +
  labs(
    x = expression(paste(delta^{18}, "O (‰)")),  # Proper isotope notation
    y = "Mean Transit Time (days)",
    title = expression(paste("Mean Transit Time vs ", delta^{18}, "O by Land Use")),
    shape = "Land Use",
    color = "Land Use",
    fill = "Land Use"
  ) +
  theme_classic() +
  theme(
    plot.title = element_text(hjust = 0.5, size = 16),
    axis.text = element_text(size = 12),
    axis.title = element_text(size = 14),
    legend.title = element_text(size = 12),
    legend.text = element_text(size = 10)
  )

# Print the plot
print(plot_MTTlanduse)

# Remove the Precipitation group from the data
landuse_no_precip <- landuse[landuse$LandUse != "Precipitation", ]

library(ggpubr)

# Visualize distribution with boxplot
ggboxplot(landuse_no_precip, x = "LandUse", y = "MTT", color = "LandUse", palette = "jco") +
  labs(title = "Distribution of MTT by Land Use", x = "Land Use Type", y = "Mean Transit Time (days)")

library(FSA)





# Run the Kruskal-Wallis test again with the reduced dataset
kruskal_test_result_no_precip <- kruskal.test(MTT ~ LandUse, data = landuse_no_precip)

# Print the result
print(kruskal_test_result_no_precip)
dunn_result <- dunnTest(MTT ~ LandUse, data = landuse_no_precip, method = "bonferroni")

# Print the results of the Dunn's test
print(dunn_result)

