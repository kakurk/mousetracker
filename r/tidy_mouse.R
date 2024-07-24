tidy_mouse <- function(x){
  # tidy the eye tracking data
  # data originally a string in JSON format

  require(jsonlite)

  parse_json(x, simplifyVector = TRUE) %>%
    as_tibble() -> parsedJ

  return(parsedJ)

}