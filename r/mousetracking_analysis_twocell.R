# Master Script for analyzing mouse tracking data
# 
# Written by Kyle Kurkela, kyleakurkela@gmail.com
# Healogix
# 
# Script is set up to perform a "basic" mouse tracking analysis. See individual
# sections for more detail.

# parameters --------------------------------------------------------------
# edit this based on the experimental design

dataFiles          <- choose.files()   # can select data files from multiple subjects or a single subject

# plot parameters

image_map          <- c('Lonsurf.png' = 'Lonsurf.png',
                        'Fruzaqla.png' = 'Fruzaqla.png',
                        'Stivarga.png' = 'Stivarga.png')

trajectory_line_size <- 1
aggregate_line_size  <- 2
window_line_size     <- 1
window_color         <- 'black'
notrials_text_size   <- 10
notrials_text_angle  <- 45

# requirements ------------------------------------------------------------
# This section loads all of the external packages and custom written functions
# that this script relies on.

# External R packages that this script relies on. See help pages for more
# information on each package.

library(tidyverse, warn.conflicts = FALSE)
library(jsonlite, warn.conflicts = FALSE)
library(mousetrap, warn.conflicts = FALSE)
library(magick, warn.conflicts = FALSE)
library(readxl, warn.conflicts = FALSE)
library(assertthat, warn.conflicts = FALSE)
library(ggpattern, warn.conflicts = FALSE)

# custom written helper functions used throughout the script.

find_images <- function(x){
  # parse a json string x into its relevant constituent elements
  
  # stim labels
  str_extract_all(x, '(?<=(id\\=)).*(?= src)') %>%
    unlist() -> stimNames
  
  # stim img names
  str_extract_all(x, '(?<=src\\=).*(?=\\><)') %>%
    unlist() -> stimFiles
  
  tibble(stimNames, stimFiles) %>%
    pivot_wider(names_from = stimNames, values_from = stimFiles) -> foundImgs
  
  return(foundImgs)
  
}

tidy_mouse <- function(x){
  # tidy the eye tracking data
  # data originally a string in JSON format
  
  require(jsonlite)
  
  parse_json(x, simplifyVector = TRUE) %>%
    as_tibble() -> parsedJ
  
  return(parsedJ)
  
}

tidy_mouse_target <- function(x){
  # takes a json formatted string as input...
  # 
  # json formatted string is expected to look something like this:
  #   {"#topLeftStim":{"x":0,"y":0,"width":192,"height":87,"top":0,"right":192,"bottom":87,"left":0},"#topRightStim":{"x":876,"y":0,"width":192,"height":62,"top":0,"right":1068,"bottom":62,"left":876}}
  # 
  # ...and turns it into a tidy rectangular dataframe which should look something like this:
  #
  #   trial_index name              x     y width height   top right bottom  left
  #   1           #topLeftStim      0     0   192     87     0   192     87     0
  #   1           #topRightStim   876     0   192     62     0  1068     62   876   
  
  parse_json(x, simplifyVector = FALSE) %>% 
    enframe() %>% 
    mutate(value = map(value, enframe)) %>% 
    unnest(cols = c(value), names_sep = '_') %>% 
    mutate(value_value = map_dbl(value_value, ~.x)) %>% 
    pivot_wider(names_from = value_name, values_from = value_value) -> parsedJ
  
  return(parsedJ)
  
}

plot_as_function <- function(mousedata, 
                             title = 'Title', 
                             subtitle = 'Subtitle'){

  df %>% 
    filter(trial_type == 'browser-check') %>% 
    select(width,height) %>% 
    as.list() -> window_size
  
mousedata %>% 
  mt_reshape(use = 'tn_trajectories', 
             use2_variables = c('response', 'topLeftButton', 'topRightButton')) -> base.df

mousedata %>%
  mt_reshape(use = 'tn_trajectories', 
             use2_variables = c('response', 'topLeftButton', 'topRightButton'), 
             aggregate = T) -> agg.df

mousedata$data %>% 
  select(ends_with('topRightButton'), ends_with('topLeftButton')) %>%
  distinct() -> imgs.df

  ggplot(data = imgs.df, mapping = aes(xmin = left_topLeftButton,
                                       xmax = right_topLeftButton,
                                       ymin = bottom_topLeftButton,
                                       ymax = top_topLeftButton,
                                       pattern_filename = topLeftButton)) + 
    annotate('rect', 
             xmin      = 0, 
             xmax      = window_size$width, 
             ymin      = 0, 
             ymax      = window_size$height, 
             fill      = NA, 
             color     = window_color, 
             linewidth = window_line_size) +    
    geom_rect_pattern(pattern = 'image',
                      pattern_type = 'fit', alpha = 0) +
    geom_rect_pattern(pattern = 'image', pattern_type = 'fit', alpha = 0, 
                      mapping = aes(xmin = left_topRightButton,
                                    xmax = right_topRightButton,
                                    ymin = bottom_topRightButton,
                                    ymax = top_topRightButton,
                                    pattern_filename = topRightButton)) +
    scale_pattern_filename_manual(values = image_map) +  
    geom_path(data = base.df, mapping = aes(x = xpos, y = ypos, color = response,
                                            xmin = NULL, xmax = NULL, ymin = NULL, 
                                            ymax = NULL, pattern_filename = NULL),
              linetype = 'dotted') +
    geom_path(data = agg.df, mapping = aes(x = xpos, y = ypos, color = response,
                                           xmin = NULL, xmax = NULL, ymin = NULL, 
                                           ymax = NULL, pattern_filename = NULL)) +
    facet_grid(cols = vars(topLeftButton), rows = vars(topRightButton)) -> plt
  
  # expand the plot limits, reverse the y-axis, add the "void" theme, add title
  # and subtitle; adjust the title and subtitle so that they are centered over
  # the plot.
  plt +
    expand_limits(x = c(0,NA), y = c(0,NA)) +
    scale_y_continuous(transform = 'reverse') +
    labs(title = title) +
    theme(plot.title = element_text(hjust =  0.5), 
          plot.subtitle = element_text(hjust = 0.5)) -> plt
  
  return(plt)
  
}

