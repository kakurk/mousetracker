find_images <- function(x){
   # parse a json string x into its relevant constituent elements
   require(jsonlite)
   parsedJson <- parse_json(x, simplifyVector = TRUE)
   
   # stim labels
   str_extract_all(parsedJson, '(?<=(id\\=)).*(?= src)') %>%
     unlist() -> stimNames
   
   # stim img names
   str_extract_all(parsedJson, '(?<=src=.).*(?=\\">)') %>%
     unlist() -> stimFiles
   
   tibble(stimNames, stimFiles) %>%
     pivot_wider(names_from = stimNames, values_from = stimFiles) -> foundImgs
   
   return(foundImgs)

 }