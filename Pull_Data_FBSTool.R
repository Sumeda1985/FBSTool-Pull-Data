library(data.table)
library(DBI)
library(RSQLite)
library(readxl)
library(RPostgres)
library(ssh)
## function to read rds for data.table
fread_rds <- function(path) data.table::data.table(readRDS(path))

#FBS Tool directory
basedir <- "E:/FBSTool_Test"

#SUA Balanced Data
# Database connection

production <- TRUE

if (production == TRUE) {
cmd <- 'ssh::ssh_tunnel(ssh::ssh_connect(host = "vikasguest@badal.sser.in:22", passwd="ERpWPM0JhN"), port = 5555, target = "127.0.0.1:5432")'
pid <- sys::r_background(
    std_out = FALSE,
    std_err = FALSE,
    args = c("-e", cmd)
)


con <- dbConnect(RPostgres::Postgres(), dbname = "suafbsdb",
                 host = '127.0.0.1',
                 port = 5555,
                 user = 'suafbsdbuser',
                 pass = 'xeoEJ7UOxiQQ') #for public data (user is able to change data)

cmd2 <- 'ssh::ssh_tunnel(ssh::ssh_connect(host = "vikasguest@badal.sser.in:22", passwd="ERpWPM0JhN"), port = 5554, target = "127.0.0.1:5432")'
pid2 <- sys::r_background(
    std_out = FALSE,
    std_err = FALSE,
    args = c("-e", cmd2)
)

concore <- dbConnect(RPostgres::Postgres(), dbname = "suafbsdb",
                         host = '127.0.0.1',
                         port = 5554,
                         user = 'suafbsdbuser',
                         pass = 'xeoEJ7UOxiQQ',
                         options = "-c search_path=core") #static data. User is not able to change data.
    ## contbl <- dplyr::tbl(con, "dbcountry")
} else {
    con <- DBI::dbConnect(SQLite(), paste0(basedir,"/Data/Permanent.db"))
    contbl <- dplyr::tbl(con, "dbcountry")
}

#In case to overwrite the database. database is the SUA Balanced
database <- get(load("Data/countrySUA.RData"))
database[,StatusFlag :=  1 ]
database[,LastModified := as.numeric(Sys.time())]
dbWriteTable(con, name="dbcountry", value=database, overwrite = TRUE)

data_tool_2000_2009 <- get(load("Data/countrySUA_2000_2009.RData"))
dbWriteTable(concore, name="data_tool_2000_2009", value=data_tool_2000_2009, overwrite = TRUE)



#Commodity Tree
tree <- fread("Data/tree.csv")
tree[, c("geographicAreaM49", "timePointYears") := lapply(.SD, as.character),
     .SDcols = c("geographicAreaM49", "timePointYears")]
tree[,StatusFlag :=  1 ]
tree[,LastModified := as.numeric(Sys.time())]
dbWriteTable(con, name="tree", value=tree, overwrite = TRUE)#editable by the user. Hence connection is con

##
processed_item_datatable <- fread("Data/processed_item_datatable.csv")
dbWriteTable(concore, name="processed_item_datatable",
             value=processed_item_datatable,
             overwrite = TRUE)


##
itemMap <- fread("Data/itemMap.csv")
dbWriteTable(concore, name="item_map", value=itemMap,
             overwrite = TRUE)
# itemMap <- dbReadTable(concore, name="item_map")

##
coproduct_table <- fread("Data/zeroweight_coproducts.csv")
dbWriteTable(concore, name="zeroweight_coproducts", value=coproduct_table,
             overwrite = TRUE)


#popultaion
popSWS <- fread("Data/popSWS.csv")
popSWS[, c("geographicAreaM49", "timePointYears","measuredElement") := lapply(.SD, as.character),
     .SDcols = c("geographicAreaM49", "timePointYears","measuredElement")]

stopifnot(nrow(popSWS) > 0)
popSWS[,StatusFlag :=  1 ]
popSWS[,LastModified := as.numeric(Sys.time())]

dbWriteTable(con, name="pop_sws", value=popSWS,overwrite = TRUE)


##
Utilization_Table <- fread("Data/utilization_table_2018.csv")
dbWriteTable(concore, name="utilization_table", value=Utilization_Table,
             overwrite = TRUE)



##

zeroWeight <- fread("Data/zeroWeight.csv")
dbWriteTable(concore, name="zero_weight", value=zeroWeight,
             overwrite = TRUE)

#nutrient table 
nutrientData <-  fread("Data/nutrientData.csv")
nutrientData[, c("geographicAreaM49", "timePointYearsSP","measuredElement") := lapply(.SD, as.character),
       .SDcols = c("geographicAreaM49", "timePointYearsSP","measuredElement")]
