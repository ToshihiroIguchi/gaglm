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
                             ),
                    tabPanel("Setting",
                             numericInput("popsize", "Population size",
                                          value = 30, min = 2, step = 1),
                             numericInput("iters", "Number of iterations",
                                          value = 30, min = 2, step = 1),
                             numericInput("cook", "Cook's distance as an error",
                                          value = 1, min = 0.1, step = 0.1),
                             numericInput("nfolds", "K-fold cross varidation",
                                          value = 5, min = 2, step = 1)

                             )

        )
      )
    )
  )
)