# import ------------------------------------------------------------------
# importing raw data into R

# using purrr::map_dfr function, import all select csv files into R and
# concatenate them all in one line.
df <- map_dfr(dataFiles, \(x) read_csv(x, show_col_types = FALSE, 
                                       col_types = cols(recorded_at = col_character())), 
              .id = 'SsID')

# tidy --------------------------------------------------------------------

# remove rows that do have mouse tracking data; select only relevant columns
df %>%
  filter(!is.na(mouse_tracking_data)) %>%
  select(any_of(c('subjectID', 'SsID')), rt, stimulus, response,
         topLeftButton, topRightButton, trial_index,
         time_elapsed, mouse_tracking_data) -> df.int

# extract image filenames from the "stimulus" columns
df.int %>%
  mutate(stimulus = map(stimulus, find_images)) %>%
  unnest(cols = c(stimulus)) -> df.int

# turn mouse tracking data into a usable, rectangular format. make "response" a
# factor with sensible labels representing the actual choice made in English
# make trial_index count the trial numbers instead of the jsPsych event numbers
df.int %>%
  mutate(mouse_tracking_data = map(mouse_tracking_data, tidy_mouse)) %>%
  mutate(response = factor(response, 
                           levels = c(0,1), 
                           labels = c('topLeft', 'topRight'))) %>%
  mutate(trial_index = factor(trial_index, 
                              labels = seq(1, 
                                           length(unique(trial_index)), 
                                           1))) %>%
  unnest(cols = c(mouse_tracking_data)) %>%
  select(-event, -any_of('NA')) -> df.tidy

# take original data, remove rows that do not have mouse targets data, select
# only relevant columns, force trial_index to count trials instead of jspsych
# events.
df %>%
  filter(!is.na(mouse_tracking_targets)) %>%
  select(any_of(c('subjectID', 'SsID')), trial_index, 
         mouse_tracking_targets, topLeftButton, topRightButton) %>%
  mutate(trial_index = factor(trial_index, 
                              labels = seq(1, 
                                           length(unique(trial_index)), 
                                           1))) -> df.int

# add stimuli information to the targets data; turn the json formatted data into
# rectangular data; make a new column called stim which indicates which stimulus
# went where (i.e., stim1 = topLeft; stim2 = topRight)
df.int %>%
  mutate(mouse_tracking_targets = map(mouse_tracking_targets, 
                                      tidy_mouse_target)) %>%
  unnest(mouse_tracking_targets) %>%
  mutate(stim = case_when(name == '#topLeftStim' ~ topLeftButton,
                          name == '#topRightStim' ~ topRightButton)) %>%
  select(-topLeftButton, -topRightButton) -> df.targets

df.targets %>% 
  mutate(centerX = (left + right) / 2, centerY = (top + bottom) / 2) %>% 
  mutate(name = case_when(name == '#topLeftStim' ~ 'topLeftButton',
                          name == '#topRightStim' ~ 'topRightButton')) -> df.targets

df.targets %>%
  pivot_wider(id_cols = all_of(c('SsID', 'trial_index')), 
              names_from = name, 
              values_from = -all_of(c('SsID', 'trial_index', 'name'))) -> df.targets

left_join(df.tidy, df.targets, 
          by = c('SsID', 'trial_index', 
                 'topLeftButton' = 'stim_topLeftButton', 
                 'topRightButton' = 'stim_topRightButton')) -> df.tidy

# sort into bins ----------------------------------------------------------

mt_import_long(df.tidy, xpos_label = 'x', ypos_label = 'y', 
               timestamps_label = 't', mt_id_label = c('SsID', 'trial_index'), 
               verbose = F) %>%
  mt_time_normalize() -> mt_data.tidy

# plot 1 ------------------------------------------------------------------
# Create plot 1:
#   the mouse trajectories for all trials where product 1 is pitted against
#   product 2 and product 1 was selected.

plot_as_function(mt_data.tidy, 
                 title = 'Lonsurf vs All',
                 subtitle = 'Selected Product 1') -> p

print(p)

# Analysis ----------------------------------------------------------------
# Automatically calculate a set of "standard" mouse tracking dependent
# variables. They include AUC, max deviation.

mt_data.tidy %>%
  mt_derivatives() %>% # timepoint-by-timepoint dist, velocity, acceleration
  mt_angles() %>% # timepoint-by-timpoint angle
  mt_measures() -> mt_measures.df # AUC, xflips

# stats -------------------------------------------------------------------
# This section performs basic statistics. This section should be customized to
# suit the needs of the experimental design.

# join the meta data and measures tables together
# create a new factor "response_leftright" which indicates, for each condition,
# whether the chosen response was the first product in the condition or the
# second. Example: condition: Prod1_v_Prod2, response_leftright: Right would
# indicate a trial where a participant choose product 1 in a forced choice
# between product 1 and product 2.
left_join(mt_measures.df$data, mt_measures.df$measures) -> analysis_df

analysis_df %>%
  select(-contains('_top')) %>%
  select(SsID, rt, response, topLeftButton, topRightButton, trial_index, time_elapsed,
         MD_above, AUC) -> analysis_tidy

write_csv(analysis_tidy, file = 'output.csv')
