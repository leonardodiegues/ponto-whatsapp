#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(DT)

source("utils.R")

# Define UI for application that draws a histogram
ui <- navbarPage(
    title = "Ponto WhatsApp",
    theme = "style/style.css",
    
    tabPanel("Como funciona",
        tags$h4("Propósito"),
        tags$p("A ferramenta tem como objetivo facilitar a marcação remota de ponto utilizando um grupo de WhatsApp como referência."),
        tags$p("É necessário, entretanto, para que a ferramenta funcione do modo correto, que algumas linguagens sejam utilizadas, a fim de que os horários de entrada e saída possam ser lidos pelo algorítimo."),
        tags$h4("Instruções de uso"),
        tags$p("Toda")
    ),
    
    tabPanel("Upload",

        fileInput(
            inputId = "file",
            label = "Histórico do Grupo",
            multiple = FALSE,
            accept = c("text", ".txt")
        ),
        
        uiOutput("metrics"),
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
    
    timetable <- reactive({
        if (is.null(input$file)) return(NULL)
        req(input$file)
        wpp_to_timetable(input$file$datapath)
    })
    
    output$timetable <- DT::renderDataTable({
        timetable()
    })
    
    output$metrics <- renderUI({
        req(timetable())
        tabsetPanel("metrics-panel",
            tabPanel("Geral",
                 DT::dataTableOutput("timetable"),
                 
                 tags$br(),
                 
                 # Download XLSX button
                 downloadButton("downloadData", "Download XLSX")
            ),
            
            tabPanel("Agregado",
                 DT::dataTableOutput("timetable"),
                 
                 tags$br(),
                 
                 # Download XLSX button
                 downloadButton("downloadData", "Download XLSX")
            )
        )
    })
    
    output$downloadData <- downloadHandler(
        filename = function() {
            paste('timetable-', Sys.Date(), '.xlsx', sep = '')
        },
        content = function(con) {
            writexl::write_xlsx(timetable(), con)
        }
    )
}

# Run the application 
shinyApp(ui = ui, server = server)
