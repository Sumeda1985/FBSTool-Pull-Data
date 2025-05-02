library(data.table)
library(RSQLite)
library(readxl)
#function to read rds for data.table
fread_rds <- function(path) data.table::data.table(readRDS(path))

#FBS Tool directory 
basedir <- "E:/FBSTool_Test"

#SUA Balanced Data
# Database connection
con <- DBI::dbConnect(SQLite(), paste0(basedir,"/Data/Permanent.db"))
contbl <- dplyr::tbl(con, "dbcountry")


#In case to overwrite the database. database is the SUA Balanced 
database <- get(load("Data/countrySUA.RData"))
database[,StatusFlag :=  1 ]
database[,LastModified := as.numeric(Sys.time())]
dbWriteTable(con, name="dbcountry", value=database, append = TRUE)

data_tool_2000_2009 <- get(load("Data/countrySUA_2000_2009.RData"))
saveRDS(data_tool_2000_2009, file = paste0(basedir,"/Data/countrySUA_2000_2009.rds"))

#Commodity Tree
tree <- fread("Data/tree.csv")
tree[, c("geographicAreaM49", "timePointYears") := lapply(.SD, as.character), 
     .SDcols = c("geographicAreaM49", "timePointYears")]

if(file.exists(paste0(basedir,"/SUA-FBS Balancing/Data/tree.rds"))){
  file.remove(paste0(basedir,"/SUA-FBS Balancing/Data/tree.rds"))
  saveRDS(tree,paste0(basedir,"/SUA-FBS Balancing/Data/tree.rds"))
} else {
  saveRDS(tree,paste0(basedir,"/SUA-FBS Balancing/Data/tree.rds"))
}

##
processed_item_datatable <- fread("Data/processed_item_datatable.csv")
if(file.exists(paste0(basedir,"/SUA-FBS Balancing/Data/processed_item_datatable.rds"))){
  file.remove(paste0(basedir,"/SUA-FBS Balancing/Data/processed_item_datatable.rds"))
  saveRDS(processed_item_datatable,paste0(basedir,"/SUA-FBS Balancing/Data/processed_item_datatable.rds"))
}else {
  saveRDS(processed_item_datatable,paste0(basedir,"/SUA-FBS Balancing/Data/processed_item_datatable.rds"))
}

##
itemMap <- fread("Data/itemMap.csv")

if(file.exists(paste0(basedir,"/SUA-FBS Balancing/Data/itemMap.rds"))){
  file.remove(paste0(basedir,"/SUA-FBS Balancing/Data/itemMap.rds"))
  saveRDS(itemMap,paste0(basedir,"/SUA-FBS Balancing/Data/itemMap.rds"))
}else {
  saveRDS(itemMap,paste0(basedir,"/SUA-FBS Balancing/Data/itemMap.rds"))
  
}

##
coproduct_table <- fread("Data/zeroweight_coproducts.csv")

if(file.exists(paste0(basedir,"/SUA-FBS Balancing/Data/zeroweight_coproducts.rds"))){
  file.remove(paste0(basedir,"/SUA-FBS Balancing/Data/zeroweight_coproducts.rds"))
  saveRDS(coproduct_table,paste0(basedir,"/SUA-FBS Balancing/Data/zeroweight_coproducts.rds"))
} else {
  
  saveRDS(coproduct_table,paste0(basedir,"/SUA-FBS Balancing/Data/zeroweight_coproducts.rds"))
}

##

popSWS <- fread("Data/popSWS.csv")
popSWS[, c("geographicAreaM49", "timePointYears","measuredElement") := lapply(.SD, as.character), 
     .SDcols = c("geographicAreaM49", "timePointYears","measuredElement")]

stopifnot(nrow(popSWS) > 0)

if(file.exists(paste0(basedir,"/SUA-FBS Balancing/Data/popSWS.rds"))){
  file.remove(paste0(basedir,"/SUA-FBS Balancing/Data/popSWS.rds"))
  saveRDS(popSWS,paste0(basedir,"/SUA-FBS Balancing/Data/popSWS.rds"))
}else{
  
  saveRDS(popSWS,paste0(basedir,"/SUA-FBS Balancing/Data/popSWS.rds"))
}

##

Utilization_Table <- fread("Data/utilization_table_2018.csv")


if(file.exists(paste0(basedir,"/SUA-FBS Balancing/Data/utilization_table_2018.rds"))){
  file.remove(paste0(basedir,"/SUA-FBS Balancing/Data/utilization_table_2018.rds"))
  saveRDS(Utilization_Table,paste0(basedir,"/SUA-FBS Balancing/Data/utilization_table_2018.rds"))
} else{
  saveRDS(Utilization_Table,paste0(basedir,"/SUA-FBS Balancing/Data/utilization_table_2018.rds"))
}

