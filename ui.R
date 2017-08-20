library(shiny)
library(plotly)
library(DT)
library(data.table)
library(plotly)
library(shinycssloaders)


# for spinners 2-3 match the background color of wellPanel
options(spinner.color.background="#F5F5F5")

navbarPage(
  title="Crypto report",theme = "cosmo", fluid = T,
  tabPanel("Charts", 
      fluidRow(
    
    column(3,
          wellPanel(
       uiOutput('coins'),
       radioButtons('time', 'Choose agregation', choiceNames = c('minute','hour','day'), 
                    choiceValues = c('histominute','histohour','histoday'), selected = 'histoday' ),
       dateRangeInput('dateRange',
                      label = 'Date range',
                      start = Sys.Date() - 30, end = Sys.Date())
    )),
    column(9,
           withSpinner( plotlyOutput("summary_plot") ,type = 4)) 
           
  )#fr
  ),# tabpanel
  tabPanel('Coin list', 
           withSpinner(dataTableOutput('coin_data'),type = 4)
           )
           

  
)#nav















# sidebarLayout(
#   sidebarPanel(
#     sliderInput("integer", "Number of days before:", min=1, max=2000, value=100),
#     actionButton("goButton", "Get plot!")
#   ),
#   mainPanel(
#     #withSpinner(plotlyOutput('summary_plot', height = 720),type = 4),
#     h2(textOutput('my_text'), align='center')
#   )
# )


