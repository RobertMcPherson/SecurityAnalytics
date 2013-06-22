rm(list=ls()) #Remove any objects

library(fBasics)
library(sqldf)

#Import failed requests file, using standard delimeter in Hive
failedRequests <- read.table("FailedRequestsByDay.txt",sep="")

#Add column headings
colnames(failedRequests) <- c("Date","FailedRequestsRatio")
stdev <- sd(failedRequests$FailedRequestsRatio) #calculate the standard deviation
avg <- mean(failedRequests$FailedRequestsRatio) #calculate the average
avgPlus2Stdev <- avg + 2*stdev #mean plus 2 standard deviations

#Identify the days that had failed requests in excess of 2X the standard deviation
failedRequests[failedRequests[,2]>avgPlus2Stdev,]

#Produce a plot and save it as a PDF
pdf("PlotOfFailedRequestRatioSeries.pdf")
plot(failedRequests[,2],type='l',main="Ratio of Failed Server Requests to Successful Requests by Day"
     ,xlab="Day",ylab="Ratio of Failed Requests to Successful Requests")
lines(rep(avg,length(failedRequests[,2])))
lines(rep(avgPlus2Stdev,length(failedRequests[,2])),lty=2)
legend("topright",c("Average","2 X Standard Deviation"),lty=c(1,2))
dev.off()

#Create autocorrelation plot to test for seasonality or other autocorrelation effects
pdf("FaileRequestsAutoCorrelation.pdf")
acfPlot(failedRequests[,2],lag.max=60)
dev.off()



#Import summed status code frequencies grouped by day
statusFrequencies <- read.table("SummedStatusByDay.txt",sep="")
statusFrequenciesNumeric <- statusFrequencies[-1,4:length(statusFrequencies)]

#Copy headers from Hive and paste them here.
colnames(statusFrequenciesNumeric) <- c("100continue","101switchingprotocols","102processing","200ok","201created","202accepted","203nonauthoritativeinformation","204nocontent","205resetcontent","206partialcontent","207multistatus","208alreadyreported","226imused","300multiplechoices","301movedpermanently","302found","303seeother","304notmodified","305useproxy","306switchproxy","307temporaryredirect","308permanentredirect","400badrequest401unauthorized","402paymentrequired","403forbidden","404notfound","405methodnotallowed","406notacceptable","407proxyauthenticationrequired","408requesttimeout","409conflict","410gone","411lengthrequired","412preconditionfailed","413requestentitytoolarge","414requesturitoolong","415unsupportedmediatype","416requestedrangenotsatisfiable","417expectationfailed","418imateapot","420enhanceyourcalm","422unprocessableentity","423locked","424faileddependency","424methodfailure","425unorderedcollection","426upgraderequired","428preconditionrequired","429toomanyrequests","431requestheaderfieldstoolarge","444noresponse","449retrywith","450blockedbywindowsparentalcontrols","451unavailableforlegalreasonsorredirect","494requestheadertoolarge","495certerror","496nocert","497httptohttps","499clientclosedrequest","500internalservererror","501notimplemented","502badgateway","503serviceunavailable","504gatewaytimeout","505httpversionnotsupported","506variantalsonegotiates","507insufficientstorage","508loopdetected","509bandwidthlimitexceeded","510notextended","511networkauthenticationrequired","598networkreadtimeouterror","599networkconnecttimeouterror")


colSums <- apply(statusFrequenciesNumeric,2,sum)
nonEmptyCols <- which(colSums>0)
str(nonEmptyCols)

X <- statusFrequenciesNumeric[,which(colSums>0)]
plot(X)

cor(X)

acf(diff(X$"200ok"))
acf(diff(X$"405methodnotallowed"))
ccf(y=diff(X$"200ok"),x=diff(X$"405methodnotallowed"),ylab="Cross-correlation")
ccf(y=diff(X$"405methodnotallowed"[10:length(X$"405methodnotallowed")]),x=diff(X$"405methodnotallowed"),ylab="Cross-correlation")


#ts200ok <- ts(X$"200ok",frequency=12)
#ts200ok.stl <- stl(ts200ok,s.window=5)
#plot(ts200ok.stl)

?ts
?stl
?arima
?ccf









