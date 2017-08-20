library(shiny)
library(plotly)
library(data.table)
library(DT)



function(input, output, session) {
  source("get_data.R")
  
  coin_list_df <- data.table(get_coin_df())
  
  output$coin_data <- DT::renderDataTable(
    DT::datatable(coin_list_df,extensions = c('Buttons','FixedHeader'),class = 'cell-border stripe',rownames = FALSE,
                  filter = 'top', options = list(dom = 'Blfrtip', fixedHeader = TRUE,pageLength = 50,lengthMenu = c(10,50,500,5000, 10000, 25000 ),
                                                 buttons = c('copy', 'csv', 'excel', 'pdf', 'print'),
                                                 columnDefs = list())))
  
  output$coins <- renderUI({
    selectInput('my_coins','Choose your cryptos', choices = coin_list_df$FullName,  selected = c("Bitcoin (BTC)", "Ethereum  (ETH)"), multiple = TRUE,
                selectize = TRUE,width = '200px')
  })
  
  my_reactive_coin_list <- reactive({
    all_list <- input$my_coins
    gsub('\\)','',sapply(strsplit(all_list,'\\(',''),"[",2))
  })
  
  
  
  my_reactive_data <- reactive({get_coin_hist_data(my_reactive_coin_list(),input$time)})
  
  my_reactive_plot <- reactive({ return(tozsde_plot(my_reactive_data(),input$dateRange[1],input$dateRange[2] ))})
  
  output$summary_plot <- renderPlotly(my_reactive_plot())
  
  output$my_list <- renderPrint(input$dateRange)
  
}