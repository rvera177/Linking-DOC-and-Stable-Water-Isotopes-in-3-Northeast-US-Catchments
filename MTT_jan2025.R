#Mean Transit Times
# use O18 data
# D = damping ratio of the precipitation isotopic signal
# SDs = standard deviation of stream water isotopic composition
# SDp = standard deviation of precipitation isotopic composition [Woodside]
# T = Mean Transit Time (days)
# c = radial frequency of annual fluctuations


library(tibble)
library(lubridate)
library(pdftools)
library(ggplot2)
library(cowplot)
library(r2symbols)
library(wesanderson)
library(dplyr)

#defining color pallet 
my_greens <- wes_palette(n = 4, name = "Moonrise2")
my_green <- my_greens[1]
my_blues <- wes_palette(n = 4, name = "Moonrise3")
my_blue <- my_blues[3]
my_colors3 <- wes_palette(n = 4, name = "GrandBudapest2")
blue <- my_colors3[4]
my_colors4 <- wes_palette(n = 4, name = "Chevalier1")
lightblue <- my_colors4[3]


#directory
#set working directory
setwd("C:/Users/Ruli's computer/OneDrive/Documents/Soil&Water lab/R-scripts")

#create pdf for plots to go to !
pdf_dir <- "C:/Users/Ruli's computer/OneDrive/Documents/Soil&Water lab/R-scripts"


#loading and storing

#load data & store it in variable
isotope_data <- read.csv("Isotope Inventory_January 2025.csv", header = TRUE, sep = ",")

#remove unnecessary columns 
i_data <- isotope_data[c(2, 3, 12, 14)] #only keeps columns 2,3,12,and 14, removes the rest

#converts to numbers & dates
as.numeric(i_data$ID, i_data$Processed.Delta.2H, i_data$Processed.Delta.18O)
#sorts data
i_data_sort <- i_data[order(i_data$Location, decreasing = TRUE), ]

#removed missing data
i_data_NA <- na.omit(i_data_sort) # nolint

#creates date column
dates <- mdy(i_data_NA$Date, quiet = FALSE, tz= NULL, locale = Sys.getlocale("LC_TIME"), truncated = 0) # nolint

#column of row numbers
rows <- c(1:length(i_data_NA$Location)) # nolint

#adds dates to data set
bind_dates <- cbind(i_data_NA, dates)

#adds new row numbers to data set
id_bind_row <- cbind(bind_dates, rows)
id <- id_bind_row[c(5, 1, 4, 3)]
#removes outlier values
id <- subset(id,  Processed.Delta.18O >= -100)
#sorts data based off location
locations<- c("Woodside", "Tan Brook Up", "Tan Brook Down", "Roaring", "Mill Site", "Lake Warner Out", "Knightly", "Horse Up", "Horse Down", "Eastman Up", "Eastman Down", "Doolittle", "Campus Pond Up", "Campus Pond Down", "WET CENTER") # nolint

#STANDARD DEVIATION FOR LOOP


#creates data frame of Woodside Data

Woodside <- id[id$Location == "Woodside", ] # nolint: object_name_linter.

#defines std of woodside precip data

SDp <- sd(Woodside$Processed.Delta.18O) # nolint: object_name_linter.
as.numeric(SDp)

# defining it works -> how to put into for loop??

TanBrookUp <- id[id$Location == "Tan Brook Up", ] # nolint: object_name_linter.

#creates empty list to store data frames in
location_data_list <- list()
SDs <- list() # nolint
D <- list() # nolint
T <- list() # nolint

#defines constant variable c
c <- 0.017214

for (location in locations) {
  #Subset the data for the current location
  location_data <- id[id$Location == location, ]
  #Order the data by dates
  location_data <- location_data[order(location_data$dates), ]
  
  SDs[location] <- sd(location_data$Processed.Delta.18O) # nolint
  
  as.numeric(SDs)
}

#converts list to data frame
SDs <- unlist(SDs) # nolint
SDs <- data.frame(SDs) # nolint

#repeats SDp value to be length of SDs
SDp <- rep(SDp, 15) # nolint
print(SDp)

#Damping Ratio Calc & Storage
D <- SDs / SDp# nolint
Data <- data.frame(col1 = locations, col2 = SDs, col3 = D) # nolint
colnames(Data) <- c('sites', 'SD', 'Damping Ratio') # nolint

#MTT Calc & Storage
T = (c^-1)*((((D)^-2) - 1)^.5) # nolint
Data_T <- data.frame(col1 = locations, col2 = T) # nolint
colnames(Data_T) <- c('sites', 'T') # nolint

