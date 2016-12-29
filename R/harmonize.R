#1) Load the vector "harmonized_vars.csv" into a variable "vars" in R
#2) Load the .dta file > db = read.dta(file.choose(), convert.factors=FALSE)
#3) Write CSV file > write.table(db[,vars], file=file.choose(), sep="\t", col.names=TRUE, row.names=FALSE, quote=TRUE, na="", fileEncoding="UTF-8")
#4) In Kettle: Set the file name in the parameters and run the transformation


#Argentina: //Sdssrv03/surveys/harmonized/ARG/EPHC/data_arm/ARG_2015s1_BID.dta
#Brasil: \\Sdssrv03\surveys\harmonized\BRA\PNAD\data_arm
#Bolivia:  \\Sdssrv03\surveys\harmonized\BOL\ECH\data_arm
#Chile: \\Sdssrv03\surveys\harmonized\CHL\CASEN\data_arm
#Ecuador: \\Sdssrv03\surveys\harmonized\ECU\ENEMDU\data_arm
#Guatemala: \\Sdssrv03\surveys\harmonized\GTM\ENEI\data_arm
#Peru : \\Sdssrv03\surveys\harmonized\PER\ENAHO\data_arm
#Uruguay \\Sdssrv03\surveys\harmonized\URY\ECH\data_arm
library(stringr)
library(foreign)
library(dplyr)
#db <-read.dta(paste0("./data/BOL_2014m11_BID.dta"), convert.factors=True)

readFile <- function(factor=FALSE)
{

vars <- read.table("harmonized_vars.csv", header=T)

files <- list.files("./data") 

mecovi_list <- list()
mecovi_vars <- list()


  for(i in 1:length(files)){
    
    db <-read.dta(paste0("./data/",files[i]), convert.factors=factor)
    
    #name of the columns
    dbVars <- as.data.frame(colnames(db))
    colnames(dbVars)<- c("var")
    
    fname = str_sub(files[i],1,-5) # remove .csv from the file name
    
    print(paste0("Reading: ",fname))
    
    db2<-db[,t(vars)]
    
    # creates a variable with the file name
    db2$survey = rep(fname, nrow(db)) 
    dbVars$survey=rep(fname, nrow(dbVars)) 
    
    
    
    mecovi_list[[i]] = db2  
    mecovi_vars[[i]] = dbVars  
    
    #write.table(db2, file=paste0(fname,".csv"), sep=",", col.names=TRUE, row.names=FALSE, quote=TRUE, na="", fileEncoding="UTF-8")
  }

#print("Starting: bind rows")
#full_data <- bind_rows(mecovi_list) 
#full_vars <- bind_rows(mecovi_vars) 

#write.table(full_data, file="full_data_FACTOR.csv", sep=",", col.names=TRUE, row.names=FALSE, quote=TRUE, na="", fileEncoding="UTF-8")
#write.table(full_vars, file="full_vars.csv", sep=",", col.names=TRUE, row.names=FALSE, quote=TRUE, na="", fileEncoding="UTF-8")
mecovi_list

}