library(data.table)
library(DBI)
library(readxl)
library(RPostgres)
library(ssh)
## function to read rds for data.table
fread_rds <- function(path) data.table::data.table(readRDS(path))

#FBS Tool directory
basedir <- "E:/FBSTool_Test"

#SUA Balanced Data
# Database connection

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
                     options = "-c search_path=core")

#In case to overwrite the database. database is the SUA Balanced
database <- get(load("Data/countrySUA.RData"))
database[,c("Country", "Commodity", "Element") := NULL]
dbAppendTable(con, name="dbcountry", value=database)

data_tool_2000_2009 <- get(load("Data/countrySUA_2000_2009.RData"))
data_tool_2000_2009[,c("Country", "Commodity", "Element") := NULL]
dbAppendTable(concore, name="data_tool_2000_2009", value=data_tool_2000_2009)



#Commodity Tree
tree <- fread("Data/tree.csv")
tree[, c("geographicAreaM49", "timePointYears") := lapply(.SD, as.character),
     .SDcols = c("geographicAreaM49", "timePointYears")]
dbAppendTable(con, name="tree", value=tree)

##rocessed_item_datatable
processed_item_datatable <- fread("Data/processed_item_datatable.csv")
processed_item_datatable[, measured_item_cpc_description := NULL]
dbAppendTable(concore, name="processed_item_datatable",
              value=processed_item_datatable)


##
itemMap <- fread("Data/itemMap.csv")
itemMap[, language := "en"]
itemMap[, c("startDate", "endDate") := NULL]
dbAppendTable(concore, name="item_map", value=itemMap)
# itemMap <- dbReadTable(concore, name="item_map")

##
coproduct_table <- fread("Data/zeroweight_coproducts.csv")
coproduct_table <- coproduct_table[,.(measured_item_child_cpc, branch)]
dbAppendTable(concore, name="zeroweight_coproducts", value=coproduct_table)


#popultaion
popSWS <- fread("Data/popSWS.csv")
popSWS[, c("geographicAreaM49", "timePointYears","measuredElement") := lapply(.SD, as.character),
     .SDcols = c("geographicAreaM49", "timePointYears","measuredElement")]

dbAppendTable(con, name="pop_sws", value=popSWS)

##
Utilization_Table <- fread("Data/utilization_table_2018.csv")
Utilization_Table[, description := NULL]
dbAppendTable(concore, name="utilization_table", value=Utilization_Table)

##
zeroWeight <- fread("Data/zeroWeight.csv")
dbAppendTable(concore, name="zero_weight", value=zeroWeight)

#nutrient table
nutrientData <-  fread("Data/nutrientData.csv")
nutrientData[, c("geographicAreaM49", "timePointYearsSP","measuredElement") := lapply(.SD, as.character),
       .SDcols = c("geographicAreaM49", "timePointYearsSP","measuredElement")]
dbAppendTable(con, name="nutrient_data", value=nutrientData)


##
fbsTree <- fread("Data/fbsTree.csv")
fbsTree[, c("id1", "id2","id3","id4") := lapply(.SD, as.character),
             .SDcols = c("id1", "id2","id3","id4")]
dbAppendTable(concore, name="fbs_tree", value=fbsTree)


shareUpDownTree <- fread("Data/ShareUpDownTree.csv")
shareUpDownTree[, c("geographicAreaM49", "timePointYears") := lapply(.SD, as.character),
       .SDcols = c("geographicAreaM49", "timePointYears")]
dbAppendTable(concore, name="share_up_down_tree", value=shareUpDownTree)

fbs_standardized_wipe<- fread("Data/fbs_standardized_wipe.csv")
fbs_standardized_wipe[, c("geographicAreaM49", "measuredItemFbsSua","timePointYears") := lapply(.SD, as.character),
                .SDcols = c("geographicAreaM49","measuredItemFbsSua", "timePointYears" )]
fbs_standardized_wipe[,Value := as.numeric(Value)]
dbAppendTable(concore, name="fbs_standardized_wipe", value=fbs_standardized_wipe)


##
fbs_balancedData <- fread("Data/fbs_balancedData_wipe.csv")

fbs_balancedData[, c("geographicAreaM49", "measuredElementSuaFbs","timePointYears") := lapply(.SD, as.character),
                 .SDcols = c("geographicAreaM49","measuredElementSuaFbs", "timePointYears" )]
fbs_balancedData[,Value := as.numeric(Value)]
dbAppendTable(concore, name="fbs_balanced_wipe", value=fbs_balancedData)


##
parentNodes = fread("Data/parentNodes.csv")
dbAppendTable(concore, name="parent_nodes", value=parentNodes)



##food domain
foodDemand <- fread("Data/fdmData.csv")
foodDemand[,c("Commodity", "FBSCommodity") := NULL]
names(foodDemand)[names(foodDemand)=="Food Demand"] <- "Food_Demand"
names(foodDemand)[names(foodDemand)=="Food Function"] <- "Food_Function"
dbAppendTable(concore, name="food_demand", value=foodDemand)

## Food classification

food_classification <- fread("Data/foodCommodityList.csv")
food_classification[, Commodity := NULL]
dbAppendTable(con, name="food_classification", value=food_classification)

##gdp data

gdpData <- data.table(read_excel("Data/gdpData.xlsx"))
gdpData[, CountryM49 := as.character(unique(database$CountryM49))]
names(gdpData)[names(gdpData)=="GDP per capita [constant 2015 US$]"] <- "GDP_per_capita_usd_const_2015"
dbAppendTable(con, name="gdp_data", value=gdpData)


##trade data
tradeMap<- data.table(read_excel("Data/tradeMap_2019.xlsx"))
dbAppendTable(concore, name="trade_map", value=tradeMap)


#create ratios. Please run the function

sapply(list.files(pattern="[.]R$", path="R/", full.names=TRUE), source)

creatingRatio <- creatingRatio()


#fish

fish <- data.table(read_excel("Data/fish.xlsx"))
names(fish)[names(fish) == "Item Code (CPC)"] <- "CPCCode"
names(fish)[names(fish) == "Element Code"] <- "ElementCode"
dbAppendTable(con, name="fish", value=fish)

#tourist

TourismNoIndustrial <- fread_rds("Data/TourismNoIndustrial.rds")
dbAppendTable(concore, name="tourismnoindustrial", value=TourismNoIndustrial)

#flag

flagValidTable <- fread_rds("Data/flagValidTable.rds")
dbAppendTable(concore, name="flagvalidtable", value=flagValidTable)

#sua commo

SUA_Commodities <- fread_rds("Data/SUA_Commodities.rds")
SUA_Commodities[, language := "en"]
dbAppendTable(concore, name="sua_commodities", value=SUA_Commodities)

#elementMap

elementMap <- data.table(readRDS("Data/elementMap.rds"))
elementMap[, c("startDate", "endDate") := NULL]
dbAppendTable(concore, name="elementmap", value=elementMap)

##itemCodekey

## Needs to be fixed
itemCodeKey <- data.table(readRDS("Data/itemCodeKey.rds"))
itemCodeKey[, c("description", "factor") := NULL]
dbAppendTable(concore, name="itemcodekey", value=itemCodeKey)

#elemets for the outputs
elements <- data.table(readRDS("Data/elements.rds"))
elements[, language := "en"]
dbAppendTable(concore, name="elements", value=elements)
