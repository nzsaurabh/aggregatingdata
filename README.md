# aggregatingdata
Aggregate data in R using simple SQL commands.
This example aggregates 80,332 individual observations into monthly counts.
Its starightforward for people familiar with SQL. Fortunately, we can use it within R using library sqldf.
This technique can be used for aggregating by any group variable in R.

Secondly, the objective is time series analysis. Hence, care has to be taken for months for which there are no observations.
For this I created the correct sequence of months. Then mapped the counts to the correct months using %in% in R.
A similar technique can be used when aggregating by a factor variable when some levels may not have any data.

About the dataset:

data format: long format data providing ufo sightings.
data source: https://www.kaggle.com/NUFORC/ufo-sightings/home
Acknowledgement: This dataset was scraped, geolocated, and time standardized from NUFORC data by Sigmond Axel

If you wish to see more analysis on this dataset, please visit my ufo sightings repository https://github.com/nzsaurabh/ufo_sightings
