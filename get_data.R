library(jsonlite)
library(data.table)
library(plotly)
get_coin_list <- function(){
  coins <- fromJSON('https://www.cryptocompare.com/api/data/coinlist/')
  coin_symbol <- names(coins$Data)
  coin_names <- NULL
  for(i in 1:length(coins$Data)){
    t <- coins$Data[[i]]
    coin_names<- c(coin_names,t$CoinName)
  }
  return(list(names = coin_names,symbols = coin_symbol))
}

get_coin_df <- function(){
  coins <- fromJSON('https://www.cryptocompare.com/api/data/coinlist/')

  coin_df_list<- data.table()
  for(i in 1:length(coins$Data)){
    coin_df_list <- rbind(coin_df_list,data.frame(coins$Data[[i]], stringsAsFactors = F), fill=T)
  
  }
  coin_df_list$SortOrder <- as.numeric(coin_df_list$SortOrder)
  coin_df_list$TotalCoinSupply <- as.numeric(coin_df_list$TotalCoinSupply)
  coin_df_list$PreMinedValue <- as.numeric(coin_df_list$PreMinedValue)
  coin_df_list$TotalCoinsFreeFloat <- as.numeric(coin_df_list$TotalCoinsFreeFloat)
  coin_df_list$TotalCoinsMined <- as.numeric(coin_df_list$TotalCoinsMined)
  coin_df_list <- coin_df_list[,4:ncol(coin_df_list)]
  setorder(coin_df_list,SortOrder)
  return(coin_df_list)
}

get_one_coin <- function(coin,agg_time){
  # coin <- 'CVC'
  # agg_time <- 'histoday'
  link<- paste('https://min-api.cryptocompare.com/data/', agg_time,'?fsym=',coin,'&tsym=USD&limit=2000',sep ="")
  adat <- fromJSON(link)
  if(adat$Response=="Success"){
    adat<- data.table(adat$Data)
    adat<- adat[high!=0&close!=0&low!=0,]
    adat$time <- as.POSIXct(adat$time, origin="1970-01-01")
    adat$symbol <- coin
    adat <- adat[,c("symbol","time",'close')]
    return(adat)
  }else{
    return(data.frame())
  }
}


#get_one_coin('CVC','histoday')



get_coin_hist_data <- function(coin_list,agg_time){

  adat<-data.table()
  for(i in coin_list){
    adat <- rbind(adat, get_one_coin(i,agg_time))
  }
  return(adat)
}


adatom <- get_coin_hist_data(c("ETH","CVC"), "histoday")



tozsde_plot <- function(adatom,min_date,max_date){
  print("plot")
  print(str(adatom))
  adatom <- adatom[as.Date(adatom$time)>=as.Date(min_date) & as.Date(adatom$time)<=as.Date(max_date),]
  list_of_markets <- unique(adatom$symbol)

  setorder(adatom, symbol, time)
  print(str(adatom))
  
  for (i in list_of_markets) {
    baseline <- adatom[symbol == i, close][1]
    adatom[symbol == i, change := (close/baseline-1)*100]
  }
  
  
  f <- list(
    family = "Courier New, monospace",
    size = 18,
    color = "#7f7f7f"
  )
  x <- list(
    title = "Date time",
    titlefont = f
  )
  y <- list(
    title = "Change (%)"
  )
  
  m <- list(
    l = 100,
    r = 80,
    b = 10,
    t = 150,
    pad = 4
  )
  p<-plot_ly(adatom, x = ~time, y = ~change, color =~symbol, text= ~paste('$',close))%>%
    add_lines()%>%layout( xaxis = x, yaxis = y)
  
  return(p)
  
}