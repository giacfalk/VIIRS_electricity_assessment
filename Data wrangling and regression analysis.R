
#Load required packages
require(plyr)
library(tidyverse)
library(lubridate)
library(sf)
library(wbstats)
library(viridis)
library(googledrive)
library(dplyr)

#import IEA data 
energy_use = read.csv("dataset_w.csv")

dataset_w = energy_use
dataset_w$YEAR=dataset_w$Time

#DOnwload data from Google Drive
drive_download("collection16.csv", type = "csv", overwrite = TRUE)
light16 = read.csv("collection16.csv")

drive_download("collection15.csv", type = "csv", overwrite = TRUE)
light15 = read.csv("collection15.csv")

drive_download("collection14.csv", type = "csv", overwrite = TRUE)
light14 = read.csv("collection14.csv")

drive_download("collection13.csv", type = "csv", overwrite = TRUE)
light13 = read.csv("collection14.csv")

drive_download("collection12.csv", type = "csv", overwrite = TRUE)
light12 = read.csv("collection14.csv")

light16 = light16 %>% select(ISO3, sum)
varnames<-c("ISO3", "lights16")
library(data.table)
setnames(light16,names(light16),varnames )

light15 = light15 %>% select(ISO3, sum)
varnames<-c("ISO3", "lights15")
setnames(light15,names(light15),varnames )

light14 = light14 %>% select(ISO3, sum)
varnames<-c("ISO3", "lights14")
setnames(light14,names(light14),varnames )

light13 = light13 %>% select(ISO3, sum)
varnames<-c("ISO3", "lights13")
setnames(light13,names(light13),varnames )

light12 = light12 %>% select(ISO3, sum)
varnames<-c("ISO3", "lights12")
setnames(light12,names(light12),varnames )

#join lights for each year
library(plyr)
lights = join_all(list(light12, light13, light14, light15, light16), by='ISO3', type='left')

#reshape and merge with IEA data
lights2 = reshape(lights, direction = "long", varying = list(names(select(lights, lights12, lights13, lights14, lights15, lights16))), v.names = "light_sum", 
                  idvar = c("ISO3"), timevar = "YEAR", times = 2012:2016)

dataset_w = merge(lights2, dataset_w, by=c("YEAR", "ISO3"), all=TRUE)

#add ISO3
library(countrycode)
dataset_w$Country = as.character(dataset_w$Country)
dataset_w2 <- dataset_w %>% mutate(Country = ifelse(is.na(dataset_w$Country), countrycode(dataset_w$ISO3, "iso3c", "country.name"), dataset_w$Country))
save(dataset_w2, file = "finalmente.Rdata")

##################

#add population
library(wbstats)
pop <- wb(indicator = "NY.GNP.PCAP.CD", startdate = 2012, enddate = 2016)

pop$ISO3 = pop$iso3c
pop$YEAR = as.numeric(pop$date)

pop$WBIC = "Low-income"
pop$WBIC[(pop$value >= 1006) &  (pop$value <= 3955)] <- "Lower-middle income"
pop$WBIC[(pop$value >= 3956 ) &  (pop$value <= 12235)] <- "Upper-middle income"
pop$WBIC[(pop$value >= 12236)] <- "High-income"

dataset_w = left_join(dataset_w, pop, by=c("ISO3", "YEAR"), all=TRUE)

pop <- wb(indicator = "SP.POP.TOTL", startdate = 2012, enddate = 2016)

pop$ISO3 = pop$iso3c
pop$YEAR = as.numeric(pop$date)

dataset_w = left_join(dataset_w, pop, by=c("ISO3", "YEAR"), all=TRUE)

#add regions
library(rworldmap) 
dataset_w3 <- merge(dataset_w, countryExData,by.x='ISO3',by.y='ISO3V10', all=TRUE)

#Regression analysis
dataset_w3=subset(dataset_w3, dataset_w3$TFC > 0 & dataset_w3$light_sum > 0 & dataset_w3$RESIDENT > 0& dataset_w3$COMMPUB > 0)

formula = "log(TFC) ~ log(light_sum)"
ols1 = lm(data=subset(dataset_w3, dataset_w3$WBIC == "Low-income"), formula = formula)
summary(ols1)

formula = "log(TFC) ~ log(light_sum)+ as.factor(ISO3) - 1"
ols2 = lm(data=subset(dataset_w3, dataset_w3$WBIC == "Low-income"), formula = formula)
summary(ols2)

