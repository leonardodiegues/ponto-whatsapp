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

shinyServer(function(input, output) {
    
    timetable <- reactive({
        if (is.null(input$file)) return(NULL)
        req(input$file)
        wpp_to_timetable(input$file$datapath)
    })
    
    output$timetable <- DT::renderDataTable({
        timetable()
    })
    
    output$timetable_agg <- DT::renderDataTable({
        timetable() %>% 
            group_by(nome) %>% 
            summarise_at(vars(total_horas, total_minutos), sum, na.rm = TRUE)
    })
    
    output$downloadData <- downloadHandler(
        filename = function() {
            paste("timetable-", Sys.Date(), '.xlsx', sep = '')
        },
        content = function(con) {
            writexl::write_xlsx(timetable(), con)
        }
    )
    
    output$metrics <- renderUI({
        req(input$file)
        tabsetPanel(id = "metricsPanel",
                    selected = TRUE,
                    
                    tabPanel("Geral",
                             DT::dataTableOutput("timetable"),
                             
                             tags$br(),
                             
                             # Download XLSX button
                             downloadButton("downloadData", "Download XLSX")
                    ),
                    
                    tabPanel("Agregado",
                             DT::dataTableOutput("timetable_agg"),
                             
                             tags$br(),
                             
                             # Download XLSX button
                             downloadButton("downloadData", "Download XLSX")
                    )
        )
    })
})