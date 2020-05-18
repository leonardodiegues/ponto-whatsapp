library(dplyr)
library(tidyr)
library(stringr)
library(magrittr)
library(lubridate)

WORDS_TO_CONSIDER <- list(
    entering = c("entrada", "entrando", "entrei", "entrou"),
    leaving = c("saida", "saindo", "out", "sai", "saiu")
)

str_search <- function(string, term) {
    return(str_match(string = string, term)[1, 2])
}

timestamp_correction <- function(original_ts, message_content) {
    correction <- str_search(message_content, "(\\d{1,2}:\\d{2})")
    if (!is.na(correction)) {
        hour(original_ts) <- as.numeric(str_search(correction, "(\\d{1,2}):"))
        minute(original_ts) <- as.numeric(str_search(correction, ":(\\d{2})"))
    }
    return(original_ts)
}

identify_entities <- function(txt) {
    ts <- as_datetime(str_search(txt, "^(.*) -"), format = "%m/%d/%y, %H:%M")

    message_content <- txt %>%
        str_search(": (.*)$") %>% 
        tolower() %>% 
        iconv(from = "UTF-8", to = "ASCII//TRANSLIT")

    return(
        list(
            timestamp = ts,
            nome = str_replace(str_search(txt, "- (.*):"), ":.*", ""),
            mensagem = message_content,
            acao = case_when(
                message_content %in% WORDS_TO_CONSIDER$entering | 
                    str_detect(
                        message_content,
                        paste0(WORDS_TO_CONSIDER$entering, collapse = "|")
                    ) 
                ~ "entrada",
                message_content %in% WORDS_TO_CONSIDER$leaving |
                    str_detect(
                        message_content,
                        paste0(WORDS_TO_CONSIDER$leaving, collapse = "|")
                    )
                ~ "saida",
                TRUE ~ "outro"
            )
        )
    )
}

wpp_to_timetable <- function(path) {
    return(
        path %>% 
            readLines() %>%
            purrr::map_df(identify_entities) %>% 
            filter(!is.na(nome)) %>% 
            filter(!acao == "outro") %>% 
            mutate(data = as_date(timestamp)) %>% 
            mutate(corrected_timestamp = timestamp_correction(timestamp, mensagem)) %>% 
            group_by(data, nome, acao) %>%
            filter(corrected_timestamp == max(corrected_timestamp)) %>% 
            select(-mensagem, -timestamp) %>% 
            pivot_wider(names_from = acao, values_from = corrected_timestamp) %>% 
            group_by(nome, data) %>% 
            arrange(data) %>% 
            mutate(timediff = difftime(saida, entrada, units = "hours")) %>% 
            mutate(total_horas = floor(as.numeric(timediff))) %>% 
            mutate(total_minutos = (as.numeric(timediff) - total_horas) * 60) %>% 
            mutate(fmt = glue::glue("{total_horas}h{round(total_minutos)}")) %>% 
            mutate_at(vars(entrada, saida), strftime, format = "%H:%M", tz = "UTC") %>% 
            rename(tempo_total = fmt)
        # %>% 
        #     select(-timediff, -total_horas, -total_minutos)
    )
}