##

zeroWeight <- fread("Data/zeroWeight.csv")


if(file.exists(paste0(basedir,"/SUA-FBS Balancing/Data/zeroWeight.rds"))){
  file.remove(paste0(basedir,"/SUA-FBS Balancing/Data/zeroWeight.rds"))
  saveRDS(zeroWeight,paste0(basedir,"/SUA-FBS Balancing/Data/zeroWeight.rds"))
} else{
  saveRDS(zeroWeight,paste0(basedir,"/SUA-FBS Balancing/Data/zeroWeight.rds"))
}

nutrientData <-  fread("Data/nutrientData.csv")
nutrientData[, c("geographicAreaM49", "timePointYearsSP","measuredElement") := lapply(.SD, as.character), 
       .SDcols = c("geographicAreaM49", "timePointYearsSP","measuredElement")]

if(file.exists(paste0(basedir,"/SUA-FBS Balancing/Data/nutrientData.rds"))){
  file.remove(paste0(basedir,"/SUA-FBS Balancing/Data/nutrientData.rds"))
  saveRDS(nutrientData,paste0(basedir,"/SUA-FBS Balancing/Data/nutrientData.rds"))
} else {
  saveRDS(nutrientData,paste0(basedir,"/SUA-FBS Balancing/Data/nutrientData.rds"))
  
}
##
fbsTree <- fread("Data/fbsTree.csv")
fbsTree[, c("id1", "id2","id3","id4") := lapply(.SD, as.character), 
             .SDcols = c("id1", "id2","id3","id4")]


if(file.exists(paste0(basedir,"/SUA-FBS Balancing/Data/fbsTree.rds"))){
  file.remove(paste0(basedir,"/SUA-FBS Balancing/Data/fbsTree.rds"))
  saveRDS(fbsTree,paste0(basedir,"/SUA-FBS Balancing/Data/fbsTree.rds"))
} else {
  saveRDS(fbsTree,paste0(basedir,"/SUA-FBS Balancing/Data/fbsTree.rds"))
}


shareUpDownTree <- fread("Data/ShareUpDownTree.csv")
shareUpDownTree[, c("geographicAreaM49", "timePointYears") := lapply(.SD, as.character), 
       .SDcols = c("geographicAreaM49", "timePointYears")]

if(file.exists(paste0(basedir,"/SUA-FBS Balancing/FBS_Balanced/Data/ShareUpDownTree.rds"))){
  file.remove(paste0(basedir,"/SUA-FBS Balancing/FBS_Balanced/Data/ShareUpDownTree.rds"))
  saveRDS(shareUpDownTree,paste0(basedir,"/SUA-FBS Balancing/FBS_Balanced/Data/ShareUpDownTree.rds"))
}else{
  saveRDS(shareUpDownTree,paste0(basedir,"/SUA-FBS Balancing/FBS_Balanced/Data/ShareUpDownTree.rds"))
}

fbs_standardized_wipe<- fread("Data/fbs_standardized_wipe.csv")
fbs_standardized_wipe[, c("geographicAreaM49", "measuredItemFbsSua","timePointYears") := lapply(.SD, as.character), 
                .SDcols = c("geographicAreaM49","measuredItemFbsSua", "timePointYears" )]
fbs_standardized_wipe[,Value := as.numeric(Value)]

if(file.exists(paste0(basedir,"/SUA-FBS Balancing/FBS_Balanced/Data/fbs_standardized_wipe.rds"))){
  file.remove(paste0(basedir,"/SUA-FBS Balancing/FBS_Balanced/Data/fbs_standardized_wipe.rds"))
  saveRDS(fbs_standardized_wipe,paste0(basedir,"/SUA-FBS Balancing/FBS_Balanced/Data/fbs_standardized_wipe.rds"))
}else{
  saveRDS(fbs_standardized_wipe,paste0(basedir,"/SUA-FBS Balancing/FBS_Balanced/Data/fbs_standardized_wipe.rds"))
}
##
fbs_balancedData <- fread("Data/fbs_balancedData_wipe.csv")

fbs_balancedData[, c("geographicAreaM49", "measuredElementSuaFbs","timePointYears") := lapply(.SD, as.character), 
                 .SDcols = c("geographicAreaM49","measuredElementSuaFbs", "timePointYears" )]
fbs_balancedData[,Value := as.numeric(Value)]

