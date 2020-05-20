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
                        tags$h4("Instruções de uso"),
                        tags$ol(
                            tags$li(tags$p(HTML("A conversa do grupo do ponto deve ser <a href=\"https://faq.whatsapp.com/en/android/23756533/\" target=\"_blank\">exportada</a> e anexada à aba <b>upload</b>"))),
                            tags$li(
                                tags$p("Para que a aplicação funcione do modo correto, é necessário que palavras específicas sejam utilizadas, a fim de que os horários de entrada e saída possam ser lidos pelo algorítimo."),
                                tags$ul(tags$li(HTML("As palavras <b>entrada</b> e <b>saída</b> devem ser utilizadas para marcar o início e fim do expediente, respectivamente;")),
                                        tags$li(HTML("Se houver alguma correção de horário de entrada ou saída, elas devem ser feitas no formato de uma nova mensagem, contendo a <b>ação</b> e o <b>horário</b>. Exemplo: \"entrada 10:20\";")),
                                        tags$li(HTML("Caso haja alguma correção do dia seguinte em relação ao dia anterior, ela deve ser feita no formato <b>ação dd/mm/yyyy hh:mm</b>. Exemplo: \"saída 15/05/2020 20:30\";")),
                                        tags$li("Mensagens que não estejam no formato especificado serão ignoradas.")
                                ),
                            )
                        ),
               ),
               
               tags$script(src = "plugins/logo.js")
    )
)
