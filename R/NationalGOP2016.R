options(stringsAsFactors = FALSE)
Sys.setlocale("LC_ALL","English")

NatlGOPData <- read.csv("C:/CodePractice/R/NationalGOP2016.csv", encoding="UTF-8")
dateparse <- function(dayrange, year) {
  dayrange <- as.character(dayrange)
  dayrange <- strsplit(dayrange, " - ")
  dayrange <- sapply(dayrange, function(x) x[2])
  dayrange <- gsub("/","-",dayrange)
  year <- as.character(year)
  result <- paste(year, "-", dayrange, sep="")
  result <- as.Date(result)
  return(result)
}

parsepoll <- function(pollresult) {
  result <- as.numeric(pollresult)
  result[is.na(result)] <- -2
  return(result)
}

plotcandidate <- function(candidateseries, candidatecolor = "black") {
  candidateseries <- lowess(parsepoll(candidateseries), f=0.06)[[2]]
  candidateseries <- rev(candidateseries)
  xaxisseries <- seq(1, length(candidateseries))
  serieslength <- length(candidateseries)
  lines(xaxisseries, candidateseries, type='l', col=candidatecolors[candidatecolor], lwd=2)
}

NatlGOPData <- within(NatlGOPData, parsed_date <- dateparse(date_value, year_value))
xaxisseries <- seq(1, length(NatlGOPData$parsed_date))
xaxislim <- c(1, length(NatlGOPData$parsed_date))
tickpoints <- xaxisseries[seq(1, length(xaxisseries), length.out = 12)]
tickpoints <- tickpoints
xaxislabels <- rev(as.character.Date(NatlGOPData$parsed_date[tickpoints], format="%b. %Y"))

png(file = "DefaultRPlot - National GOP Primary Race.png", width = 702, height = 455, antialias = "cleartype")

plot(NULL, typ='l', ann=F, axes=F, xlim=xaxislim, ylim=c(0,30), xlab="")
axis(1, at=tickpoints, labels=xaxislabels, las=2, font=2)
axis(2, at=seq.int(0,100,5), font=2)
title(main="National GOP Primary (2015)", ylab="Support %", font.lab=2, font=2)
grid()

candidatecolors = c('#7f3b08','#b35806','#e08214','#fdb863','#fee0b6','#000000','#d8daeb','#b2abd2','#8073ac','#542788','#2d004b', 'ffffff', 'ffffff')
candidatenames = c("Trump", "Carson", "Cruz", "Rubio", "Bush", "Fiorina", "Christie", "Kasich", "Huckabee", "Paul", "Patacki", "Graham", "Santorum")
legend('topleft', candidatenames, lty=1, col=candidatecolors, bty='n', cex=0.75, lwd=5, ncol=3, text.font = 2 )

#Plot Candidates
plotcandidate(NatlGOPData$trump_value, 1)
plotcandidate(NatlGOPData$carson_value, 2)
plotcandidate(NatlGOPData$cruz_value, 3)
plotcandidate(NatlGOPData$rubio_value, 4)
plotcandidate(NatlGOPData$bush_number, 5)
plotcandidate(NatlGOPData$fiorina_value, 6)
plotcandidate(NatlGOPData$christie_number, 7)
plotcandidate(NatlGOPData$kasich_value, 8)
plotcandidate(NatlGOPData$huckabee_value, 9)
plotcandidate(NatlGOPData$paul_number, 10)
plotcandidate(NatlGOPData$pataki_value, 11)
plotcandidate(NatlGOPData$graham_value, 12)
plotcandidate(NatlGOPData$santorum_value, 13)

dev.off()

