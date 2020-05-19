library(shiny)

shinyUI(
    navbarPage(title = "ponto whatsapp",
               theme = "style/style.css",
               fluid = TRUE,

               # First tab
               tabPanel("upload",
                        
                        # Upload button
                        fileInput(inputId = "file",
                                  label = "Histórico do Grupo",
                                  multiple = FALSE,
                                  accept = c("text", ".txt")
                        ),
                        
                        # Output metrics
                        uiOutput(outputId = "metrics")
               ),
               
               # Second tab
               tabPanel("como funciona?",
                        
                        # Explaining
                        tags$h4("Propósito"),
                        tags$p("A ferramenta tem como objetivo facilitar a marcação remota de ponto utilizando um grupo de WhatsApp como referência."),
                        tags$p("Para que a aplicação funcione do modo correto, é necessário que palavras específicas sejam utilizadas, a fim de que os horários de entrada e saída possam ser lidos pelo algorítimo."),
                        tags$p("Show de bola"),
                        tags$h4("Instruções de uso"),
                        tags$a(href = "https://faq.whatsapp.com/en/android/23756533/",
                               target = "_blank",
                               "Link para detalhes de exportação de conversa."
                        )
               ),
               
               tags$script(src = "plugins/logo.js")
    )
)
