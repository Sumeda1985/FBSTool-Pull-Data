library(faosws)
library(faoswsUtil)
library(faoswsBalancing)
library(faoswsStandardization)
library(dplyr)
library(data.table)
library(tidyr)
library(openxlsx)

options('repos' = c(CRAN = ifelse(getRversion() <= "3.3.3",

                "https://dev-sws-rcranrepo.s3-eu-west-1.amazonaws.com/", "https://cran.rstudio.com/")))

# The only parameter is the string to print
# COUNTRY is taken from environment (parameter)
dbg_print <- function(x) {
  print(paste0("NEWBAL (", COUNTRY, "): ", x))
}

basedir <-getwd()
sapply(list.files(pattern="[.]R$", path="SUA-FBS Balancing/R/", full.names=TRUE), source) # mainly for the new nutritative data
if (CheckDebug()) {
  SETTINGS <- faoswsModules::ReadSettings(file.path("sws.yml"))
  SetClientFiles(SETTINGS[["certdir"]])
  GetTestEnvironment(baseUrl = SETTINGS[["server"]], token = SETTINGS[["token"]])
  R_SWS_SHARE_PATH <- "//hqlprsws1.hq.un.fao.org/sws_r_share"
}
fread_rds <- function(path) data.table::data.table(readRDS(path))
tool_year <- as.character(2023)
COUNTRY <- as.character(swsContext.datasets[[1]]@dimensions$geographicAreaM49@keys)

COUNTRY_NAME <-
  nameData(
    "suafbs", "sua_unbalanced",
    data.table(geographicAreaM49 = COUNTRY))$geographicAreaM49_description

#fbs domain
sessionKey_fbsBal = swsContext.datasets[[1]]
#sessionKey_suaUnb = swsContext.datasets[[2]]
sessionKey_suabal = swsContext.datasets[[2]]
sessionKey_fbsStand = swsContext.datasets[[3]]
sessionCountries =
  getQueryKey("geographicAreaM49", sessionKey_fbsBal)
selectedGEOCode = sessionCountries
areaKeys = selectedGEOCode
#end fbs domain


dbg_print("parameters")

USER <- regmatches(
  swsContext.username,
  regexpr("(?<=/).+$", swsContext.username, perl = TRUE)
)

STOP_AFTER_DERIVED <- as.logical(swsContext.computationParams$stop_after_derived)

#FILL_EXTRACTION_RATES<-as.logical(swsContext.computationParams$fill_extraction_rates)
FILL_EXTRACTION_RATES <- TRUE

YEARS <- as.character(2000:tool_year)

p <- defaultStandardizationParameters()
p$itemVar <- "measuredItemSuaFbs"
p$mergeKey[p$mergeKey == "measuredItemCPC"] <- "measuredItemSuaFbs"
p$elementVar <- "measuredElementSuaFbs"
p$childVar <- "measuredItemChildCPC"
p$parentVar <- "measuredItemParentCPC"
p$createIntermetiateFile <- "TRUE"
p$protected <- "Protected"
p$official <- "Official"
sapply(dir("SUA-FBS Balancing/R", full.names = TRUE), source)


#####################################  TREE #################################
dbg_print("download tree")
tree <- getCommodityTreeNewMethod(COUNTRY, YEARS)
stopifnot(nrow(tree) > 0)
tree <- tree[geographicAreaM49 %chin% COUNTRY]
tree_exceptions <- tree[geographicAreaM49 == "392" & measuredItemParentCPC == "0141" & measuredItemChildCPC == "23995.01"]

if (nrow(tree_exceptions) > 0) {
  tree <- tree[!(geographicAreaM49 == "392" & measuredItemParentCPC == "0141" & measuredItemChildCPC == "23995.01")]
}
validateTree(tree)
if (nrow(tree_exceptions) > 0) {
  tree <- rbind(tree, tree_exceptions)
  rm(tree_exceptions)
}
## NA ExtractionRates are recorded in the sws dataset as 0
## for the standardization, we nee them to be treated as NA
## therefore here we are re-changing it

tree[Value == 0, Value := NA]
tree_to_send <- tree[is.na(Value) & measuredElementSuaFbs=="extractionRate"]

