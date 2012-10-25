library(scatterplot3d)
#library(rgl) #interactive plots

getOpt <- function(argname, numeric = F) {
  args <- commandArgs()  
  argexp = sprintf('^--%s=',argname)
  idx <- regexpr(argexp, args); 
  ret <- NA
  
  if ( any(idx > 0) ) { # found matching argument  
    found <- args[idx > 0]
    value <- strsplit(found,"=")
    ret <- unlist(value)[2]
   }
   
   if ( numeric )
     ret <- as.numeric(ret)
   
   ret
}

###
### Main
###

inFile<-getOpt("inDisplFile")
outFile<-getOpt("outDisplFile")
plotFile<-getOpt("plotFile")

dis_data <- read.table(inFile, header=FALSE, sep =" ");

summary(dis_data)

dis_data_temp <- subset(dis_data, dis_data$V1==100.)

write.table(file=outFile, dis_data_temp[2:4], sep="\t", row.names=FALSE, col.names=FALSE);

x<-dis_data_temp$V2
y<-dis_data_temp$V3
z<-dis_data_temp$V4

length(x)
length(x)
length(z)

pdf(plotFile)      
  scatterplot3d(x,y,z,
               angle=-22.5,
               color=gray(.4*z/max(abs(z)) + .4),
               box=TRUE,
               pch=".",
               main="Deformation using the Okada model",
               sub=inFile,
               tick.marks=TRUE,
               xlab="long",
               ylab="lat",
               zlab="displacement in meters");
dev.off()
             
# plot3d(x,y,z, #interactive plots
       # col=gray(.4*z/max(abs(z)) + .4), 
       # box=TRUE,
       # main="Deformation using the Okada model",
       # sub=filename,
       # tick.marks=TRUE,
       # xlab="long",
       # ylab="lat",
       # zlab="displacement in meters")