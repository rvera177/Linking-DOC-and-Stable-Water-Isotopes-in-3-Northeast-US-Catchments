#---------------------Library--------------------------------------------
library(tibble)
library(lubridate)
library(pdftools)
library(ggplot2)
library(cowplot)
library(wesanderson)
library(r2symbols) 

#defining colors i like 
my_colors1 = wes_palette(n=5, name = "Royal2")

green = my_colors1[1]
sage_green = my_colors1[5]

my_colors2 = wes_palette(n=4, name = "Moonrise2")

slate_blue = my_colors2[1]
orange = my_colors2[2]

my_colors3 = wes_palette(n=4, name = "GrandBudapest2")

red = my_colors3[3]
blue = my_colors3[4]


#---------DIRECTORY----------------------------------------------------------------------

#set working directory
setwd("C:/Users/Ruli's computer/OneDrive/Documents/Soil&Water lab/R-scripts")

#create pdf for plots to go to !
pdf_dir <- "C:/Users/Ruli's computer/OneDrive/Documents/Soil&Water lab/R-scripts"

# Create the directory if it doesn't exist
if (!dir.exists(pdf_dir)) {
  dir.create(pdf_dir, recursive = TRUE)
}

#--------LOADING DATA & SORTING ----------------------------------------------------------------------

#load data & store it in variable
isotope_data <- read.csv("Isotope Inventory_January 2025.csv", header = TRUE, sep = ",")

#only observed needed columns
i_data <- isotope_data[c(2,3,7,12,14)]

# Check column names in i_data
colnames(i_data)


#converts to numbers & dates
as.numeric(i_data$ID, i_data$Processed.Delta.2H, i_data$Processed.Delta.18O)
#sorts data
i_data_sort <- i_data[order(i_data$Location, decreasing = TRUE),]

#removed missing data
i_data_NA <- na.omit(i_data_sort)

#creates date column 
dates <- mdy(i_data_NA$Date, quiet = FALSE, tz= NULL, locale = Sys.getlocale("LC_TIME"), truncated = 0)

#column of row numbers
rows <- c(1:length(i_data_NA$Location))

#adds dates to data set
bind_dates <-cbind(i_data_NA, dates)

#adds new row numbers to data set
id_bind_row <- cbind(bind_dates, rows)
id <- id_bind_row[c(1,6,5,3,4)]

#removes outlier values
id <- subset(id,  Processed.Delta.18O >= -100)
#sorts data based off location
locations <- c("Tan Brook Up", "Tan Brook Down", "Roaring", "Mill Site", "Lake Warner Out", "Knightly", "Horse Up", "Horse Down", "Eastman Up", "Eastman Down", "Doolittle", "Campus Pond Up", "Campus Pond Down", "WET CENTER")
location_data_list <- list()


for (location in locations) {
  location_data <- id[id$Location == location, ]
  
  #Order the data by dates
  location_data <- location_data[order(location_data$dates), ]
  
  # Save the data set in the list
  location_data_list[[location]] <- location_data
  
  assign(location, location_data)
  
}
#------------------urban plots------------------------------
urban <- rbind( `Tan Brook Up`, `Tan Brook Down`, `Campus Pond Up`, `Campus Pond Down`, `WET CENTER`)

plot_urban <- ggplot(data = urban, aes(x = Processed.Delta.18O, y = Processed.Delta.2H, shape = Location, fill = Location)) +
  geom_point(alpha = .8, size = 3, color = "grey") +
  scale_shape_manual(values = c(21,22,23,24,25,20))+
  scale_fill_manual(values = c(blue, slate_blue, green, red, orange, sage_green)) +
  ylab(expression(paste(delta^2~"H"," ", "[\u2030]", ""["VSMOW"]))) +
  xlab(expression(paste(delta^18~"O"," ","[\u2030]", ""["VSMOW"]))) + 
  theme(legend.text = element_text(size = 14), legend.title = element_text(size = 14)) +
  theme(legend.position.inside = c(0.8, 0.8)) +
  theme_minimal()+ 
  theme(plot.title = element_text(hjust = 0.5))+
  theme(text=element_text(family = "serif")) + 
  ggtitle("Urban Land-Usage")
print(plot_urban)

#------------------rural plots------------------------------
rural <- rbind(Doolittle, `Eastman Down`, `Eastman Up`, `Lake Warner Out`, `Mill Site`, Roaring)