if (FILL_EXTRACTION_RATES == TRUE) {
  
  expanded_tree <-
    merge(
      data.table(
        geographicAreaM49 = unique(tree$geographicAreaM49),
        timePointYears = sort(unique(tree$timePointYears))
      ),
      unique(tree[, .(geographicAreaM49, measuredElementSuaFbs,
                      measuredItemParentCPC, measuredItemChildCPC)]),
      by = "geographicAreaM49",
      all = TRUE,
      allow.cartesian = TRUE
    )
  
  tree <- tree[expanded_tree, on = colnames(expanded_tree)]
  
  # flags for carry forward/backward
  tree[is.na(Value), c("flagObservationStatus", "flagMethod") := list("E", "t")]
  
  tree <-
    tree[!is.na(Value)][
      tree,
      on = c("geographicAreaM49", "measuredElementSuaFbs",
             "measuredItemParentCPC", "measuredItemChildCPC",
             "timePointYears"),
      roll = -Inf
      ]
  
  tree <-
    tree[!is.na(Value)][
      tree,
      on = c("geographicAreaM49", "measuredElementSuaFbs",
             "measuredItemParentCPC", "measuredItemChildCPC",
             "timePointYears"),
      roll = Inf
      ]
  
  # keep orig flags
  tree[, flagObservationStatus := i.i.flagObservationStatus]
  tree[, flagMethod := i.i.flagMethod]
  
  tree[, names(tree)[grep("^i\\.", names(tree))] := NULL]
}
tree_to_send <-
  tree_to_send %>% 
  dplyr::anti_join(tree[is.na(Value) & measuredElementSuaFbs == "extractionRate"], by = c("geographicAreaM49", "measuredElementSuaFbs", "measuredItemParentCPC", "measuredItemChildCPC", "timePointYears", "Value", "flagObservationStatus", "flagMethod")) %>%
  dplyr::select(-Value) %>%
  dplyr::left_join(tree, by = c("geographicAreaM49", "measuredElementSuaFbs", "measuredItemParentCPC", "measuredItemChildCPC", "timePointYears", "flagObservationStatus", "flagMethod")) %>%
  setDT()

tree_to_send <-
  tree_to_send[,
               .(geographicAreaM49, measuredElementSuaFbs, measuredItemParentCPC,
                 measuredItemChildCPC, timePointYears, Value, flagObservationStatus, flagMethod)]

setnames(
  tree_to_send,
  c("measuredItemParentCPC", "measuredItemChildCPC"),
  c("measuredItemParentCPC_tree", "measuredItemChildCPC_tree")
)

tree_to_send <-
  nameData("suafbs", "ess_fbs_commodity_tree2", tree_to_send, except = c('measuredElementSuaFbs', 'timePointYears'))

tree_to_send[,
             `:=`(
               measuredItemParentCPC_tree = paste0("'", measuredItemParentCPC_tree),
               measuredItemChildCPC_tree = paste0("'", measuredItemChildCPC_tree))
             ]

tmp_file_name_extr <- tempfile(pattern = paste0("FILLED_ER_", COUNTRY, "_"), fileext = '.csv')
# XXX remove NAs
# tree <- tree[!is.na(Value)]   #this option is disabled when it reads for the first time to the tool.
#In this way we do not lose the connection. It happened in cuba. flour with bread connection has been
#removed. 
tree[is.na(Value), Value := 0]   #in this way you retain all possible connections
if(file.exists(paste0(basedir,"/Data/tree.csv"))){
  file.remove(paste0(basedir,"/Data/tree.csv"))
  write.csv(tree,paste0(basedir,"/Data/tree.csv"), row.names =FALSE)
} else {
  write.csv(tree, paste0(basedir,"/Data/tree.csv"), row.names =FALSE)
}
# XXX Check if this one is still good or it can be obtained within the dataset
processed_item_datatable <- ReadDatatable("processed_item")

