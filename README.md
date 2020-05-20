# [ponto-whatsapp](https://leonardodiegues.shinyapps.io/ponto-whatsapp/)

### Propósito
A ferramenta tem como objetivo facilitar a marcação remota de ponto utilizando um grupo de __WhatsApp__ como referência.

### Instruções de uso
1. A conversa do grupo do ponto deve ser exportada e anexada à aba upload
2. Para que a aplicação funcione do modo correto, é necessário que palavras específicas sejam utilizadas, a fim de que os horários de entrada e saída possam ser lidos pelo algorítimo.
    * As palavras __entrada__ e __saída__ devem ser utilizadas para marcar o início e fim do expediente, respectivamente;
    * Se houver alguma correção de horário de entrada ou saída, elas devem ser feitas no formato de uma nova mensagem, contendo a __ação__ e o __horário__. Exemplo: "entrada 10:20";
    * Caso haja alguma correção do dia seguinte em relação ao dia anterior, ela deve ser feita no formato __ação dd/mm/yyyy hh:mm__. Exemplo: "saída 15/05/2020 20:30";
    * Mensagens que não estejam no formato especificado serão ignoradas.