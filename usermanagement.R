library(password)
library(sodium)
library(data.table)

apppath<-file.path("~/fao2025","FBSTool_Test")
adminpath<-file.path("~/fao2025","FBSTool-Pull-Data")

## These commands were used for creating a secret key  and a public key.
## The public key will reside in the shiny app.
## The secret key will reside in this app.

## key <- sig_keygen()
## pubkey <- sig_pubkey(key)
## saveRDS(key, file="secret.rds")
## saveRDS(pubkey, file="publickey.rds")

## These commands were used to create an empty authentication file.
## They can be used again to remove access to all existing users.

userauth <- data.table(user=character(), country=character(),
                       authkey=character(),
                       status=numeric())
newuser <- data.table(user="Vikas.Rawal@fao.org", country="Lesotho",
                              authkey=enc2utf8(rawToChar(sig)), status=1)
userauth <- rbind(userauth, newuser)
saveRDS(userauth, file.path(apppath,"userauth.rds"))

## key <- readRDS("secret.rds")
pubkey <- readRDS(file.path(apppath,"publickey.rds"))

#' Add fbs user
#'
#' @description
#' This function is used for adding fbs users
#'
#' @param useremail Email address of the user to be added. The user should use this on shinyapps.io
#' @param usercountry Name of the country whose FBS the user should have access to.
#' @import password
#' @import sodium
#' @import data.table
#' @return The authentication key to be sent to the user
#' @export
addfbsuser <- function(useremail, usercountry) {
    userauth <- readRDS(file.path(apppath,"userauth.rds"))
    if (nrow(userauth[user==useremail & country==usercountry & status == 1]) == 0) {
        key <- readRDS(file.path(adminpath,"secret.rds"))
        pw <- password::password(n = 15, numbers = TRUE, case = TRUE,
                                 special = c("?", "!", "&", "%", "$"))
        sig <- sodium::sig_sign(charToRaw(pw), key)
        newuser <- data.table(user=useremail, country=usercountry,
                              authkey=enc2utf8(rawToChar(sig)),
                              status=1)
        userauth <- rbind(userauth, newuser)
        saveRDS(userauth, file.path(apppath, "userauth.rds"))
        print(paste0("Added user. Please send this authentication key to ", useremail, ": ", pw))
    } else {
        print(paste0(useremail, " already has access to ", usercountry, " data"))
    }
}

delfbsuser <- function(useremail, usercountry) {
    userauth <- readRDS(file.path(apppath,"userauth.rds"))
    if (nrow(userauth[user==useremail & country==usercountry]) > 0) {
        userauth <- userauth[!(user==useremail & country==usercountry)]
        saveRDS(userauth, file.path(apppath, "userauth.rds"))
        print(paste0("Removed access of ", useremail, " to ", usercountry, " data"))
    } else {
        print(paste0(useremail, " does not have access to ", usercountry, " data"))
    }
}

disablefbsuser <- function(useremail, usercountry) {
    userauth <- readRDS(file.path(apppath,"userauth.rds"))
    if (nrow(userauth[user==useremail & country==usercountry & status == 1]) > 0) {
        userauth[user==useremail & country==usercountry, status := 0]
        saveRDS(userauth, file.path(apppath, "userauth.rds"))
        print(paste0("Disabled access of ", useremail, " to ", usercountry, " data"))
    } else {
        print(paste0(useremail, " does not have access to ", usercountry, " data"))
    }
}

enablefbsuser <- function(useremail, usercountry) {
    userauth <- readRDS(file.path(apppath,"userauth.rds"))
    if (nrow(userauth[user==useremail & country==usercountry]) > 0) {
        if (nrow(userauth[user==useremail & country==usercountry & status == 0]) > 0) {
            userauth[user==useremail & country==usercountry, status := 1]
            saveRDS(userauth, file.path(apppath, "userauth.rds"))
            print(paste0(useremail, " can now access ", usercountry, " data using previously provided key. If the user does not have authentication key, you need to delete the user and create it again."))
        } else {
        print(paste0(useremail, " already has access to ", usercountry, " data")) }
    } else {
        print(paste0(useremail, " has not been provided access to ", usercountry,
                     " data. Please use addfbsuser function to add user and provide access"))
    }
}

#3 addfbsuser("Vikas.Rawal@fao.org", "Lesotho")
## delfbsuser("Vikas.Rawal@fao.org", "Lesotho")
## disablefbsuser("Vikas.Rawal@fao.org", "Lesotho")
## enablefbsuser("Vikas.Rawal@fao.org", "Lesotho")

## addfbsuser("Vikas.Rawal@fao.org", "South Sudan")

## The part below needs to be moved to the shiny app.
userauth <- readRDS(file.path(apppath,"userauth.rds"))[status==1]
pubkey <- readRDS(file.path(apppath,"publickey.rds"))
for (i in userauth[user=="Vikas.Rawal@fao.org", authkey]) {
    print(i)
    if(tryCatch({sig_verify(charToRaw("0oRRq7$iBt16jev"), charToRaw(userauth$authkey[1]),
                     pubkey)},
                error=function(e){
                    FALSE
                }) == TRUE) {
        selectcountry <- userauth[user=="Vikas.Rawal@fao.org" & authkey == i,
                                  country]
        print(selectcountry)
    } else {
        print("Does not match")
    }
}

userauth <- readRDS(file.path(apppath,"userauth.rds"))[status==1]