if(file.exists(paste0(basedir,"/Data/processed_item_datatable.csv"))){
  file.remove(paste0(basedir,"/Data/processed_item_datatable.csv"))
  write.csv(processed_item_datatable,paste0(basedir,"/Data/processed_item_datatable.csv"),row.names = FALSE)
}else {
  write.csv(processed_item_datatable,paste0(basedir,"/Data/processed_item_datatable.csv"),row.names = FALSE)
}

# XXX what is this for?
itemMap <- GetCodeList(domain = "agriculture", dataset = "aproduction", "measuredItemCPC")

if(file.exists(paste0(basedir,"/Data/itemMap.csv"))){
  file.remove(paste0(basedir,"/SUA-FBS Balancing/Data/itemMap.csv"))
  write.csv(itemMap,paste0(basedir,"/Data/itemMap.csv"),row.names = FALSE)
}else {
  write.csv(itemMap,paste0(basedir,"/Data/itemMap.csv"),row.names = FALSE)
}


##################################### / TREE ################################
coproduct_table <- ReadDatatable('zeroweight_coproducts')

if(file.exists(paste0(basedir,"/Data/zeroweight_coproducts.csv"))){
  file.remove(paste0(basedir,"/SUA-FBS Balancing/Data/zeroweight_coproducts.csv"))
  write.csv(coproduct_table,paste0(basedir,"/Data/zeroweight_coproducts.csv"),row.names = FALSE)
} else {
  write.csv(coproduct_table,paste0(basedir,"/Data/zeroweight_coproducts.csv"),row.names = FALSE)
}

############################ POPULATION #####################################

key <-
  DatasetKey(
    domain = "population",
    dataset = "population_unpd",
    dimensions =
      list(
        geographicAreaM49 = Dimension(name = "geographicAreaM49", keys = COUNTRY),
        measuredElementSuaFbs = Dimension(name = "measuredElement", keys = "511"), # 511 = Total population
        timePointYears = Dimension(name = "timePointYears", keys = as.character(2000:tool_year))
      )
  )

dbg_print("download population")
popSWS <- GetData(key)
stopifnot(nrow(popSWS) > 0)

if(file.exists(paste0(basedir,"/Data/popSWS.csv"))){
  file.remove(paste0(basedir,"/Data/popSWS.csv"))
  write.csv(popSWS,paste0(basedir,"/Data/popSWS.csv"),row.names = FALSE)
}else{
   write.csv(popSWS,paste0(basedir,"/Data/popSWS.csv"),row.names = FALSE)
}
popSWS[geographicAreaM49 == "156", geographicAreaM49 := "1248"]
############################ / POPULATION ##################################
# 5510 Production[t]
# 5610 Import Quantity [t]
# 5071 Stock Variation [t]
# 5023 Export Quantity [t]
# 5910 Loss [t]
# 5016 Industrial uses [t]
# 5165 Feed [t]
# 5520 Seed [t]
# 5525 Tourist Consumption [t]
# 5164 Residual other uses [t]
# 5141 Food [t]
# 664 Food Supply (/capita/day) [Kcal]

elemKeys <- c("5510", "5610", "5071", "5113", "5910", "5016", 
              "5165", "5520", "5525", "5164", "5141") #residual and processing will be removed.

itemKeys <- GetCodeList(domain = "suafbs", dataset = "sua_unbalanced", "measuredItemFbsSua")
itemKeys <- itemKeys$code

Utilization_Table <- ReadDatatable("utilization_table_2018")


if(file.exists(paste0(basedir,"/Data/utilization_table_2018.csv"))){
  file.remove(paste0(basedir,"/Data/utilization_table_2018.csv"))
  write.csv(Utilization_Table,paste0(basedir,"/Data/utilization_table_2018.csv"),row.names = FALSE)
} else{
  write.csv(Utilization_Table,paste0(basedir,"/Data/utilization_table_2018.csv"),row.names = FALSE)
}

zeroWeight <- ReadDatatable("zero_weight")[, item_code]


if(file.exists(paste0(basedir,"/Data/zeroWeight.csv"))){
  file.remove(paste0(basedir,"/Data/zeroWeight.csv"))
  write.csv(zeroWeight,paste0(basedir,"/Data/zeroWeight.csv"),row.names = FALSE)
} else{
  write.csv(zeroWeight,paste0(basedir,"/Data/zeroWeight.csv"),row.names = FALSE)
  
}
nutrientCodes = c("1061","1062","1063","1064", "1066", "1067", "1068","1070","1071","1072","1073",
                  "1074","1075","1076","1078","1079","1080","1081","1083","1084","1087","1089")
