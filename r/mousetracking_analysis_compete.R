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
product1           <- 'Lonsurf.png'    # the filename representing the clients product. The first product serves as the reference.
product2           <- 'Stivarga.png'   # the filename representing second competitor
product3           <- 'Fruzaqla.png'   # the filename representing third competitor

product1_img_loc   <- sprintf('./img/%s', product1) # edit this line based on where your image files are located
product2_img_loc   <- sprintf('./img/%s', product2) # edit this line based on where your image files are located
product3_img_loc   <- sprintf('./img/%s', product3) # edit this line based on where your image files are located

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

raster_read <- function(x){
  # read an image file x into a raster
  require(magick)
  
  image_read(path = x) %>%
    image_fill(., 'none') %>%
    as.raster() -> raster_img
    
  return(raster_img)
}

custom_flip <- function(data, ScreenWidth){
  # this function does the flipping about the center of the screen
  data %>%
    mutate(x = ((x-(ScreenWidth/2))*-1)+(ScreenWidth/2))
}

plot_as_function <- function(mousedata, 
                             prodLeftImg, prodLeftLoc, 
                             prodRightImg, prodRightLoc, 
                             title = 'Title', subtitle = 'Subtitle'){
  
  # plot parameters
  trajectory_line_size <- 1
  aggregate_line_size  <- 2
  window_line_size     <- 1
  window_color         <- 'black'
  notrials_text_size   <- 10
  notrials_text_angle  <- 45
  
  # how many trials fell into this "bin"?
  ntrials <- nrow(mousedata$data)
  
  if(ntrials == 0){
    # blank plot
    ggplot(tibble(x = c(0,1), y = c(1,0)), aes(x = x, y = y)) -> plt
  } else if(ntrials == 1){
    # plot without the average line
    mt_plot(mousedata, use = 'tn_trajectories', return_type = 'mapping') -> plt
  } else {
    # standard plot with the trajectories and the average line. Assumes that the
    # trajectories were normalized first
    mt_plot(mousedata, use = 'tn_trajectories', return_type = 'mapping') +
      mt_plot_aggregate(return_type = 'geom', use = 'tn_trajectories', 
                        mousedata, size = aggregate_line_size) -> plt
  }
  
  # add the rectangle screen outline and the product images to the top right and
  # top left of the plot
  plt +
    annotate('rect', xmin = 0, xmax = ScreenWidth, ymin = 0, ymax = 550, 
             fill = NA, color = window_color, size = window_line_size) +
    annotation_raster(prodLeftImg, 
                      xmin = prodLeftLoc$left, 
                      xmax = prodLeftLoc$right,
                      ymin = prodLeftLoc$top,
                      ymax = -1*prodLeftLoc$bottom, 
                      interpolate = T) +
    annotation_raster(prodRightImg, 
                      xmin = prodRightLoc$left, 
                      xmax = prodRightLoc$right,
                      ymin = prodRightLoc$top,
                      ymax = -1*prodRightLoc$bottom, 
                      interpolate = T) -> plt
  
  # if there are any trials, added dashed lines for the individual trajectories
  if(ntrials > 0){
    plt + geom_path(linewidth = trajectory_line_size, linetype = 'dashed') -> plt
  }
  
  # if there are no trials, add some text indicating this is the case
  if(ntrials == 0){
    plt + annotate(geom = 'text', x = ScreenWidth/2, y = 300, 
                   label = 'No Trials', 
                   size = notrials_text_size, 
                   angle = notrials_text_angle) -> plt
  }
  
  # expand the plot limits, reverse the y-axis, add the "void" theme, add title
  # and subtitle; adjust the title and subtitle so that they are centered over
  # the plot.
  plt +
    expand_limits(x = c(0,NA), y = c(0,NA)) +
    scale_y_continuous(transform = 'reverse') +
    theme_void() +
    labs(title = title, 
         subtitle = str_c(subtitle, str_glue('(n = {ntrials})'), 
                          sep = ' ')) +
    theme(plot.title = element_text(hjust =  0.5), 
          plot.subtitle = element_text(hjust = 0.5)) -> plt
  
  return(plt)
  
}

# import ------------------------------------------------------------------
# importing raw data into R

# using purrr::map_dfr function, import all select csv files into R and
# concatenate them all in one line.
df <- map_dfr(dataFiles, \(x) read_csv(x, show_col_types = FALSE), .id = 'SsID')

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

# custom flip ------------------------------------------------------------------
# What we want to do is to flip all of trajectories for trials where product 1
# is in the top right corner over the center of the screen.

# How wide is the screen? One way we can figure that out is to find the pixel
# location value for the right side of the bounding box for the top right stim
# -- the top right stim is anchored to the right side of the screen by design.
# Assumes that all screens are the same size.
df.targets %>%
  filter(name == '#topRightStim') %>%
  pull(right) %>%
  unique() -> ScreenWidth

