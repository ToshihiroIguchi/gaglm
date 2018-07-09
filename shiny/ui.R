library(shiny)


shinyUI(
  fluidPage(
    titlePanel("Automatic selection of explanatory variable of multiple regression analysis by genetic algorithm"),
    sidebarLayout(
      sidebarPanel(
        fileInput("file", "Choose csv file",
                  accept = c(
                    "text/csv",
                    "text/comma-separated-values,text/plain",
                    ".csv")
        ),

        tags$hr(),
        htmlOutput("ydata"),
        htmlOutput("xdata"),


        actionButton("submit", "Analyze")

      ),

      mainPanel(
        tabsetPanel(type = "tabs",
                    tabPanel("Table", tableOutput('table')),
                    tabPanel("Result",
                             plotOutput("plot"),
                             verbatimTextOutput("sum")
                             )

        )
      )
    )
  )
)