nutrientData[,StatusFlag :=  1 ]
nutrientData[,LastModified := as.numeric(Sys.time())]
dbWriteTable(con, name="nutrient_data", value=nutrientData,
             overwrite = TRUE)


##
fbsTree <- fread("Data/fbsTree.csv")
fbsTree[, c("id1", "id2","id3","id4") := lapply(.SD, as.character),
             .SDcols = c("id1", "id2","id3","id4")]

dbWriteTable(concore, name="fbs_tree", value=fbsTree,
             overwrite = TRUE)


shareUpDownTree <- fread("Data/ShareUpDownTree.csv")
shareUpDownTree[, c("geographicAreaM49", "timePointYears") := lapply(.SD, as.character),
       .SDcols = c("geographicAreaM49", "timePointYears")]
dbWriteTable(concore, name="share_up_down_tree", value=shareUpDownTree,
             overwrite = TRUE)

fbs_standardized_wipe<- fread("Data/fbs_standardized_wipe.csv")
fbs_standardized_wipe[, c("geographicAreaM49", "measuredItemFbsSua","timePointYears") := lapply(.SD, as.character),
                .SDcols = c("geographicAreaM49","measuredItemFbsSua", "timePointYears" )]
fbs_standardized_wipe[,Value := as.numeric(Value)]
dbWriteTable(concore, name="fbs_standardized_wipe", value=fbs_standardized_wipe,
             overwrite = TRUE)


##
fbs_balancedData <- fread("Data/fbs_balancedData_wipe.csv")

fbs_balancedData[, c("geographicAreaM49", "measuredElementSuaFbs","timePointYears") := lapply(.SD, as.character),
                 .SDcols = c("geographicAreaM49","measuredElementSuaFbs", "timePointYears" )]
fbs_balancedData[,Value := as.numeric(Value)]
dbWriteTable(concore, name="fbs_balanced_wipe", value=fbs_balancedData,
             overwrite = TRUE)


##
parentNodes = fread("Data/parentNodes.csv")
dbWriteTable(concore, name="parent_nodes", value=parentNodes,
             overwrite = TRUE)



##food domain
foodDemand <- fread("Data/fdmData.csv")
dbWriteTable(concore, name="food_demand", value=foodDemand,
             overwrite = TRUE)

## Food classification

food_classification <- fread("Data/foodCommodityList.csv")
food_classification[,StatusFlag :=  1 ]
food_classification[,LastModified := as.numeric(Sys.time())]
dbWriteTable(con, name="food_classification", value=food_classification,
             overwrite = TRUE)

##gdp data

gdpData <- data.table(read_excel("Data/gdpData.xlsx"))
gdpData[, `:=`(
  StatusFlag = 1,
  LastModified = as.numeric(Sys.time()),
  CountryM49 = as.character(unique(database$CountryM49)),
  Country = as.character(unique(database$Country))
)]
dbWriteTable(con, name="gdpData", value=gdpData,
             overwrite = TRUE)


##trade data
tradeMap<- data.table(read_excel("Data/tradeMap_2019.xlsx"))
dbWriteTable(concore, name="trade_map", value=tradeMap,
             overwrite = TRUE)


#create ratios. Please run the function

sapply(list.files(pattern="[.]R$", path="R/", full.names=TRUE), source)

creatingRatio <- creatingRatio()


#fish 

fish <- data.table(read_excel("Data/fish.xlsx"))
fish[,StatusFlag :=  1 ]
fish[,LastModified := as.numeric(Sys.time())]
dbWriteTable(con, name="fish", value=fish,
             overwrite = TRUE)

#tourist

TourismNoIndustrial <- fread_rds("Data/TourismNoIndustrial.rds")
dbWriteTable(concore, name="TourismNoIndustrial", value=TourismNoIndustrial,
             overwrite = TRUE)

#flag

flagValidTable <- fread_rds("Data/flagValidTable.rds")
dbWriteTable(concore, name="flagValidTable", value=flagValidTable,
             overwrite = TRUE)

#sua commo

SUA_Commodities <- fread_rds("Data/SUA_Commodities.rds") 
dbWriteTable(concore, name="SUA_Commodities", value=SUA_Commodities,
             overwrite = TRUE)

#elementMap

elementMap <- data.table(readRDS("Data/elementMap.rds"))
dbWriteTable(concore, name="elementMap", value=elementMap,
             overwrite = TRUE)
#itemCodekey

itemCodeKey <- data.table(readRDS("Data/itemCodeKey.rds"))
dbWriteTable(concore, name="itemCodeKey", value=itemCodeKey,
             overwrite = TRUE)

#elemets for the outputs
elements <- data.table(readRDS("Data/elements.rds"))
dbWriteTable(concore, name="elements", value=elements,
             overwrite = TRUE)
