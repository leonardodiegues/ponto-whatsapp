# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(here)
library(DT)

source(here("utils.R"))

shinyServer(function(input, output) {
    
    customized_table <- function(.tbl) {
        DT::datatable(
            data = .tbl,
            filter = "top",
            options = list(
                dom = "tp",
                pageLength = 20,
                autoWidth = TRUE
            )
        )
    }
    
    timetable <- reactive({
        if (is.null(input$file)) return(NULL)
        req(input$file)
        wpp_to_timetable(input$file$datapath)
    })
    
    timetable_agg <- reactive({
        if (is.null(input$file)) return(NULL)
        req(input$file)
        timetable() %>% 
            group_by(mes, ano, nome) %>% 
            summarise_at(vars(total_horas, total_minutos), sum, na.rm = TRUE)
    })
    
    contacts <- reactive({
        req(input$file)
        unique(timetable()$nome)
    })
    
    messages <- reactive({
        req(input$file)
        nrow(timetable())
    })
    
    output$timetable <- DT::renderDataTable({
        customized_table(timetable())
    })
    
    output$timetable_agg <- DT::renderDataTable({
        customized_table(timetable_agg())
    })
    
    output$downloadData <- downloadHandler(
        filename = function() {
            paste("timetable-", Sys.Date(), '.xlsx', sep = '')
        },
        content = function(con) {
            writexl::write_xlsx(
                x = list(
                    "Geral" = timetable(),
                    "Agregado" = timetable_agg()
                ),
                path = con
            )
        }
    )
    
    output$metrics <- renderUI({
        req(input$file)
        tabsetPanel(id = "metricsPanel",
                    selected = TRUE,
                    
                    tabPanel("Geral",
                             column(DT::dataTableOutput("timetable"),
                                    
                                    # Download XLSX button
                                    downloadButton("downloadData", "Download XLSX completo"),
                             width = 6)
                    ),
                    
                    tabPanel("Agregado",
                             column(DT::dataTableOutput("timetable_agg"),
                                    
                                    # Download XLSX button
                                    downloadButton("downloadData", "Download XLSX completo"),
                                    width = 6)
                    )
        )
    })
    
})