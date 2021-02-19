##########################
###########################
### datacamp time series case studies
ipak <- function(pkg){
  new.pkg <- pkg[!(pkg %in% installed.packages()[, "Package"])]
  if (length(new.pkg))
    install.packages(new.pkg, dependencies = TRUE)
  try(sapply(pkg, require, character.only = TRUE), silent = TRUE)
}
packages <- c("xts", "zoo", "astsa")
ipak(packages)
################
################
# https://learn.datacamp.com/courses/case-studies-manipulating-time-series-data-in-r
# 



####################################
####### chapter 1
####################################

# one or more units over years
# xts facilitates time series objects
# index + matrix

# flight data
# flight delay cancellations, 2010 through 2015
# 

#View the structure of the flights data
str(flights)

#Examine the first five rows of the flights data
head(flights, n = 5)

#Identify class of the column containing date information
class(flights$date)

# xts objects have the functionality of a simple matrix while containing an index allowing easy manipulation over time.

# Load the xts package
library(xts)

# Convert date column to a time-based class
flights$date <- as.Date(flights$date)

# Convert flights to an xts object using as.xts
flights_xts <- as.xts(flights[ , -5], order.by = flights$date)

# Check the class of flights
class(flights_xts)

# View the first five lines of flights
head(flights_xts, n = 5)


###############
## Manipulating and visualizing your data
## periodicity: units of time in your data (periodicity and scope of your data)
## 
# plot.xts()
# plotting time series data
# can plot the relative change data


# Identify the periodicity of flights_xts
periodicity(flights_xts)

# Identify the number of periods in flights_xts
nmonths(flights_xts)

# Find data on flights arriving in BOS in June 2014
flights_xts["2014-06-01",]


# Use plot.xts() to view total monthly flights into BOS over time
plot.xts(flights_xts[,"total_flights"])

# Use plot.xts() to view monthly delayed flights into BOS over time
plot.xts(flights_xts[,"delay_flights"])

# Use plot.zoo() to view all four columns of data in their own panels
plot.zoo(flights_xts, plot.type = "multiple", ylab = labels)

# Use plot.zoo() to view all four columns of data in one panel
plot.zoo(flights_xts, plot.type = "single", lty = lty)
legend("right", lty = lty, legend = labels)

# 
# Calculate percentage of flights delayed each month: pct_delay
flights_xts$pct_delay <- (flights_xts$delay_flights / flights_xts$total_flights) * 100

# Use plot.xts() to view pct_delay over time
plot.xts(flights_xts$pct_delay)

# Calculate percentage of flights cancelled each month: pct_cancel
flights_xts$pct_cancel <- (flights_xts$cancel_flights / flights_xts$total_flights) * 100

# Calculate percentage of flights diverted each month: pct_divert
flights_xts$pct_divert <- (flights_xts$divert_flights / flights_xts$total_flights) * 100

# Use plot.zoo() to view all three trends over time
plot.zoo(x = flights_xts[ , c("pct_delay", "pct_cancel", "pct_divert")])


# saving and exporting xts objects
# saving as rds (most reliable and efficient way)

# in R
# saveRDS
# readRDS

# saving as csv
# write.zoo()
# read.zoo()
# sep = "," for csv files
# 

# Exactly! Your plot suggests that the percentage of flight cancellations spikes around December and January each year, with the exception of 2012. What could be causing this trend? You'll explore some possibilities later in the course.


# Save your xts object to rds file using saveRDS
saveRDS(object = flights_xts, file = "flights_xts.rds")

# Read your flights_xts data from the rds file
flights_xts2 <- readRDS("flights_xts.rds")

# Check the class of your new flights_xts2 object
class(flights_xts2)

# Examine the first five rows of your new flights_xts2 object
head(flights_xts2, n=5)


# 
# Export your xts object to a csv file using write.zoo
write.zoo(flights_xts, file = "flights_xts.csv", sep = ",")

# Open your saved object using read.zoo
flights2 <- read.zoo("flights_xts.csv", sep = ",", FUN = as.Date, header = TRUE, index.column = 1)

