library(dplyr)
library(purrr)
library(tidyr)
library(stringr)
library(magrittr)
library(lubridate)

PATTERNS <- list(
    ENTERING = c("entrada", "entrando", "entrei", "entrou"),
    LEAVING = c("saida", "saindo", "sai", "saiu"),
    YESTERDAY = "ontem \\d{1,2}:\\d{2}",
    DMYHM = "\\d{1,2}/\\d{1,2}\\d{4} \\d{1,2}:\\d{2}",
    HM = "\\d{1,2}:\\d{2}"
)

str_search <- function(string, term) {
    return(str_match(string = string, term)[1, 2])
}

check_ts_correction <- function(msg) {
    return(
        case_when(
            str_detect(msg, PATTERNS$YESTERDAY) ~ "full_y",
            str_detect(msg, PATTERNS$DMYHM) ~ "full",
            str_detect(msg, PATTERNS$HM) ~ "partial",
            TRUE ~ "none"
        )
    )
}

timestamp_correction <- function(ts, msg) {
    corrected <- ts
    
    correction_type <- check_ts_correction(msg)
    
    if (correction_type == "full") {
        corrected <- msg %>%
                str_search(paste0("(", PATTERNS$DMYHM, ")")) %>% 
                ymd_hms()

    } else if (!correction_type == "none") {
        if (correction_type == "full_y") {
            corrected <- corrected - days(1)
        }
        
        replace_time <- msg %>%
            str_search(paste0("(", PATTERNS$HM, ")")) %>% 
            hm()
        
        corrected <- corrected %>% 
            `hour<-`(hour(replace_time)) %>% 
            `minute<-`(minute(replace_time))
    }
    
    return(corrected)
}

identify_entities <- function(txt) {
    ts <- as_datetime(str_search(txt, "^(.*) -"))
    
    if (is.na(ts)) {
        ts <- as_datetime(str_search(txt, "^(.*) -"), format = "%m/%d/%y, %H:%M")
    }
    
    message_content <- txt %>%
        str_search(": (.*)$") %>% 
        tolower() %>% 
        iconv(from = "UTF-8", to = "ASCII//TRANSLIT")

    return(
        list(
            ts = ts,
            nome = str_replace(str_search(txt, "- (.*):"), ":.*", ""),
            mensagem = message_content,
            acao = case_when(
                message_content %in% PATTERNS$ENTERING | 
                    str_detect(
                        message_content,
                        paste0(PATTERNS$ENTERING, collapse = "|")
                    ) 
                ~ "entrada",
                message_content %in% PATTERNS$LEAVING |
                    str_detect(
                        message_content,
                        paste0(PATTERNS$LEAVING, collapse = "|")
                    )
                ~ "saida",
                TRUE ~ "outro"
            )
        )
    )
}

wpp_to_timetable <- function(path) {
    timetable <- path %>% 
        readLines() %>% 
        map_df(identify_entities) %>% 
        filter(!is.na(nome)) %>% 
        filter(!acao == "outro") %>% 
        mutate(corrected_ts = modify2(ts, mensagem, timestamp_correction)) %>% 
        mutate(data = as_date(corrected_ts))
    
    entries <- timetable %>% 
        group_by(data, nome, acao) %>% 
        filter(acao == "entrada") %>% 
        filter(corrected_ts == min(corrected_ts))

    exits <- timetable %>% 
        group_by(data, nome, acao) %>%
        filter(acao == "saida") %>% 
        filter(corrected_ts == max(corrected_ts))
    
    return(
        entries %>% 
            bind_rows(exits) %>% 
            arrange(data) %>% 
            select(-mensagem, -ts) %>%
            pivot_wider(names_from = acao, values_from = corrected_ts) %>%
            group_by(nome, data) %>%
            arrange(data) %>%
            mutate(timediff = difftime(saida, entrada, units = "hours")) %>%
            mutate(total_horas = floor(as.numeric(timediff))) %>%
            mutate(total_minutos = (as.numeric(timediff) - total_horas) * 60) %>%
            mutate(fmt = glue::glue("{total_horas}h{round(total_minutos)}")) %>%
            mutate_at(vars(entrada, saida), strftime, format = "%H:%M", tz = "UTC") %>%
            rename(tempo_total = fmt) %>%
            mutate(mes = month(data)) %>%
            mutate(ano = year(data))
    )
}
