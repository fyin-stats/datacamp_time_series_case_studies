##########################
###########################
### datacamp time series case studies
ipak <- function(pkg){
  new.pkg <- pkg[!(pkg %in% installed.packages()[, "Package"])]
  if (length(new.pkg))
    install.packages(new.pkg, dependencies = TRUE)
  try(sapply(pkg, require, character.only = TRUE), silent = TRUE)
}
packages <- c("xts", "zoo", "astsa","dplyr")
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








#############################
### chapter 3
#############################
### Handling missingness
#############################

### fill NAs with last observation
### Last observation carried forward (LOCB)

### fill NAs with next observation (NOCB)
citydata_nocb <- na.locf(citydata, fromLast = TRUE)

### 
plot.xts(citydata)
plot.xts(citydata_nocb)

### linear interpolation
### 
citydata_approx <- na.approx(citydata)
plot.xts(citydata)
plot.xts(citydata_nocb)

### 
# Get a summary of your GDP data
summary(gdp)

# Convert GDP date column to time object
gdp$date <- as.yearqtr(gdp$date)

# Convert GDP data to xts
gdp_xts <- as.xts(gdp[, -1], order.by = gdp$date)

# Plot GDP data over time
plot.xts(gdp_xts)

# Fill NAs in gdp_xts with the last observation carried forward
gdp_locf <- na.locf(gdp_xts, fromLast=FALSE)

# Fill NAs in gdp_xts with the next observation carried backward 
gdp_nocb <- na.locf(gdp_xts, fromLast=TRUE)

# Produce a plot for each of your new xts objects
par(mfrow = c(2,1))
plot.xts(gdp_locf, major.format = "%Y")
plot.xts(gdp_nocb, major.format = "%Y")

# Query for GDP in 1993 in both gdp_locf and gdp_nocb
gdp_locf["1993"]
gdp_nocb["1993"]

# Fill NAs in gdp_xts using linear approximation
gdp_approx <- na.approx(gdp_xts)

# Plot your new xts object
plot.xts(gdp_approx, major.format = "%Y")

# Query for GDP in 1993 in gdp_approx
gdp_approx["1993"]

#
# Exactly! Based on the non-missing data, GDP tends to grow at fairly predictable rates (with notable exceptions). 
# For this reason, you should estimate missing values using linear interpolation. This method will not 
# detect sudden shifts in GDP from quarter to quarter, but can provide a general approximation of trends. 


################################
# Lagging and differencing
# moving indicators
################################
# lagging
# lag offsets observations in time
################################
# diff(unemployment, lag = 1)
# 


# View a summary of your unemployment data
summary(unemployment)

# Use na.approx to remove missing values in unemployment data
unemployment <- na.approx(unemployment)

# Plot new unemployment data
plot.zoo(unemployment, plot.type = "single", lty = lty)
legend("topright", lty = lty, legend = labels, bg = "white")


# Create a one month lag of US unemployment
us_monthlag <- lag(unemployment$us, k = 1)

# Create a one year lag of US unemployment
us_yearlag <- lag(unemployment$us, k = 12)

# Merge your original data with your new lags 
unemployment_lags <- merge(unemployment, us_monthlag, us_yearlag)

# View the first 15 rows of unemployment_lags
head(unemployment_lags, 15)


#
# Generate monthly difference in unemployment
unemployment$us_monthlydiff <- diff(unemployment$us, lag = 1, differences = 1)

# Generate yearly difference in unemployment
unemployment$us_yearlydiff <- diff(unemployment$us, lag = 12, differences = 1)

# Plot US unemployment and yearly difference
par(mfrow = c(2,1))
plot.xts(unemployment$us)
plot.xts(unemployment$us_yearlydiff, type = "h")



# Rolling functions
# function applied to a specific time window
# discrete windows: split, apply, bind

# rollapply(unemployment, width, FUN)

# unemployment

# Add a quarterly difference in gdp
gdp$quarterly_diff <- diff(gdp$gdp, lag = 1, differences = 1)

# Split gdp$quarterly_diff into years
gdpchange_years <- split(gdp$quarterly_diff, f = "years")

# Use lapply to calculate the cumsum each year
gdpchange_ytd <- lapply(gdpchange_years, FUN = cumsum)

# Use do.call to rbind the results
gdpchange_xts <- do.call(rbind, gdpchange_ytd)

# Plot cumulative year-to-date change in GDP
plot.xts(gdpchange_xts, type = "h")


# Use rollapply to calculate the rolling yearly average US unemployment
unemployment$year_avg <- rollapply(unemployment$us, width = 12, FUN = mean)

# Plot both columns of US unemployment data
plot.zoo(unemployment[, c("us", "year_avg")], plot.type = "single", lty = lty, lwd = lwd)

# 

# Add a one-year lag of MA unemployment
unemployment$ma_yearlag <- lag(unemployment$ma, k = 12)

# Add a six-month difference of MA unemployment
unemployment$ma_sixmonthdiff <- diff(unemployment$ma, lag = 6, differences = 1)

# Add a six-month rolling average of MA unemployment
unemployment$ma_sixmonthavg <- rollapply(unemployment$ma, width = 6, FUN = mean)

# Add a yearly rolling maximum of MA unemployment
unemployment$ma_yearmax <- rollapply(unemployment$ma, width = 12, FUN = max)

# View the last year of unemployment data
tail(unemployment, n = 12)