nutrientData <-
  getNutritiveFactors_ESN(
    nutrientDomain = "suafbs",
    nutrientDataset = "global_nct",
    measuredElement = nutrientCodes,
    timePointYearsSP = as.character(2014:tool_year),
    geographicAreaM49 = COUNTRY )

nutrientData[measuredElement=="1066",measuredElement:="664"]
nutrientData[measuredElement=="1079",measuredElement:="674"]
nutrientData[measuredElement=="1067",measuredElement:="684"]
if(file.exists(paste0(basedir,"/SUA-FBS Balancing/Data/nutrientData.csv"))){
  file.remove(paste0(basedir,"/SUA-FBS Balancing/Data/nutrientData.csv"))
  write.csv(nutrientData,"SUA-FBS Balancing/Data/nutrientData.csv",row.names = FALSE)
} else {
  write.csv(nutrientData,"SUA-FBS Balancing/Data/nutrientData.csv",row.names = FALSE)
}
# we have decided to pre-fill the tool with 2000-2009 sua unbalanced data and 2010 onwards with sua balanced data

if (CheckDebug()) {
  key <-
    DatasetKey(
      domain = "suafbs",
      dataset = "sua_unbalanced",
      dimensions =
        list(
          geographicAreaM49 = Dimension(name = "geographicAreaM49", keys = COUNTRY),
          measuredElementSuaFbs = Dimension(name = "measuredElementSuaFbs", keys = elemKeys),
          measuredItemFbsSua = Dimension(name = "measuredItemFbsSua", keys = itemKeys),
          timePointYears = Dimension(name = "timePointYears", keys = as.character(2000:2009))
        )
    )
} else {
  key <- swsContext.datasets[[2]]
  
  key@dimensions$timePointYears@keys <- YEARS
  key@dimensions$measuredItemFbsSua@keys <- itemKeys
  key@dimensions$measuredElementSuaFbs@keys <- elemKeys
  key@dimensions$geographicAreaM49@keys <- COUNTRY
}
dbg_print("download data")
data <- GetData(key)
# from 2010 to the "tool_year" , the data will be extracted from SUA_Balanced. (decided after the discussion with Giualia on 16/12/2021)
itemKeys_sua_balanced = GetCodeList(domain = "suafbs", dataset = "sua_balanced", "measuredItemFbsSua")
itemKeys_sua_balanced = itemKeys_sua_balanced[, code]
key_sua_balanced = DatasetKey(domain = "suafbs", dataset = "sua_balanced", dimensions = list(
  geographicAreaM49 = Dimension(name = "geographicAreaM49", keys = COUNTRY),
  measuredElementSuaFbs = Dimension(name = "measuredElementSuaFbs", keys = elemKeys),
  measuredItemFbsSua = Dimension(name = "measuredItemFbsSua", keys = itemKeys),
  timePointYears = Dimension(name = "timePointYears", keys = as.character(c(2010:tool_year)))))

sua_balanced_data <- GetData(key_sua_balanced)
data <- rbind(data,sua_balanced_data)
data_tool <- copy(data)
#Industrial (E,e) is not protected in SWS. So, "I" flag is assigned to (E,e) of Industrial for 2014 onwards. 

data_tool[timePointYears %in% c(2014:tool_year) & measuredElementSuaFbs == "5165" & flagObservationStatus  == "E"
          & flagMethod == "e", flagObservationStatus := "I"]

# 09/02/2021 - After discussing with Rachele (due to an issue arose for Benin) , we have deiced to use "I" for (E,u) combination
# for stock Variation. 
data_tool[timePointYears %in% c(2014:tool_year) & measuredElementSuaFbs == "5071" & flagObservationStatus  == "E"
          & flagMethod == "u", flagObservationStatus := "I"]