# Encode your new object back into xts
flights_xts2 <- as.xts(flights2)

# Examine the first five rows of your new flights_xts2 object
head(flights_xts2, n=5)



###########################################
########## chapter 2
############################################

# merging by row
# merging by rbind()
# xts objects are automatically ordered in time
# merging xts using rbind() preserves order
# weather data

# 

# View the structure of each object
str(temps_1)
str(temps_2)

# View the first and last rows of temps_1
head(temps_1, n=1)
tail(temps_1, n=1)

# View the first and last rows of temps_2
head(temps_2, n=1)
tail(temps_2, n=2)


# 
# Confirm that the date column in each object is a time-based class
class(temps_1$date)
class(temps_2$date)

# Encode your two temperature data frames as xts objects
temps_1_xts <- as.xts(temps_1[, -4], order.by = temps_1$date)
temps_2_xts <- as.xts(temps_2[, -4], order.by = temps_2$date)

# View the first few lines of each new xts object to confirm they are properly formatted
head(temps_1_xts)
head(temps_2_xts)

# Use rbind to merge your new xts objects
temps_xts <- rbind(temps_1_xts, temps_2_xts)

# View data for the first 3 days of the last month of the first year in temps_xts
first(last(first(temps_xts, "1 year"), "1 month"), "3 days")


# Identify the periodicity of temps_xts
periodicity(temps_xts)

# Generate a plot of mean Boston temperature for the duration of your data
plot.xts(temps_xts$mean)

# Generate a plot of mean Boston temperature from November 2010 through April 2011
plot.xts(temps_xts$mean["201011/201104"])

# Use plot.zoo to generate a single plot showing mean, max, and min temperatures during the same period 
plot.zoo(temps_xts["201011/201104"], plot.type = "single", lty = lty)






#################
## Merging time series data by column
################
# preparing to merge
# check periodicity and coverage
# periodicity
# 

# subset data to include similar coverage
temps_xts2 <- temps_xts["2010/2015"]
# convert periodicity
# 
temps_monthly <- to.period(temps_xts_2, period = "months")

# can only convert to lower frequency
# 

# merge() with xts
# order of rows is based on time index
# 

# Subset your temperature data to include only 2010 through 2015: temps_xts_2
temps_xts_2 <- temps_xts["2010/2015"]

# Use to.period to convert temps_xts_2 to monthly periodicity
# avoid generating new OHLC columns. Finally, set the indexAt argument # to "firstof" to select the first observation each month.
temps_monthly <- to.period(temps_xts_2, period = "months", OHLC = FALSE, indexAt = "firstof")

# Compare the periodicity and duration of temps_monthly and flights_xts 
periodicity(temps_monthly)
periodicity(flights_xts)

# Split temps_xts_2 into separate lists per month
monthly_split <- split(temps_xts_2$mean , f = "months")

# Use lapply to generate the monthly mean of mean temperatures
mean_of_means <- lapply(monthly_split, FUN = mean)

# Use as.xts to generate an xts object of average monthly temperature data
temps_monthly <- as.xts(as.numeric(mean_of_means), order.by = index)

# Compare the periodicity and duration of your new temps_monthly and flights_xts 
periodicity(temps_monthly)
periodicity(flights_xts)


# 
# Use merge to combine your flights and temperature objects
flights_temps <- merge(flights_xts, temps_monthly)

# Examine the first few rows of your combined xts object
head(flights_temps)

# Use plot.zoo to plot these two columns in a single panel
plot.zoo(flights_temps[,c("pct_delay", "temps_monthly")], plot.type = "single", lty = lty)
legend("topright", lty = lty, legend = labels, bg = "white")


# Time series data workflow
# workflow for merging
# 1, encode all time series objects to xts
# 2, examine and adjust periodicity
# also want to ensure xts objects covering similar time periods
# 3, merge xts objects

# 
# Confirm the periodicity and duration of the vis and wind data
periodicity(vis)
periodicity(wind)


# Merge vis and wind with your existing flights_temps data
flights_weather <- merge(flights_temps, vis, wind)

# View the first few rows of your flights_weather data
head(flights_weather)