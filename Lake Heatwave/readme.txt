input dataset:

1) the "daily_LSWT_data_onlyopenmonth_riwnc2724lake.mat" file is a matrix with 2,724 rows and 14,610 columns; the data of each row is the daily LSWT series for individual lake during the period of 1981-2020. Note that the values of the freezing month are all assigned as NaN.

2) the "ndays_openmonth_byDailyflake_riwnc2724lake.mat" file is a matrix with 2,724 rows and 40 columns; the data of each row represents the total number of days with completely ice-free months for each year from 1981 to 2020.

3) the "daily_LSWT_dateinfo.mat" file describes the date of time-series lake surface water temperature, with 14,610 rows (representing the total days from 1981 to 2020) and 3 columns (Year, Month, and Day).

4) the "daily_LSWT_lakeinfo_riwnc2724lake.mat" file describes the locations (Hylak_id, Latitude, and Longitude) of the studied 2,724 lakes, with 2,724 rows and 3 columns. The Hylak_id is the same as the HydroLAKES v1.0 dataset.

output dataset:
5) the "glast_lake_hotevents_riwnc2724lake.csv" file is a matrix with 2,724 rows and 40 columns; the data of each row is the calculated annually heatwave frequency for each lakes from 1981 to 2020. The code is contained in "heatwave_freq_code_riwnc2724lake.R" file.
