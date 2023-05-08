wealth_baseline$NY.GDP.PCAP.PP.CD <- ppp_gdp_capita
wealth_baseline$SI.POV.GINI <- gini

outer <- function(rwi, gini, gdp_capita){
  
  rwi_to_awi <- function(i){
    
    #https://arxiv.org/ftp/arxiv/papers/2104/2104.07761.pdf
    
    shape_alpha = (1+gini)/(2*gini)
    threshold = (1-(1/shape_alpha)) 
    n <- length(rwi)
    ranked_i <- rank(rwi)
    
    sd <- sqrt(2) * qnorm((gini+1)/2)
    mean <- log(gdp_capita) - ((sd^2)/2)
    
    p <- pnorm(ranked_i[-i]/n)
    
    x <- qlnorm(p, mean, sd)
    
    #library(Pareto)
    #library(HDInterval)
    # p <- pPareto(ranked_i[-i], threshold, shape_alpha)
    # x <-  qPareto(p, threshold, shape_alpha)
    
    return(x[ranked_i[i]])
    
  }
  
  out <- future_lapply(1:length(rwi), rwi_to_awi)
  
  out <- do.call(rbind, out)[,1]
  
  # library(lattice)
  # histogram(out, n=5)
  # summary(out)
  # #
  
  lm <- (lm(sort(rwi[-which(is.na(out))]) ~ sort(out[-which(is.na(out))])))
  out[which(is.na(out))] <- lm$coefficients[1] + lm$coefficients[2] * rwi[which(is.na(out))]
  
  outone <- data.frame(sort(rwi), sort(out))
  
  rwi_df <- as.data.frame(rwi)
  
  rwi_df <- rwi_df %>%
    group_by(rwi) %>%
    mutate(Count = row_number()) %>%
    ungroup() %>%
    mutate(rwi = ifelse(Count > 1, rwi + runif(1, 0.0001, 0.0009), rwi)) %>%
    dplyr::select(-Count)
  
  rwi_df <- merge(rwi_df, outone, by.x="rwi", by.y="sort.rwi.")
  
  #plot(rwi_df$rwi, rwi_df$sort.out..which.is.na.out....)
  
  return(rwi_df$sort.out.)
  
}

wealth_baseline$awi <- outer(wealth_baseline$rwi, wealth_baseline$SI.POV.GINI[1]/100, wealth_baseline$NY.GDP.PCAP.PP.CD[1])
  
wealth_baseline <- dplyr::select(wealth_baseline, latitude, longitude, rwi, awi, error, iso3c)

wealth_baseline <- filter(wealth_baseline, awi>0)
