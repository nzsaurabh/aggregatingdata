# Input data file: ufo.csv
# data source: https://www.kaggle.com/NUFORC/ufo-sightings/home
# Acknowledgement: This dataset was scraped, geolocated, and time standardized from NUFORC data by Sigmond Axel

# Objective: reshape into time series of monthly sightings
# Purpose: (1) demonstrate usage of sql to aggregate / collect the rows into monthly counts
# (2) be careful of including months or dates with no sightings for time series analysis

# data format: long format data providing ufo sightings.
# Each row is a sighting. 
# Columns / Variables include amongst others - date and location of the sightings
# This implies that months with zero sightings will not be in the dataset

# Note:
# I will not be overwriting the R objects / data frames so that you can easily compare them to new objects
# To be memory efficient, ideally, you should overwrite the existing objects wherever possible

# Code begins here #########

# assuming the data and the script are in the same folder (i.e. source folder)
# get source folder in R studio

sourcefolder <- dirname(rstudioapi::getSourceEditorContext()$path)

# set working directory to the source folder
setwd(sourcefolder)

# read data from csv file
# Don't read character variables as factors
ufodata <- read.csv("ufo_scrubbed.csv", stringsAsFactors = FALSE)

# view first few rows
head(ufodata)

# data has 80332 rows of 11 variables
# datetime is in "mm/dd/yyyy hh:mm" format. It has been read in as a character variable
str(ufodata)

# Find missing values
missfun <- function(x){sum(is.na(x))}

# the data was already scrubbed, so no missing values here
lapply(ufodata, FUN = missfun)

# Sightings before 1960 are very few and far between. 
# We can subset data to look at only after 1960 for trends.

# first get dates ######
# we can use regular expressions to directly get the month and year.
# I'll use date format for rigour and flexibility.

# dates are the first 10 characters in mm/dd/yyyy format
ufodata$datetime[1:6]

# split the date
ufodata$date <- substr(ufodata$datetime, start = 1, stop = 10)

ufodata$date[1:6]

ufodata$date <- as.Date(ufodata$date, format = "%m/%d/%Y")

# check on a sample of rows
rowindex <- 1:nrow(ufodata)

samplerows <- sample(rowindex, 10)

# check if dates have been created correctly
# they look correct
# ufodata$date is now in standard R date format "yyyy-mm-dd".
ufodata$date[samplerows]
ufodata$datetime[samplerows]

# create year month variable for collecting the monthly time series
ufodata$yearmonth <- format(ufodata$date, format="%Y-%m")

# looks good. now we have all the required date variables
ufodata$yearmonth[samplerows]

# subset the data #########
# subset data to look at only after 1960 for trends
# creating a separate object to enable comparison
# data for May 2014 is only of 10 days so subset it
data1960 <- ufodata[ufodata$date > as.Date("1960-01-01"), ]

data1960 <- data1960[data1960$date < as.Date("2014-05-01"), ]


# now we have 79662 rows
nrow(data1960)

# aggregate using sql ##########
# load library for sql
require(sqldf)

monthlydata <- sqldf("SELECT yearmonth, COUNT(*) as sightings
                          FROM data1960
                          GROUP BY yearmonth")

# now it has aggregated to 647 months of data
nrow(monthlydata)

# data is now sorted by yearmonth because of GROUP BY command
# first month is 1960-01 
head(monthlydata)

# latest month is 2014-04
tail(monthlydata)

# account for months with zero sightings

# Time series data needs observations every month
# There need to be 652 months in the timeframe
# Create vector of months during the time period

# create sequence of months
monthly_seq <- seq.Date(as.Date("1960-01-01"), as.Date("2014-04-30"), by = "month")

# put in year month format - same as our variable
monthly_seq <- format(monthly_seq, format="%Y-%m")
length(monthly_seq)

# check first and last few months
# created correctly as they match monthlydata$yearmonth
head(monthly_seq)
tail(monthly_seq)

# Check if only 5 months have no sightings and rest are the same
sum( !(monthly_seq  %in% monthlydata$yearmonth))

# create new data frame so we have zeros for the required months
monthlydata_complete <- data.frame(yearmonth = monthly_seq, 
                          sightings = rep(0, length(monthly_seq)))

# check
head(monthlydata_complete)

tail(monthlydata_complete)

# Add sighting counts to relevant months

monthlydata_complete$sightings[
  (monthlydata_complete$yearmonth %in% monthlydata$yearmonth)
  ] <- monthlydata$sightings


# Check months with 0 counts

monthlydata_complete[monthlydata_complete$sightings == 0,]

# check head and tail
head(monthlydata_complete)

tail(monthlydata_complete)

# Final time series object #####

# now that we have data for all months i.e. including zeros,
# we can analyse it as a time series
# create time series object of monthly sightings

monthly_ts <- ts(monthlydata_complete$sightings, frequency = 12,
                 start = c(1960, 01))

plot(monthly_ts, main = "Global UFO sightings" ,
     ylab = "Monthly Sightings")

