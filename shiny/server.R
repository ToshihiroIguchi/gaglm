#CUI版のgaglm読み込み
source(file.path("../R","gaglm.R"))
source(file.path("../R","gaglm.cv.R"))

#shiny用の関数読み込み
source("shiny_gaglm.R")


server <- function(input, output, session) {
  observeEvent(input$file, {
    #テーブルにて表示
    csv_file <- reactive({read.csv(input$file$datapath)})
    output$table <- renderTable({head(csv_file(), n = 30)})

    #目的変数を選択
    output$ydata <- renderUI({
      selectInput("ydata", "Purpose variable", choices = colnames(csv_file()))
    })
  })



  observeEvent(input$ydata, {
    csv_file <- reactive({read.csv(input$file$datapath)})
    #説明変数を選択
    output$xdata <- renderUI({
      checkboxGroupInput("xdata",
                         label = "Explanatory variable",
                         choices = get.explanatory(csv_file(), input$ydata),
                         selected = get.explanatory(csv_file(), input$ydata)
                         )
      })

  })

  observeEvent(input$submit, {

    csv_file <- reactive({read.csv(input$file$datapath)})

    #Elastic Netの計算
    result <- reactive({gaglm(chr2formula(y = input$ydata, x= input$xdata),
                               data = csv_file(),
                              method = "CV",
                               seed = 108
                               )
      })

    #結果のプロット
    output$plot <- renderPlot({plot(result())})

    #結果の表示
    output$sum <- renderPrint({summary(result())})
  })
}





