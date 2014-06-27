if (require("ggplot2") == FALSE) install.packages("ggplot2")
if (require("grid") == FALSE) install.packages("grid")
if (require("gridExtra") == FALSE) install.packages("gridExtra")

numruns <- 2
prefix <- "138E-0"
setwd("C://Users//yue//Documents//R//hot topping")
file_names <- paste0(prefix, seq_len(numruns), ".log")
df_list <- lapply(file_names, function(x) read.csv(x, colClasses=c('NULL', 'numeric')))
df_all <- as.data.frame(do.call(cbind, df_list))
time <- as.data.frame(seq(1:480))
df_all <- data.frame(time, df_all)
new_names <- paste0("run", seq_len(numruns))
colnames(df_all) <- c("time", new_names)
#for NA values
df_all[is.na(df_all)] <- 0

filenames <- paste0(prefix, "all (250-drop)")

##uncomment AFTER initial run, 
##otherwise export happens before data can change

#export_png(filenames, 1400, 1800)
#export_pdf(filenames, 15.5, 18)

drop_thresh <- 250
#remove_columns <- c(-2)
remove_columns <- c(-100)

graph_names <- new_names[remove_columns]

# ///////////////////
# //Begin Functions//
# ///////////////////
max_coord <- function(column){
        max_temp <- max(df_all[,column])
        row_num <- round(mean(which(df_all[,column] == max_temp)),0)
        coord <- c(row_num, max_temp)
        return(coord)
}
drop_coord <- function(column){
        start <- max_coord(column)[1]
        end <- length(df_all$time)
        target = max_coord(column)[2]-drop_thresh
        drop_temp <- 0        
        for (i in start:end){
                if (df_all[i,column] <= target && df_all[i,column] > drop_temp){
                        drop_temp <- df_all[i,column]
                }
        }
        drop_time <- which(df_all[,column] == drop_temp)
        coord <- c(drop_time[1], drop_temp)
        return(coord)
}
ign_duration <- function(column){
        start <- max_coord(column)[1]
        end <- drop_coord(column)[1]
        duration <- end-start
        return(duration)
}
make_data_table <- function(g_list){
        a1 <- as.data.frame(lapply(g_list, max_coord))
        a2 <- lapply(g_list, drop_coord)
        b1 <- lapply(g_list, ign_duration)
        a1 <- rbind(a1, a2, b1)
        a3 <- rowMeans(a1)
        a4 <- apply(a1,1,sd)
        a5 <- cbind(a1, a3, a4)
        colnames(a5) <- c(g_list, "avg", "stdev")
        rownames(a5) <- c("Time@Max-T", "Max Temp", "Time@T-Drop", "T-Drop", "Duration")
        a5 <- round(a5, 0)
        colnames(a1) <- c(g_list)
        rownames(a1) <- c("Time@Max-T", "Max Temp", "Time@T-Drop", "T-Drop", "Duration")
        a1 <- round(a1, 0)
        remove_rows <- c(-1,-3,-4)
        report_data <- a5[remove_rows,]
        return(report_data)
}
make_quantile_table <- function(g_list){
        a1 <- as.data.frame(lapply(g_list, max_coord))
        a2 <- lapply(g_list, drop_coord)
        b1 <- lapply(g_list, ign_duration)
        a1 <- rbind(a1, a2, b1)
        colnames(a1) <- c(g_list)
        rownames(a1) <- c("Time@Max-T", "Max Temp", "Time@T-Drop", "T-Drop", "Duration")
        a1 <- round(a1, 0)
        colnames(a1) <- c(g_list)
        rownames(a1) <- c("Time@Max-T", "Max Temp", "Time@T-Drop", "T-Drop", "Duration")
        a1 <- round(a1, 0)
        remove_rows <- c(-1,-3,-4)
        report_data <- a1[remove_rows,]
        return(report_data)
}

#        =========================================
#        ==tables for outlier function reference==
#        =========================================
        data_table <- make_data_table(graph_names)
        quantile_table <- make_quantile_table(new_names)

mild_outliers <- function(row){
        lowerq = quantile(quantile_table[row,])[2]
        upperq = quantile(quantile_table[row,])[3]
        iqr = upperq-lowerq
        mild.threshold.upper = (iqr * 1.5) + upperq
        mild.threshold.lower = lowerq - (iqr * 1.5)       
        mild.threshold <- as.numeric(c(mild.threshold.lower, mild.threshold.upper))
        mild.threshold <- round(mild.threshold ,0)
        return(mild.threshold)
}
extreme_outliers <- function(row){
        lowerq = quantile(quantile_table[row,])[2]
        upperq = quantile(quantile_table[row,])[3]
        iqr = upperq-lowerq
        extreme.threshold.upper = (iqr * 3) + upperq
        extreme.threshold.lower = lowerq - (iqr * 3)       
        extreme.threshold <- as.numeric(c(extreme.threshold.lower, extreme.threshold.upper))
        extreme.threshold <- round(extreme.threshold ,0)
        return(extreme.threshold)
}

