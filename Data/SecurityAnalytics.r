\documentclass[compress,8pt]{beamer}
\usepackage[latin1]{inputenc}
\usepackage{pgf,pgfarrows,pgfnodes,pgfautomata,pgfheaps,pgfshade}
\usepackage{amsmath,amssymb}
\usepackage[latin1]{inputenc}
\usepackage{colortbl}
\usepackage{graphicx}
\usepackage[english]{babel}
\usepackage{tabularx}
\usepackage{verbatim}
\usepackage{url} %needed for function to handle underscore characters
\usepackage[section]{placeins}
\usepackage{Sweave}
\usepackage{upquote}
\urlstyle{sf} %style consistent with URL package - can also use rm style
\usetheme{Singapore}%define the beamer theme
\setbeamertemplate{navigation symbols}{}%remove navigation symbols
\setbeamertemplate{section in head/foot shaded}[default][20]
\setbeamertemplate{headline}{}%remove the navigation header
%\setbeamertemplate{subsection in head/foot shaded}[default][20]
\logo{\includegraphics[width=0.15\textwidth]{nw_logo.jpg}} %change here. I used an eps file logo, you can use jpg or other format

\title{\bfseries{Outlier Analysis of Nationwide Catastrophe Exposure
    Data\\ Net of Growth Effects\\ September 2012 vs. September 2011}}
\author{Nationwide Product and Pricing Risk Management\\ PROPRIETARY AND CONFIDENTIAL}
\date{November 27, 2012}
%\institute[Product and Pricing Risk Management]{Product and Pricing Risk Management \\ Nationwide Insurance }

\AtBeginSection[]
{
  \begin{frame}
    \begin{center}
        \Large{\insertsection}
    \end{center}
  \end{frame}
}

%\AtBeginSubsection[]
%{
%  \begin{frame}
%    \begin{center}
%        \Large{\insertsubsection}
%    \end{center}
%  \end{frame}
%}

\begin{document}

\begin{frame}
  \maketitle
\end{frame}

\begin{frame}
\frametitle{Outline}
\tableofcontents%[part=1,pausesections]
\end{frame}

\section{Introduction}


rm(list=ls())

library(tm)
library(stringr)
library(sqldf)
library(data.table)
library(outliers)
library(xtable)

#Read server log - text file
secureData <- scan("secure.txt", character(0), sep = "\n") # separate each line

#Save as a word corpus
data <- Corpus(VectorSource(secureData[1:1000],))

summary(data) #Test summary function
print(data) #Test print function
inspect(data) #Inspect data

#Function to strip white space from strings
trim <- function (x) gsub("^\\s+|\\s+$", "", x)

#Regular expressions for parsing date information
regexpDate = "[0-9][0-9]:[0-9][0-9]:[0-9][0-9]"
regexpDay = "\\s[0-9][0-9]\\s"
regexpMonth = "^[A-Z][a-z][a-z]\\s"

time = trim(str_extract(secureData[1:1000],regexpDate))
day = trim(str_extract(secureData[1:1000],regexpDay))
month = trim(str_extract(secureData[1:1000],regexpMonth))

#Make a data frame consisting of month, day, and time columns
timeStampCols = data.frame(cbind(month, day, time))

data2 = tm_map(data, stripWhitespace)
data2 = tm_map(data2, tolower)
stopWords = c(stopwords("english"),"uiftp","sshd")
data2 = tm_map(data2, removeWords, stopWords)
data2 = tm_map(data2, stemDocument)
data2 = tm_map(data2, removePunctuation)
data2 = tm_map(data2, removeNumbers)
inspect(data2)

#Make a word frequency matrix, with documents as rows, and terms as columns
dtm = DocumentTermMatrix(data2)
inspect(dtm)

#Remove and inspect sparse terms, with at least 80% sparse occurence
dtm = removeSparseTerms(dtm, 0.85)
inspect(dtm)

#Make a word frequency matrix, with terms as rows, and documents as columns
dtm2 = TermDocumentMatrix(data2)
inspect(dtm2)

#Find the top 20 most frequent terms
findFreqTerms(dtm, 20)

#Find associated terms with the term, "root", and a correlation of at least 0.4
findAssocs(dtm, "session", 0.4)
findAssocs(dtm, "user", 0.4)
findAssocs(dtm, "port", 0.4)

##Other functions related to selecting specific terms

#Create a dictionary: a subset of terms
d = Dictionary(c("root", "richard", "invalid", "session"))

#Use dictionary to make a matrix with only the dictionary terms
dtm_dictionary = TermDocumentMatrix(data2, list(dictionary = d))
inspect(dtm_dictionary)

#Add month, day, and time columns to the document term matrix
#First, turn the dtm into a plain text object
dtmText = inspect(dtm)

#This data frame version has the full month, day, and time stamp 
dtmStamp = data.frame(cbind(timeStampCols, dtmText))

#This data frame version only has the month appended, not day or time
dtmMonth = data.frame(cbind(month, dtmText))

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

#Bonferoni outlier detection


##Second version of grouping, utilizing a more automated technique
dtmMonth.dt <- data.table(dtmMonth)
setkey(data.dt, month)
dtmMonth.dt[, lapply(.SD, sum), by = list(month)]


#by(iris[, 1:4], Species, mean)
by(dtmMonth[,-1], dtmMonth$month, sum)
is.numeric(dtmMonth[,-1])

?apply
?aggregate

plot(topTermsByMonth$session~topTermsByMonth$rowCount) 