plot_rural <- ggplot(data = rural, aes(x = Processed.Delta.18O, y = Processed.Delta.2H, shape = Location, fill = Location)) +
  geom_point(alpha = .8, size = 3, color = "grey") +
  scale_shape_manual(values = c(21,22,23,24,25,20))+
  scale_fill_manual(values = c(blue, slate_blue, green, red, orange, sage_green)) +
  ylab(expression(paste(delta^2~"H"," ", "[\u2030]", ""["VSMOW"]))) +
  xlab(expression(paste(delta^18~"O"," ","[\u2030]", ""["VSMOW"]))) + 
  theme_minimal()+ 
  theme(plot.title = element_text(hjust = 0.5))+
  theme(text=element_text(family = "serif")) + 
  ggtitle("Rural Land-Usage")

print(plot_rural)

#------------------agriculture sites ------------------------------
agriculture <- rbind(Knightly, `Horse Up`, `Horse Down`)

plot_agricultural <- ggplot(data = agriculture, aes(x = Processed.Delta.18O, y = Processed.Delta.2H, shape = Location, fill = Location, color = Location)) +
  geom_point(alpha = .8, size = 3, color = "grey") +
  scale_shape_manual(values = c(21,22,23,24,25,20))+
  geom_smooth(method=lm,se=FALSE,fullrange=TRUE,aes(color=Location)) +
  scale_color_manual(values = c(blue, orange, sage_green)) +
  scale_fill_manual(values = c(blue,orange,sage_green)) +
  ylab(expression(paste(delta^2~"H"," ", "[\u2030]", ""["VSMOW"]))) +
  xlab(expression(paste(delta^18~"O"," ","[\u2030]", ""["VSMOW"]))) + 
  theme(legend.text = element_text(size = 18), legend.title = element_text(size = 18)) +
  theme(legend.position = c(0.8, 0.8)) +
  theme_minimal()+ 
  theme(plot.title = element_text(hjust = 0.5))+
  theme(text=element_text(family = "serif")) + 
  ggtitle("Agricultural Land-Usage")

print(plot_agricultural)

#-------Wet Center only
WC <- rbind(`WET CENTER`)

library(ggpubr)

# Filter for only precipitation samples at the WET CENTER location
WC_precip <- subset(`WET CENTER`, Type == "precipitation")
# Check column names to ensure 'Type' is correctly referenced

colnames(`WET CENTER`)

# Filter for only precipitation samples at the WET CENTER location
WC_precip <- subset(`WET CENTER`, Type == "Precipitation")
# Filter for only stream samples at the WET CENTER location
WC_stream <- subset(`WET CENTER`, Type == "Stream")

# Create the plot using only precipitation data
plot_WC_precip <- ggplot(data = WC_precip, aes(x = Processed.Delta.18O, y = Processed.Delta.2H, shape = Location, fill = Location)) +
  geom_point(alpha = .8, size = 3, color = "grey") +
  geom_smooth(method = "lm", se = FALSE, color = "blue") +  # Linear trend line for precipitation data
  geom_abline(slope = 8, intercept = 10, color = "black", linetype = "dashed", size = 1, alpha = 0.8) +  # GMWL line
  scale_shape_manual(values = c(21, 22, 23, 24, 25, 20)) +
  scale_fill_manual(values = c(blue, slate_blue, green, red, orange, sage_green)) +
  ylab(expression(paste(delta^2~"H"," ", "[\u2030]", ""["VSMOW"]))) +
  xlab(expression(paste(delta^18~"O"," ","[\u2030]", ""["VSMOW"]))) + 
  theme_classic() + 
  theme(plot.title = element_text(hjust = 0.5)) +
  theme(text = element_text(family = "serif")) + 
  ggtitle("Wet Center LMWL (Precipitation Only)") +
  annotate("text", x = -7, y = -25, label = "GMWL: δ²H = 8δ¹⁸O + 10", angle =25, size = 4, color = "black") +
  
  # Add regression equation and R-squared
  stat_regline_equation(
    aes(label = paste(..eq.label.., ..rr.label.., sep = "~~~")), 
    label.x = -5, label.y = -60, 
    color = "blue", size = 4, 
    formula = y ~ x
  )  +

  xlim(c(-10, -1)) +  # Adjust x-axis range (example values)
  ylim(c(-70, -10))  # Adjust y-axis range (example values)

print(plot_WC_precip)



#--------big plot-----
plot_grid(plot_urban, plot_rural, plot_agricultural, ncol = 1, nrow = 3)

pdf_file <- file.path(pdf_dir, paste0("RatioLandUsage.pdf"))

ggsave(filename = pdf_file, plot = last_plot(), device = "pdf", width = 10, height = 10)