assert_that(length(ScreenWidth) == 1, 
            msg = 'Unexpected: all screens are NOT the same width.')

# Take the tidy data, create a list column containing only the mouse tracking
# data. Use a series of purrr::map_if functions to flip the trajectories for
# select trials about the center of the screen in the x-dimension. See
# custom_flip.
df.tidy %>%
  nest(mousedata = c(x,y,t)) %>%
  mutate(mousedata = map_if(mousedata, 
                       topRightButton == product1, 
                       ~custom_flip(.x, ScreenWidth = ScreenWidth))) %>%
  mutate(mousedata = map_if(mousedata, 
                       topLeftButton == product3 & topRightButton == product2,
                       ~custom_flip(.x, ScreenWidth = ScreenWidth))) -> df.flipped

# sort into bins ----------------------------------------------------------
# there should be 6 bins in a full factorial like design:
# 3 alternative forced choice product combinations
# 2 choices (Picked product x or picked product y)

df.flipped %>%
  mutate(containsProd1 = topLeftButton == product1 | topRightButton == product1,
         containsProd2 = topLeftButton == product2 | topRightButton == product2,
         containsProd3 = topLeftButton == product3 | topRightButton == product3) %>%
  mutate(condition = case_when(containsProd1 & containsProd2 ~ 'Prod1_v_Prod2',
                               containsProd1 & containsProd3 ~ 'Prod1_v_Prod3',
                               containsProd2 & containsProd3 ~ 'Prod2_v_Prod3')) %>%
  select(-starts_with('contains')) %>%
  mutate(response_stim = case_when(response == 'topLeft' ~ topLeftButton,
                                   response == 'topRight' ~ topRightButton)) %>%
  mutate(response_prod = case_when(response_stim == product1 ~ 'Prod1',
                                   response_stim == product2 ~ 'Prod2',
                                   response_stim == product3 ~ 'Prod3')) %>%
  unnest(cols = c(mousedata)) -> df.sorted

mt_import_long(df.sorted, xpos_label = 'x', ypos_label = 'y', 
               timestamps_label = 't', mt_id_label = c('SsID', 'trial_index'), 
               verbose = F) %>%
  mt_time_normalize() -> mt_data.tidy

Prod1  <- raster_read(x = product1_img_loc)
Prod2  <- raster_read(x = product2_img_loc)
Prod3  <- raster_read(x = product3_img_loc)

# plot 1 ------------------------------------------------------------------
# Create plot 1:
#   the mouse trajectories for all trials where product 1 is pitted against
#   product 2 and product 1 was selected.

# "mouse tracking data for trials where product 1 was pitted against product 2
# and product 1 was chosen"
mt_data.tidy %>%
  mt_subset(condition == 'Prod1_v_Prod2' & response_prod == 'Prod1') -> mousedata

# the bounding box when product 1 is in the top left corner of the screen.
# Assumes that this is the same for every subject
df.targets %>% 
  filter(name == '#topLeftStim' & stim == product1) %>% 
  slice(1)  %>% 
  select(top,right,bottom,left) %>% 
  as.list() -> Prod1.loc

# the bounding box when product 2 is in the top right corner of the screen
df.targets %>% 
  filter(name == '#topRightStim' & stim == product2) %>% 
  slice(1)  %>% 
  select(top,right,bottom,left) %>% 
  as.list() -> Prod2.loc

plot_as_function(mousedata, Prod1, Prod1.loc, Prod2, Prod2.loc, 
                 title = 'Product 1 vs Product 2',
                 subtitle = 'Selected Product 1') -> plot1

# plot 2 ------------------------------------------------------------------
# Create plot 2:
#   the mouse trajectories for all trials where product 1 is pitted against
#   product 3 and product 1 was selected.


# "mouse tracking data for trials where product 1 was pitted against product 3
# and product 1 was chosen"
mt_data.tidy %>%
  mt_subset(condition == 'Prod1_v_Prod3' & response_prod == 'Prod1') -> mousedata

# "the bound box of product 3 when placed in the top right corner of the screen"
df.targets %>% 
  filter(name == '#topRightStim' & stim == product3) %>% 
  slice(1)  %>% 
  select(top,right,bottom,left) %>% 
  as.list() -> Prod3.loc

# create the plot
plot_as_function(mousedata, Prod1, Prod1.loc, Prod3, Prod3.loc, 
                 title = 'Product 1 vs Product 3',
                 subtitle = 'Selected Product 1') -> plot2

# plot 3 ------------------------------------------------------------------
# Create plot 3:
#   the mouse trajectories for all trials where product 2 is pitted against
#   product 3 and product 2 was selected.

# "mouse tracking data for trials where product 2 was pitted against product 3
# and product 2 was chosen"
mt_data.tidy %>%
  mt_subset(condition == 'Prod2_v_Prod3' & response_prod == 'Prod2') -> mousedata

