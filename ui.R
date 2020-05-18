library(shiny)

shinyUI(
    navbarPage(title = "Ponto WhatsApp",
               theme = "style/style.css",
               
               # First tab
               tabPanel("Como funciona?",
                        
                        # Explaining
                        tags$h4("Propósito"),
                        tags$p("A ferramenta tem como objetivo facilitar a marcação remota de ponto utilizando um grupo de WhatsApp como referência."),
                        tags$p("É necessário, entretanto, para que a ferramenta funcione do modo correto, que algumas linguagens sejam utilizadas, a fim de que os horários de entrada e saída possam ser lidos pelo algorítimo."),
                        tags$h4("Instruções de uso"),
                        tags$p("Toda")
               ),
               
               # Second tab
               tabPanel("Upload",
                        
                        # Upload button
                        fileInput(inputId = "file",
                                  label = "Histórico do Grupo",
                                  multiple = FALSE,
                                  accept = c("text", ".txt")
                        ),
                        
                        # Output metrics
                        uiOutput(outputId = "metrics")
               )
    )
)
