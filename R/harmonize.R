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
  
    # remove .csv from the file name
    fname = str_sub(files[i],1,-5) 

    print(paste0("Reading: ",fname))
    
    #Read dta  
    db <-read.dta(paste0("./data/",files[i]), convert.factors=factor)
    
    #Create dataset of variables
    #dbVars <- as.data.frame(colnames(db))
    #colnames(dbVars)<- c("var")
    
    # Find names of missing columns
    missing <- setdiff(vars$x, names(db))
    
    print(paste0("# missing columns: ",length(missing)))
    
    db[missing] <- NA
    
    db$techo_ch <- factor(db$techo_ch)
    db$tipopen_ci <-factor(db$tipopen_ci)
    db$instcot_ci<-factor(db$instcot_ci)
    db$jefe_ci<-factor(db$jefe_ci)
    db$pqnoasis_ci<-factor(db$pqnoasis_ci)
    db$region_c<-factor(db$region_c)
    db$edupub_ci<-factor(db$edupub_ci)
    db$bano_ch<-factor(db$bano_ch)
    db$aguamide_ch<-factor(db$aguamide_ch)
    db$combust_ch<-factor(db$combust_ch)
    db$luzmide_ch<-factor(db$luzmide_ch)
    db$raza_idioma_ci<-factor(db$raza_idioma_ci)
    db$resid_ch<-factor(db$resid_ch)
    db$viviprop_ch<-factor(db$viviprop_ch)
    db$pared_ch<-as.character(db$pared_ch)
    db$piso_ch<-as.character(db$piso_ch)
    db$raza_ci<-as.character(db$raza_ci)
    
    db<-db[,t(vars)]
    
    # creates a variable with the file name
    db$survey = rep(fname, nrow(db)) 
    #dbVars$survey=rep(fname, nrow(dbVars)) 
  
  
    mecovi_list[[i]] = db  
    #mecovi_vars[[i]] = dbVars  
    
    #if(i==1){
     # write.csv(db, file="full_data_FACTOR.csv", sep=",", col.names=TRUE, append=FALSE, row.names=FALSE, quote=TRUE, na="", fileEncoding="UTF-8")
    #}
  #  else {
   #   write.csv(db, file="full_data_FACTOR.csv", sep=",", col.names=FALSE, append=TRUE, row.names=FALSE, quote=TRUE, na="", fileEncoding="UTF-8")  
    # } 
    
  }

mecovi_list
#print("Starting: bind rows")
#full_data <- bind_rows(mecovi_list) 
#full_vars <- bind_rows(mecovi_vars) 

#write.table(full_data, file="full_data_FACTOR.csv", sep=",", col.names=TRUE, row.names=FALSE, quote=TRUE, na="", fileEncoding="UTF-8")
#write.table(full_vars, file="full_vars.csv", sep=",", col.names=TRUE, row.names=FALSE, quote=TRUE, na="", fileEncoding="UTF-8")
#full_data

}


check_metadata <- function(mecovi_list)
{
  metadata <- list()
  for(i in 1:length(mecovi_list)){
    meta=as.data.frame(sapply(mecovi_list[[i]], class))
    colnames(meta)=c(paste0("type",i))
    meta <- add_rownames(meta, "col")
    meta <- meta[order(meta$col),] 
    
    metadata[[i]]=meta
  }
  metadata
}

join_meta<-function(meta_list)
{
  meta<-''
  for(i in 1:length(meta_list)){
    if (i== 1){
      meta=meta_list[[i]]
    } 
    else
    {
      meta<-inner_join(meta,meta_list[[i]],by="col")
      #meta<-merge(meta, meta_list[[i]], by=c("col")) # NA's match
      
    }
  }
  meta
  
}
#http://stackoverflow.com/questions/2851015/convert-data-frame-columns-from-factors-to-characters/2853231#2853231

as_character_df<-function(mecovi_list)
{
  for(i in 1:length(mecovi_list)){
    db<-mecovi_list[[i]]
    x <- sapply(db, is.factor)
    db[x] <- lapply(db[x], as.character)
    mecovi_list[[i]] <-db
  }
  mecovi_list
}

printDF<-function(mecovi_list)
{
  for(i in 1:3){
    if(i==1){
      write.table(mecovi_list[[i]], file="full_data_FACTOR.csv", sep=",", col.names=TRUE, append=FALSE, row.names=FALSE, quote=TRUE, na="", fileEncoding="UTF-8")
    }
    else {
      write.table(mecovi_list[[i]], file="full_data_FACTOR.csv", sep=",", col.names=FALSE, append=TRUE, row.names=FALSE, quote=TRUE, na="", fileEncoding="UTF-8")  
    } 
  }
  
}