if(file.exists(paste0(basedir,"/SUA-FBS Balancing/FBS_Balanced/Data/fbs_balancedData_wipe.rds"))){
  file.remove(paste0(basedir,"/SUA-FBS Balancing/FBS_Balanced/Data/fbs_balancedData_wipe.rds"))
  saveRDS(fbs_balancedData,paste0(basedir,"/SUA-FBS Balancing/FBS_Balanced/Data/fbs_balancedData_wipe.rds"))
}else{
  
  saveRDS(fbs_balancedData,paste0(basedir,"/SUA-FBS Balancing/FBS_Balanced/Data/fbs_balancedData_wipe.rds"))
}

##

sua_bal_2010_2013 <- fread("Data/sua_bal_2010_2013.csv")


if(file.exists(paste0(basedir,"/SUA-FBS Balancing/Data/sua_bal_2010_2013.rds"))){
  file.remove(paste0(basedir,"/SUA-FBS Balancing/Data/sua_bal_2010_2013.rds"))
  saveRDS(sua_bal_2010_2013,paste0(basedir,"/SUA-FBS Balancing/Data/sua_bal_2010_2013.rds"))
}else{
  
  saveRDS(sua_bal_2010_2013,paste0(basedir,"/SUA-FBS Balancing/Data/sua_bal_2010_2013.rds"))
}

##
SuabalData <- fread("Data/SuabalData.csv")

if(file.exists(paste0(basedir,"/SUA-FBS Balancing/FBS_Balanced/Data/SuabalData.rds"))){
  file.remove(paste0(basedir,"/SUA-FBS Balancing/FBS_Balanced/Data/SuabalData.rds"))
  saveRDS(SuabalData,paste0(basedir,"/SUA-FBS Balancing/FBS_Balanced/Data/SuabalData.rds"))
}else{
  
  saveRDS(SuabalData,paste0(basedir,"/SUA-FBS Balancing/FBS_Balanced/Data/SuabalData.rds"))
}

##
parentNodes = fread("Data/parentNodes.csv")

if(file.exists(paste0(basedir,"/SUA-FBS Balancing/FBS_Balanced/Data/parentNodes.rds"))){
  file.remove(paste0(basedir,"/SUA-FBS Balancing/FBS_Balanced/Data/parentNodes.rds"))
  saveRDS(paste0(basedir,"/SUA-FBS Balancing/FBS_Balanced/Data/parentNodes.rds"))
}else{
  saveRDS(parentNodes,paste0(basedir,"/SUA-FBS Balancing/FBS_Balanced/Data/parentNodes.rds"))
  
}


##
fbs_standardized <- fread("Data/fbs_standardized_final.csv")
fbs_standardized[, c("geographicAreaM49", "measuredElementSuaFbs","timePointYears") := lapply(.SD, as.character), 
                 .SDcols = c("geographicAreaM49","measuredElementSuaFbs", "timePointYears" )]
saveRDS(fbs_standardized,paste0(basedir,"/SUA-FBS Balancing/FBS_Balanced/Data/fbs_standardized_final.rds"))
##
fbs_balanced_bis <- fread("Data/fbs_balanced_final.csv")
fbs_balanced_bis[, c("geographicAreaM49", "measuredElementSuaFbs","timePointYears") := lapply(.SD, as.character), 
                 .SDcols = c("geographicAreaM49","measuredElementSuaFbs", "timePointYears" )]

saveRDS(fbs_balanced_bis,paste0(basedir,"/SUA-FBS Balancing/FBS_Balanced/Data/fbs_balanced_final.rds"))

##
fbs_balancedData_2010_2013 <- fread("Data/fbs_balanced_2010_2013.csv")
fbs_balancedData_2010_2013[, c("geographicAreaM49", "measuredElementSuaFbs","timePointYears") := lapply(.SD, as.character), 
                 .SDcols = c("geographicAreaM49","measuredElementSuaFbs", "timePointYears" )]

saveRDS(fbs_balancedData_2010_2013,paste0(basedir,"/SUA-FBS Balancing/FBS_Balanced/Data/fbs_balanced_2010_2013.rds"))

paste0(basedir,"/Data/fdmData.rds")
##food domain
foodDemand <- fread("Data/fdmData.csv")
saveRDS(foodDemand,paste0(basedir,"/Data/fdmData.rds"))

food_classification <- fread("Data/foodCommodityList.csv")
saveRDS(food_classification, paste0(basedir,"/Data/foodCommodityList.rds"))


##trade data
tradeMap<- data.table(read_excel("Data/tradeMap_2019.xlsx"))
saveRDS(tradeMap,paste0(basedir,"/Data/tradeMap_2019.rds"))