# Calculate mean Processed.Delta.18O for each location
mean_18O_table_15 <- id %>%
  filter(Location %in% locations) %>%
  group_by(Location) %>%
  summarise(Mean_Delta_18O = mean(Processed.Delta.18O, na.rm = TRUE)) %>%
  arrange(desc(Mean_Delta_18O))  # Optional: sort by mean value

#plots
# Split the sites into two groups of 8
sites_group1 <- locations[1:8]
sites_group2 <- locations[9:15]

# Subset Data for each group
Data_group1 <- Data[Data$sites %in% sites_group1, ]
Data_T_group1 <- Data_T[Data_T$sites %in% sites_group1, ]

Data_group2 <- Data[Data$sites %in% sites_group2, ]
Data_T_group2 <- Data_T[Data_T$sites %in% sites_group2, ]

# Plot for Group 1
# Plot for Group 1 with Larger Axis Text
pD1 <- ggplot(data = Data_group1, aes(x = sites, y = `Damping Ratio`)) +
  geom_bar(stat = "identity", color = my_blue, fill = my_green, width = 0.7) +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5, size = 18),      # Larger title
    axis.text.x = element_text(size = 16, angle = 30, hjust = 1),  # Larger x-axis text
    axis.text.y = element_text(size = 16),                  # Larger y-axis text
    axis.title.x = element_text(size = 17),                 # Larger x-axis title
    axis.title.y = element_text(size = 17),                 # Larger y-axis title
    text = element_text(family = "serif")
  ) +
  labs(subtitle = "Sampling Site Stream Data & Woodside Precipitation Data") +
  ylab(expression("Damping Ratio [SDs/SDp]")) +
  xlab("Sampling Site") +
  ggtitle(expression(O^18 ~ " Damping Ratio"))

pT1 <- ggplot(data = Data_T_group1, aes(x = sites, y = T)) +
  geom_bar(stat = "identity", color = my_green, fill = my_blue, width = 0.7) +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5, size = 18),      # Larger title
    axis.text.x = element_text(size = 16, angle = 30, hjust = 1),  # Larger x-axis text
    axis.text.y = element_text(size = 16),                  # Larger y-axis text
    axis.title.x = element_text(size = 17),                 # Larger x-axis title
    axis.title.y = element_text(size = 17),                 # Larger y-axis title
    text = element_text(family = "serif")
  ) +
  ylab(expression(tau ~ "[days]")) +
  xlab("Sampling Site") +
  ggtitle(expression(O^18 ~ " Mean Transit Time"))


# Plot for Group 2
pD2 <- ggplot(data = Data_group2, aes(x = sites, y = `Damping Ratio`)) +
  geom_bar(stat = "identity", color = my_blue, fill = my_green, width = 0.7) +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5, size = 18),      # Larger title
    axis.text.x = element_text(size = 16, angle = 30, hjust = 1),  # Larger x-axis text
    axis.text.y = element_text(size = 16),                  # Larger y-axis text
    axis.title.x = element_text(size = 17),                 # Larger x-axis title
    axis.title.y = element_text(size = 17),                 # Larger y-axis title
    text = element_text(family = "serif")
  ) +
  labs(subtitle = "Sampling Site Stream Data & Woodside Precipitation Data") +
  ylab(expression("Damping Ratio [SDs/SDp]")) +
  xlab("Sampling Site") +
  ggtitle(expression(O^18 ~ " Damping Ratio"))

pT2 <- ggplot(data = Data_T_group2, aes(x = sites, y = T)) +
  geom_bar(stat = "identity", color = my_green, fill = my_blue, width = 0.7) +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5, size = 18),      # Larger title
    axis.text.x = element_text(size = 16, angle = 30, hjust = 1),  # Larger x-axis text
    axis.text.y = element_text(size = 16),                  # Larger y-axis text
    axis.title.x = element_text(size = 17),                 # Larger x-axis title
    axis.title.y = element_text(size = 17),                 # Larger y-axis title
    text = element_text(family = "serif")
  ) +
  ylab(expression(tau ~ "[days]")) +
  xlab("Sampling Site") +
  ggtitle(expression(O^18 ~ " Mean Transit Time"))

print(pT1)
print(pT2)
print(pD1)
print(pD2)

# Save Group 1 Plots to PDF
pdf_file1 <- file.path(pdf_dir, "MeanTransitTime_Group1.pdf")
ggsave(filename = pdf_file1, plot = plot_grid(pD1, pT1, ncol = 1), device = "pdf", width = 16, height = 10)

# Save Group 2 Plots to PDF
pdf_file2 <- file.path(pdf_dir, "MeanTransitTime_Group2.pdf")
ggsave(filename = pdf_file2, plot = plot_grid(pD2, pT2, ncol = 1), device = "pdf", width = 16, height = 10)