#01/06/2021 During the workshop of Malawi, it is suggested by Rachele to unprotect E,f flags for Utilization variables. 
data_tool[timePointYears %in% c(2014:tool_year) & measuredElementSuaFbs %in% c("5071","5016","5165","5520","5525","5141","5164")
          & flagObservationStatus  == "E"
          & flagMethod == "f", flagObservationStatus := "I"]
data_tool[, flagMethod := NULL]
data[, flagMethod := NULL]
#check for elements for all years
data_tool_element <- unique(data_tool[,c("measuredElementSuaFbs", "timePointYears"),with=F])
if (unique(! unique(data_tool_element$timePointYears) %in% c(2000: tool_year))){
  warning("Years are missing for some elements")
}
data_tool <- nameData("suafbs","sua_unbalanced", data_tool,except = "timePointYears")
setnames(data_tool,c("geographicAreaM49","geographicAreaM49_description","measuredElementSuaFbs","measuredElementSuaFbs_description","measuredItemFbsSua","measuredItemFbsSua_description",
                     "timePointYears","Value","flagObservationStatus"),
         c("CountryM49","Country","ElementCode","Element","CPCCode","Commodity","Year","Value","Flag"))
setcolorder(data_tool, c("CountryM49","Country","CPCCode","Commodity","ElementCode","Element","Year","Value", "Flag"))
data_tool_2000_2009 <- data_tool[Year %in% c(2000:2009)] #data 2000-2009
#data 2010 - tool_year
###################################################### Agriculture Data

agrielemkeys=c("5315" ,"5318", "5319", "5320" ,"5314" ,"5327", "5313", "5321", "5417" ,"5422" ,"5423", "5424" ,"5111"  ,"5519" ,
               "5312" , "5421", "5025")
itemKeysAgri = GetCodeList(domain = "agriculture", dataset = "aproduction", "measuredItemCPC")
itemKeysAgri = itemKeysAgri[, code]
keyAgriculture = DatasetKey(domain = "agriculture", dataset = "aproduction", dimensions = list(
  geographicAreaM49 = Dimension(name = "geographicAreaM49", keys = COUNTRY),
  measuredElementSuaFbs = Dimension(name = "measuredElement", keys = agrielemkeys),
  measuredItemFbsSua = Dimension(name = "measuredItemCPC", keys = itemKeysAgri),
  timePointYears = Dimension(name = "timePointYears", keys = as.character(c(2010:tool_year)))
))
agricultureData=GetData(keyAgriculture)
agricultureData[,flagMethod := NULL]
agricultureData <- nameData("agriculture","aproduction", agricultureData,except = "timePointYears")
setnames(agricultureData,c("geographicAreaM49","geographicAreaM49_description","measuredElement","measuredElement_description",
                           "measuredItemCPC","measuredItemCPC_description",
                     "timePointYears","Value","flagObservationStatus"),
         c("CountryM49","Country","ElementCode","Element","CPCCode","Commodity","Year","Value","Flag"))

###########################################################

data_tool <- rbind(data_tool,agricultureData)
data_tool_2010 <- data_tool[Year %in% c(2010:tool_year)]
#####################################################################

save(data_tool_2000_2009, file = "Data/countrySUA_2000_2009.RData")

########before saving make sure loss values exist only for the primary commodities

primary_commodities <- unique(Utilization_Table[primary_item == "X"]$cpc_code)

data_tool_2010 <- data_tool_2010[!(ElementCode == "5016" & !CPCCode %in% primary_commodities)]

###before saving make sure that industrial use is not created for Rice milled

data_tool_2010 <- data_tool_2010[!(ElementCode == "5165" & CPCCode %in% "23161.02")]
save(data_tool_2010, file = "Data/countrySUA.RData")
#################### FODDER CROPS ##########################################
fbsTree <- ReadDatatable("fbs_tree")

if(file.exists(paste0(basedir,"/Data/fbsTree.csv"))){
  file.remove(paste0(basedir,"/Data/fbsTree.csv"))
  write.csv(fbsTree,paste0(basedir,"/Data/fbsTree.csv"),row.names = FALSE)
} else {
  write.csv(fbsTree,paste0(basedir,"/Data/fbsTree.csv"),row.names = FALSE)
  
}