formula = "log(TFC) ~ log(light_sum)+ as.factor(ISO3) -1 + as.factor(YEAR) -1"
ols3 = lm(data=subset(dataset_w3, dataset_w3$WBIC == "Low-income"), formula = formula)
summary(ols3)

library(stargazer)
stargazer(ols1, ols2, ols3, type = "latex", omit = c("ISO3", "YEAR"), dep.var.labels   = "Flight delay (in minutes)", add.lines = list(c("Country fixed effects?", "No", "Yes", "Yes"),  c("Year fixed effects?", "No", "No", "Yes")))


formula = "log(TFC) ~ log(light_sum)"
ols1 = lm(data=subset(dataset_w3, dataset_w3$WBIC == "Lower-middle income"), formula = formula)
summary(ols1)

formula = "log(TFC) ~ log(light_sum)+ as.factor(ISO3) - 1"
ols2 = lm(data=subset(dataset_w3, dataset_w3$WBIC == "Lower-middle income"), formula = formula)
summary(ols2)

formula = "log(TFC) ~ log(light_sum)+ as.factor(ISO3) -1 + as.factor(YEAR) -1"
ols3 = lm(data=subset(dataset_w3, dataset_w3$WBIC == "Lower-middle income"), formula = formula)
summary(ols3)

stargazer(ols1, ols2, ols3, type = "latex", omit = c("ISO3", "YEAR"), dep.var.labels   = "Flight delay (in minutes)", add.lines = list(c("Country fixed effects?", "No", "Yes", "Yes"),  c("Year fixed effects?", "No", "No", "Yes")))

##

formula = "log(TFC) ~ log(light_sum)"
ols1 = lm(data=subset(dataset_w3, dataset_w3$WBIC == "Upper-middle income"), formula = formula)
summary(ols1)

formula = "log(TFC) ~ log(light_sum)+ as.factor(ISO3) - 1"
ols2 = lm(data=subset(dataset_w3, dataset_w3$WBIC == "Upper-middle income"), formula = formula)
summary(ols2)

formula = "log(TFC) ~ log(light_sum)+ as.factor(ISO3) -1 + as.factor(YEAR) -1"
ols3 = lm(data=subset(dataset_w3, dataset_w3$WBIC == "Upper-middle income"), formula = formula)
summary(ols3)

stargazer(ols1, ols2, ols3, type = "latex", omit = c("ISO3", "YEAR"), dep.var.labels   = "Flight delay (in minutes)", add.lines = list(c("Country fixed effects?", "No", "Yes", "Yes"),  c("Year fixed effects?", "No", "No", "Yes")))


####

formula = "log(TFC) ~ log(light_sum)"
ols1 = lm(data=subset(dataset_w3, dataset_w3$WBIC == "High-income"), formula = formula)
summary(ols1)

formula = "log(TFC) ~ log(light_sum)+ as.factor(ISO3) - 1"
ols2 = lm(data=subset(dataset_w3, dataset_w3$WBIC == "High-income"), formula = formula)
summary(ols2)

formula = "log(TFC) ~ log(light_sum)+ as.factor(ISO3) -1 + as.factor(YEAR) -1"
ols3 = lm(data=subset(dataset_w3, dataset_w3$WBIC == "High-income"), formula = formula)
summary(ols3)

stargazer(ols1, ols2, ols3, type = "latex", omit = c("ISO3", "YEAR"), dep.var.labels   = "Flight delay (in minutes)", add.lines = list(c("Country fixed effects?", "No", "Yes", "Yes"),  c("Year fixed effects?", "No", "No", "Yes")))


##Regional regressions

formula = "log(TFC) ~ log(light_sum)*as.factor(EPI_regions) -1"
ols1 = lm(data=dataset_w3, formula = formula)
summary(ols1)

formula = "log(TFC) ~ log(light_sum)*as.factor(EPI_regions) -1+ as.factor(ISO3) - 1"
ols2 = lm(data=dataset_w3, formula = formula)
summary(ols2)

formula = "log(TFC) ~ log(light_sum)*as.factor(EPI_regions) -1 + as.factor(ISO3) -1 + as.factor(YEAR) -1"
ols3 = lm(data=dataset_w3, formula = formula)
summary(ols3)

library(stargazer)
stargazer(ols1, ols2, ols3, type = "latex", omit = c("ISO3", "YEAR"), dep.var.labels   = "Flight delay (in minutes)", add.lines = list(c("Country fixed effects?", "No", "Yes", "Yes"),  c("Year fixed effects?", "No", "No", "Yes")))

