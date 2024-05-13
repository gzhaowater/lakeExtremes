Sys.setenv(TZ='UTC')
library(raveio)
# install.packages('moments',repos='http://cran.us.r-project.org')
library(heatwaveR)
library(moments)
# library(dplyr)

# Create mode function
getmode <- function(v) {
  uniqv <- unique(v)
  uniqv[which.max(tabulate(match(v, uniqv)))]
}

# path
ifid <- '/datapath' 
scratch_fid <- '/outputpath'


# load GLAST dataset: daily lake surface temperature. Note that the values of the freezing month are all assigned as NaN.
idata_all <- read_mat(paste0(ifid,'/','daily_LSWT_data_onlyopenmonth_riwnc2724lake.mat'))
mydata <- idata_all$daily_LSWT_data_onlyopenmonth_riwnc2724lake

# load ndays ndays_completelyopenmonth
ndays_openmonthall <- read_mat(paste0(ifid,'/','ndays_openmonth_byDailyflake_riwnc2724lake.mat'))
ndays_openmonthall <- ndays_openmonthall$ndays_openmonth_byDailyflake_riwnc2724lake

# load date info
idate <- read_mat(paste0(ifid,'/','daily_LSWT_dateinfo.mat'))
idate <- matrix(unlist(idate), ncol = 3)
itime <- as.Date(ISOdate(idate[,1],idate[,2],idate[,3],tz = "UTC"))

# load lake info
ilake_all <- read_mat(paste0(ifid,'/','daily_LSWT_lakeinfo_riwnc2724lake.mat'))
ilake_all <- matrix(unlist(ilake_all), ncol = 3)




# calculate unique months and years
imonth <- as.numeric(strftime(as.POSIXct(itime),format = '%m'))
umonth <- unique(imonth)

iyear <- as.numeric(strftime(as.POSIXct(itime),format = '%Y'))
uyear <- unique(iyear)


alloutput <- matrix(NA, nrow = nrow(ilake_all), ncol = length(uyear))

for(i in 1:nrow(ilake_all)){

  #
  cat(paste('Run code for Hylak ', ilake_all[i,1],'...started','\n', sep = ''))
  
  #
  ilakeid <- ilake_all[i,1]

  #
  idat_mean <- as.vector(mydata[i,])
  df_mean <- data.frame(t = itime,
                        temp = idat_mean)
  
  #
  #rm(idat_mean,idat_max,idat_min)
  gc()
  
  
  # only proceed if at least 30 days each year are ice-free
  if(all(ndays_openmonthall[i,] > 30)){

    # generate complete time series for heatwaver algorithm
    mdf_mean <- merge(df_mean, data.frame(t = as.Date(itime)),
                      by = 't', all = TRUE)
    #
    clim_mean <- ts2clm(mdf_mean, x = t, y = temp,climatologyPeriod = c('1991-01-01','2020-12-31'),
                       robust = FALSE, maxPadLength = 3,windowHalfWidth = 5,pctile = 90,
                       smoothPercentile = TRUE, smoothPercentileWidth = 31,
                       clmOnly = FALSE, var = FALSE, roundClm = 4)
    
    #
    out_mean <- detect_event(clim_mean, x = t, y = temp, seasClim = seas, threshClim = thresh,
                            threshClim2 = NA, minDuration = 1, minDuration2 = minDuration,
                            joinAcrossGaps = TRUE, maxGap = 2, maxGap2 = maxGap,
                            coldSpells = FALSE, protoEvents = FALSE)
    
    
    #
    out2_mean <- as.data.frame(out_mean$climatology)
    durations_eachevent <- table(out2_mean$event_no)         
    indexes <- which(durations_eachevent < 5)               
    out2_mean <- subset(out2_mean, !(event_no %in% indexes))  
    
    out2_mean <- out2_mean[,c('t','temp','seas','event','event_no')]
    out2_mean$int <- out2_mean$temp - out2_mean$seas
    out2_mean <- out2_mean[out2_mean$event,]
    out2_mean <- out2_mean[,c('t','int','event_no')]
    colnames(out2_mean) <- c('time','int','event_no')
    
    #
    if(any(!is.na(out2_mean$event_no))){
      #
      out2_mean$year <- as.numeric(strftime(out2_mean$time,format = '%Y'))
      
      #
      out6 <- out2_mean
      out6 <- out6[,c('time','year','int')]
      colnames(out6) <- c('time','year','int')
      
      
      #
      ifreq <- rep(0,length(uyear))
      for(ii in 1:length(uyear)){
        idx <- out6$year == uyear[ii]
        if(any(idx)){
          out6b <- out6[idx,c('time','int')]
          # annual statistics
          ifreq[ii] <- round(nrow(out6b)/ndays_openmonthall[i,ii]*100,3)
        }
      }
      
      #

      alloutput[i,] <- ifreq #ilake_night_freq[i,]  
    }
  }

  #
  cat(paste('Run code for i ',i ,', Hylak ', ilakeid,'...finished','\n', sep = ''))
}
write.table(alloutput,paste0(scratch_fid,'/','glast_lake_hotevents_riwnc2724lake.csv'),
            quote = FALSE, sep = ',', col.names = FALSE, row.names = FALSE)
