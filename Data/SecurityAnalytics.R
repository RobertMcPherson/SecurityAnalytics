### R code from vignette source 'SecurityAnalytics.rnw'
### Encoding: UTF-8

###################################################
### code chunk number 1: SecurityAnalytics.rnw:50-60
###################################################
#Remove any objects from the environment before starting
rm(list=ls())

#Load libraries
library(tm)
library(stringr)
library(sqldf)
library(data.table)
library(outliers)
library(xtable)


###################################################
### code chunk number 2: SecurityAnalytics.rnw:71-78
###################################################
#Read server log - text file
secureData <- scan("secure.txt", character(0), sep = "\n") # separate each line

#Save as a word corpus
data <- Corpus(VectorSource(secureData[1:1000],))

inspect(data[1:5]) #Inspect the first five entries in the data


###################################################
### code chunk number 3: SecurityAnalytics.rnw:88-90
###################################################
#Function to strip white space from strings
trim <- function (x) gsub("^\\s+|\\s+$", "", x)


###################################################
### code chunk number 4: SecurityAnalytics.rnw:96-108
###################################################
#Regular expressions for parsing date information
regexpDate = "[0-9][0-9]:[0-9][0-9]:[0-9][0-9]"
regexpDay = "\\s[0-9][0-9]\\s"
regexpMonth = "^[A-Z][a-z][a-z]\\s"

time = trim(str_extract(secureData[1:1000],regexpDate))
day = trim(str_extract(secureData[1:1000],regexpDay))
month = trim(str_extract(secureData[1:1000],regexpMonth))

#Make a data frame consisting of month, day, and time columns
timeStampCols = data.frame(cbind(month, day, time))
timeStampCols[1:5,]


###################################################
### code chunk number 5: SecurityAnalytics.rnw:114-122
###################################################
data2 = tm_map(data, stripWhitespace)
data2 = tm_map(data2, tolower)
stopWords = c(stopwords("english"),"uiftp","sshd")
data2 = tm_map(data2, removeWords, stopWords)
data2 = tm_map(data2, stemDocument)
data2 = tm_map(data2, removePunctuation)
data2 = tm_map(data2, removeNumbers)
inspect(data2[1:5])


###################################################
### code chunk number 6: SecurityAnalytics.rnw:133-136
###################################################
#Make a word frequency matrix, with documents as rows, and terms as columns
dtm = DocumentTermMatrix(data2)
inspect(dtm[1:5,1:5])


###################################################
### code chunk number 7: SecurityAnalytics.rnw:147-150
###################################################
#Remove and inspect sparse terms, with at least 80% sparse occurence
dtm = removeSparseTerms(dtm, 0.85)
inspect(dtm[1:5,1:5])


###################################################
### code chunk number 8: SecurityAnalytics.rnw:161-164
###################################################
#Make a word frequency matrix, with terms as rows, and documents as columns
dtm2 = TermDocumentMatrix(data2)
inspect(dtm2)


###################################################
### code chunk number 9: SecurityAnalytics.rnw:176-185
###################################################
#Add month, day, and time columns to the document term matrix
#First, turn the dtm into a plain text object
dtmText = inspect(dtm)

#This data frame version has the full month, day, and time stamp 
dtmStamp = data.frame(cbind(timeStampCols, dtmText))

#This data frame version only has the month appended, not day or time
dtmMonth = data.frame(cbind(month, dtmText))


###################################################
### code chunk number 10: SecurityAnalytics.rnw:195-213
###################################################
#Get counts of entries for each month for use in bonferoni outlier detection
sqldf("select month, count(*) from dtmStamp group by month")
sqldf("select month, count(*) from dtmMonth group by month")

#Sum up the frequencies each of the top terms for each month
topTermsByMonth = sqldf("select month
,count(*) as rowCount
,sum(user) as user
,sum(invalid) as invalid
,sum(richard) as richard
,sum(port) as port
,sum(password) as password
,sum(ssh) as ssh
,sum(uid) as uid
,sum(session) as session
from dtmMonth group by month")

aggregate(dtmMonth[,-1], by = list(factor(dtmMonth$month)), sum)


###################################################
### code chunk number 11: SecurityAnalytics.rnw:227-229
###################################################
#Find the top 20 most frequent terms
findFreqTerms(dtm, 20)


###################################################
### code chunk number 12: SecurityAnalytics.rnw:240-244
###################################################
#Find associated terms with the term, "root", and a correlation of at least 0.4
findAssocs(dtm, "session", 0.4)
findAssocs(dtm, "user", 0.4)
findAssocs(dtm, "port", 0.4)


###################################################
### code chunk number 13: SecurityAnalytics.rnw:254-262
###################################################
##Other functions related to selecting specific terms

#Create a dictionary: a subset of terms
d = Dictionary(c("root", "richard", "invalid", "session"))

#Use dictionary to make a matrix with only the dictionary terms
dtm_dictionary = TermDocumentMatrix(data2, list(dictionary = d))
inspect(dtm_dictionary)


###################################################
### code chunk number 14: SecurityAnalytics.rnw:266-283
###################################################
#Bonferoni outlier detection


##Second version of grouping, utilizing a more automated technique
#dtmMonth.dt <- data.table(dtmMonth)
#setkey(data.dt, month)
#dtmMonth.dt[, lapply(.SD, sum), by = list(month)]


#by(iris[, 1:4], Species, mean)
#by(dtmMonth[,-1], dtmMonth$month, sum)
#is.numeric(dtmMonth[,-1])

?apply
?aggregate

#plot(topTermsByMonth$session~topTermsByMonth$rowCount) 


