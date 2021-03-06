library(ggplot2)
library(reshape2)
library(plyr)
library(extrafont)
require(grid)

options(stringsAsFactors = FALSE)
Sys.setlocale("LC_ALL","English")

#Setup Fonts
loadfonts(device="win", quiet=T)
FontName = "Georgia"
FontList <- data.frame(fonts())


#Import and Massage Data
NatlGOPData <- read.csv("C:/CodePractice/R/NationalGOP2016.csv", encoding="UTF-8")
#NatlGOPData <- NatlGOPData[NatlGOPData$year_value==2015,]
parsedate <- function(dayrange, year) {
  dayrange <- as.character(dayrange)
  dayrange <- strsplit(dayrange, " - ")
  dayrange <- sapply(dayrange, function(x) x[2])
  dayrange <- gsub("/","-",dayrange)
  year <- as.character(year)
  result <- paste(year, "-", dayrange, sep="")
  result <- as.Date(result)
  return(result)
}
lowesspoll <- function(pollresult) {
  temp <- as.numeric(pollresult)
  temp[is.na(temp)] <- 0
  temp <- lowess(temp, f=0.05)[[2]]
  #temp[1] <- pollresult[1]
  return(temp)
}
splinepoll<- function(pollresult) {
  temp <- as.numeric(pollresult)
  temp[is.na(temp)] <- 0
  temp <- spline(temp, n=360)[2]
  return(temp)
}
computealpha <- function(value) {
  percent <- value/max(MeltedData$value)
  percent <- 1
  return(percent)
}

NatlGOPData <- within(NatlGOPData, parsed_date <- parsedate(date_value, year_value))

#Do Smoothing
NatlGOPData[seq(9,21)]  <- mapply(lowesspoll, NatlGOPData[seq(9,21)])

#Add index
NatlGOPData$global_index <- length(NatlGOPData$parsed_date):1

#Decide Candidate Details
CandidateColors = c('#457fff', '#cc0000','#000000','#ff66ff','#009900','#666666','#990099','#9966ff','#000099', '#996600','#f2dc0f', '#3da882', '#990000')
CandidateNames = c("Trump", "Carson", "Cruz", "Rubio", "Bush", "Fiorina", "Christie", "Kasich", "Huckabee", "Paul", "Patacki", "Graham", "Santorum")

#Reshape Data
MeltedData <- melt(NatlGOPData[c(9:21,24)], id="global_index")
MeltedData$candidate_color <- MeltedData$variable
MeltedData$alpha_value <- mapply(computealpha, MeltedData$value)
MeltedData$variable <- mapvalues(MeltedData$variable, levels(MeltedData$variable), CandidateNames)
MeltedData$candidate_color <- mapvalues(MeltedData$candidate_color, levels(MeltedData$candidate_color), CandidateColors)

#Plot Data

xbreaks = seq.int(1, length(NatlGOPData$global_index), length.out = 12)
xbreaks <- round(xbreaks)
xlabels = as.character.Date(rev(NatlGOPData$parsed_date[xbreaks]), format="%b %d, %Y")
BGColor = "#f0f0f0"
TextColor = "#323232"
GridColor = "#DCDCDC"
TextSettings = element_text(family=FontName, size=20, color = "#525252", face = "bold")

PrimaryPlot <- ggplot(MeltedData, aes(x=global_index, y=value, color=variable, alpha=alpha_value)) + 
  geom_path(size=1.2) +
  #geom_point(size=0.75) + 
  scale_color_manual(values=CandidateColors) +
  scale_alpha_continuous(range=c(0.5,0.95), guide="none") +
  labs(x = NULL, y = NULL, color = NULL, alpha = NULL, title = "National GOP Primary Race") + 
  scale_x_discrete(breaks = xbreaks, label = xlabels) +
  scale_y_discrete(breaks = seq(0, max(MeltedData$value), by=5), label = function(x){paste0(x, "%")}) +
  theme(plot.title=element_text(vjust=1, size=24, color=TextColor),
        panel.background = element_rect(fill=BGColor, color=BGColor),
        plot.background = element_rect(fill=BGColor, color=BGColor),
        plot.margin = unit(c(1,1,1,1), "cm"),
        legend.text = element_text(angle = 0, vjust = 0, hjust=0, color=TextColor),
        legend.background = element_rect(fill=BGColor, color=BGColor),
        legend.key = element_rect(fill=BGColor, color=BGColor),
        panel.grid.major = element_line(colour=GridColor, size=1.2),
        axis.ticks.x = element_line(colour=GridColor, size=1.2),
        axis.ticks.y = element_blank(),
        axis.text.x=element_text(angle = 45, vjust = 1, hjust=1, color=TextColor),
        axis.text.y=element_text(angle = 0, vjust = 0.5, hjust=0, color=TextColor),
        text = TextSettings)

PrimaryPlot
ggsave(PrimaryPlot, filename = "GGPlot2 - National GOP Primary Race.png")
  