# "the bound box of product 3 when placed in the top right corner of the screen"
df.targets %>% 
  filter(name == '#topLeftStim' & stim == product2) %>% 
  slice(1)  %>% 
  select(top,right,bottom,left) %>% 
  as.list() -> Prod2.left.loc

# create the plot
plot_as_function(mousedata, Prod2, Prod2.left.loc, Prod3, Prod3.loc, 
                 title = 'Product 2 vs Product 3',
                 subtitle = 'Selected Product 2') -> plot3

# plot 4 ------------------------------------------------------------------

# "mouse tracking data for trials where product 1 was pitted against product 2
# and product 2 was chosen"
mt_data.tidy %>%
  mt_subset(condition == 'Prod1_v_Prod2' & response_prod == 'Prod2') -> mousedata

# create the plot
plot_as_function(mousedata, Prod1, Prod1.loc, Prod2, Prod2.loc, 
                 title = 'Product 1 vs Product 2',
                 subtitle = 'Selected Product 2') -> plot4

# plot 5 ------------------------------------------------------------------

# "mouse tracking data for trials where product 1 was pitted against product 3
# and product 2 was chosen"
mt_data.tidy %>%
  mt_subset(condition == 'Prod1_v_Prod3' & response_prod == 'Prod3') -> mousedata

# create the plot
plot_as_function(mousedata, Prod1, Prod1.loc, Prod3, Prod3.loc,
                 title = 'Product 1 vs Product 3',
                 subtitle = 'Selected Product 3') -> plot5

# plot 6 ------------------------------------------------------------------

# "mouse tracking data for trials where product 1 was pitted against product 3
# and product 2 was chosen"
mt_data.tidy %>%
  mt_subset(condition == 'Prod2_v_Prod3' & response_prod == 'Prod3') -> mousedata

# create the plot
plot_as_function(mousedata, Prod2, Prod2.left.loc, Prod3, Prod3.loc,
                 title = 'Product 2 vs Product 3',
                 subtitle = 'Selected Product 3') -> plot6

# stitched plot -----------------------------------------------------------
# create stitched together plot using the R package "patchwork"

require(patchwork)
(plot1 + plot2 + plot3) / (plot4 + plot5 + plot6) -> patch

# printing the plot object forces R to actually display it
print(patch)

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

# external stats packages
require(emmeans)
require(lme4)
require(lmerTest)
require(pbkrtest)

# join the meta data and measures tables together
# create a new factor "response_leftright" which indicates, for each condition,
# whether the chosen response was the first product in the condition or the
# second. Example: condition: Prod1_v_Prod2, response_leftright: Right would
# indicate a trial where a participant choose product 1 in a forced choice
# between product 1 and product 2.
left_join(mt_measures.df$data, mt_measures.df$measures) %>%
  mutate(response_leftright = case_when(condition == 'Prod1_v_Prod2' & response_prod == 'Prod1' ~ 'left',
                                        condition == 'Prod1_v_Prod2' & response_prod == 'Prod2' ~ 'right',
                                        condition == 'Prod1_v_Prod3' & response_prod == 'Prod1' ~ 'left',
                                        condition == 'Prod1_v_Prod3' & response_prod == 'Prod3' ~ 'right',
                                        condition == 'Prod2_v_Prod3' & response_prod == 'Prod2' ~ 'left',
                                        condition == 'Prod2_v_Prod3' & response_prod == 'Prod3' ~ 'right')) -> analysis_df

# create a basic linear mixed effects model modeling the entire factorial design
# (condition x response_leftright) including random intercepts per participant.
nsubjects <- analysis_df %>% pull(SsID) %>% unique() %>% length()
nlevels   <- analysis_df %>% pull(response_leftright) %>% unique() %>% length()
if(nsubjects == 1){
  if(nlevels == 1){
    lm(AUC~condition, data = analysis_df) -> model.fit
    spec  <- ~condition
    spec1 <- ~condition
  } else {
    lm(AUC ~ condition * response_leftright, data = analysis_df) -> model.fit
    spec  <- ~ condition + response_leftright
    spec1 <- ~ condition | response_leftright
  }
} else {
  lmer(AUC ~ condition * response_leftright + (1|SsID), data = analysis_df) -> model.fit
  spec  <- ~ condition + response_leftright
  spec1 <- ~ condition | response_leftright
}

# Using the package emmeans, create an object that performs all possible
# pairwise comparisons. See the emmeans package documentation for more
# information
emmeans(model.fit, specs = spec, contr = 'pairwise') -> emmeans.obj
print(emmeans.obj)

# create a plot displaying the interaction of condition and response
emmip(emmeans.obj, spec1, CIs = TRUE) +
  theme_classic() +
  theme(axis.title.x = element_blank(),
        axis.title.y = element_blank()) +
  ggtitle('AUC', subtitle = 'Indicator of Indecision') -> pp

print(pp)
