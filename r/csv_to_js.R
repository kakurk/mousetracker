# packages used
library(readxl)
library(jsonlite)
library(stringr)

# routine

# ask user to choose the stimuli excel file and the output directory
csv_file  <- file.choose()
outputDir <- choose.dir(caption = 'Choose Folder to Write JavaScript File to.')

# read in the excel file as a tbl
tbl       <- read_excel(path = csv_file)

# create the javascript formatted string
text <- str_c('var stim_list = ', toJSON(tbl))

# write the javascript file for importing into jsPsych
newlyCreatedFile <- file(file.path(outputDir, 'stimuli.js'))
writeLines(text, newlyCreatedFile)
close(newlyCreatedFile)