mild_outliers("Max Temp")
extreme_outliers("Max Temp")
mild_outliers("Duration")
extreme_outliers("Duration")

# //////////////////////////////////
# //Graph formatting for  Outliers//
# //////////////////////////////////
temp_outliers_color <- function(x){
        ifelse(x > mild_outliers("Max Temp")[2] | x < mild_outliers("Max Temp")[1],"purple", "red")
}
duration_outliers_color <- function(x){
        ifelse(x > mild_outliers("Duration")[2] | x < mild_outliers("Duration")[1],"yellow", "blue")
}
temp_outliers_size <- function(x){
        ifelse(x > extreme_outliers("Max Temp")[2] | x < extreme_outliers("Max Temp")[1],10, 5)
}
duration_outliers_size <- function(x){
        ifelse(x > extreme_outliers("Duration")[2] | x < extreme_outliers("Duration")[1],10, 5)
}

graphit <- function(column){
        ggplot(data=df_all, aes_string(x="time", y=column)) +
                ggtitle(paste(column, filenames)) +
                geom_point(alpha=1/4) +
                #geom_point(x=max_coord(column)[1], y=max_coord(column)[2], color="red", size=5, alpha=1/100)) +
                #geom_point(x=drop_coord(column)[1], y=drop_coord(column)[2], color="blue", size=5, alpha=1/100) +
                geom_point(x=max_coord(column)[1], y=max_coord(column)[2], 
                           color=temp_outliers_color(max_coord(column)[2]), 
                           size=temp_outliers_size(max_coord(column)[2]), 
                           alpha=1/100) +
                geom_point(x=drop_coord(column)[1], y=drop_coord(column)[2], 
                           color=duration_outliers_color(ign_duration(column)), 
                           size=duration_outliers_size(ign_duration(column)), 
                           alpha=1/100) +
                
                geom_hline(aes_string(yintercept=(max_coord(column)[2])),linetype="dashed", alpha=1/3, color="red") +
                geom_hline(aes_string(yintercept=(drop_coord(column)[2])),linetype="dashed", alpha=1/3, color="blue") +
                
                
                scale_x_continuous("Time(s)", limits=c(0,480)) +
                scale_y_continuous("Temperature(C)", limits=c(0,1400))
        
}


# //////////////////////////////
# //Format data table for grob//
# //Format graph for display////
# //////////////////////////////

d1 <- lapply(list(data_table), tableGrob)
g1 <- lapply(graph_names, graphit)
g1 <- c(g1, list(nrow=2,ncol=2))
g1 <- c(g1, d1)
do.call("grid.arrange", g1)


# export pNG
export_png <- function(x, h, w){
        png(paste0(x,".png"), width=w, height=h)
        d1 <- lapply(list(data_table), tableGrob)
        g1 <- lapply(graph_names, graphit)
        #g1 <- c(g1, list(nrow=2,ncol=2))
        g1 <- c(g1, d1)
        do.call("grid.arrange", g1)
        dev.off()
}

#export pdf
export_pdf <- function(x, h, w){
        pdf(paste0(x,".pdf"), width=w, height=h)
        d1 <- lapply(list(data_table), tableGrob)
        g1 <- lapply(graph_names, graphit)
        #g1 <- c(g1, list(nrow=2,ncol=2))
        g1 <- c(g1, d1)
        do.call("grid.arrange", g1)
        dev.off()
}




# ==========================================
#         TEST AREA
# ==========================================

# k1 <- tableGrob(
#         format(data_table, digits = 1,
#                scientific=F,big.mark = ","),
#         #core.just="left",
#         #core.just="right",
#         col.just="right",
#         gpar.coretext=gpar(fontsize=15), 
#         gpar.coltext=gpar(fontsize=10, fontface='bold'), 
#         show.rownames = T,
#         h.even.alpha = 0,
#         gpar.rowtext = gpar(col="black", cex=0.7,
#                             equal.width = TRUE,
#                             show.vlines = TRUE, 
#                             show.hlines = TRUE,
#                             separator="grey")                     
# )
# grid.newpage()
# grid.draw(k1)
# k11 <- grid.draw(k1)
