# Master Script for analyzing mouse tracking data
# 
# Written by Kyle Kurkela, kyleakurkela@gmail.com
# Healogix
#
# Script is set up to perform a "basic" mouse tracking analysis. See individual
# sections for more detail.

# requirements ------------------------------------------------------------
# External R packages that this script relies on. See help pages for more 
# information on each package.

library(tidyverse)
library(jsonlite)
library(mousetrap)
library(readbulk)

# import ------------------------------------------------------------------
# importing raw data into R
# select the appropriate data files interactively

dataFiles  <- choose.files()
df         <- map_dfr(dataFiles, \(x) read_csv(x, show_col_types = FALSE))

# tidy --------------------------------------------------------------------
# cleaning the data up. Includes removing events that do not have mouse tracking
# data, selecting relevant columns, extracting key info from columns formatted
# as JSON strings (mouse_tracking_data, stimulus), reformatting columns for
# clarity (trial_index, response). See the functions find_images.R and
# tidy_mouse.R for more information on JSON -> R conversion.

df %>%
  filter(!is.na(mouse_tracking_data)) %>%
  select(rt, stimulus, response, trial_index, time_elapsed, mouse_tracking_data) %>%
  mutate(stimulus = map(stimulus, find_images)) %>%
  mutate(mouse_tracking_data = map(mouse_tracking_data, tidy_mouse)) %>%
  mutate(response = factor(response, labels = c('topeLeft', 'topRight'))) %>%
  mutate(trial_index = factor(trial_index, labels = seq(1, nrow(.), 1))) %>%
  unnest(cols = c(stimulus, mouse_tracking_data)) -> df

# import ------------------------------------------------------------------
# import into mousetrap package. Assumes data is in a "long" format -- i.e., one
# time point per row, with columns for the x pos, y pos, time, and trial number.

mt_import_long(df, 
               xpos_label = 'x', 
               ypos_label = 'y', 
               timestamps_label = 't', 
               mt_id_label = 'trial_index', 
               verbose = FALSE) -> mt_df

# Geometric processing ----------------------------------------------------
# Geometric preprocessing of the data. Some common preprocessing operations
# include: 
# 
#   symmetric remapping -- mapping trajectories that go up and to
#     the right to go up and to the left.
#
#   aligning start/end --. making sure that all trajectories start at
#     0,0 and end at 1,1 in coordinate space
#
#   normalizing time -- some trials take longer than others and thus have more 
#     time points. This normalizes trials so that they all have the same number 
#     of time points

mt_df %>%
  mt_remap_symmetric() %>%
  mt_align_start_end() %>%
  mt_time_normalize() -> mt_df

# Analysis ----------------------------------------------------------------
# Automatically calculate a set of "standard" mouse tracking dependent
# variables. They include AUC, max deviation.

mt_df %>%
  mt_measures() -> mt_df

# plotting ----------------------------------------------------------------
# Create a basic plot of the data. This plot can be customized using ggplot2.
# The "basic" plot includes individual trajectories as thin lines and average
# trajectory as a bolded line.

mt_plot(mt_df) +
mt_plot_aggregate(mt_df, 
                  use = 'tn_trajectories', 
                  return_type = 'geom', 
                  size = 2) -> fig

print(fig)

# stats -------------------------------------------------------------------
# This section performs basic statistics. This section should be customized to
# suit the needs of the experimental design. Here I assume you perform a
# one-sample t-test testing the null hypothesis that AUC is equal to 0.

t.test(formula = AUC~1, data = mt_df$measures, mu = 0)
