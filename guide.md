---
output:
  word_document: default
  html_document: default
---
# README

Official Guide to the Healogix's Mouse Tracking Protocol.

This folder contains a template for running an online mouse tracking experiment.

## Files

Below is a table describing what each file is in this directory.

| file | description  | need to edit? |
|--| --| -- |
| data_dictionary.xlsx | a "dictionary" describing what every column of the output data is.  | NO |
| functions.js | javascript file containing custom written functions supporting the experimental protocol. Needs to be uploaded to cognition.run as an "External JS/CSS" | NO | 
| guide.md | this guide. | NO | 
| index.browser.js | code for conducting mouse tracking. Needs to be uploaded to cognition.run as an "External JS/CSS" | NO |
| index.js | code for running the experimental protocol. DO NOT EDIT. Should be copy and pasted to the "Task Code" section of cognition.run | NO |
| parameters.js | javascript code for defining experimental parameters. Edit this to customize the experiment. Needs to be uploaded to cognition.run as an "External JS/CSS". | YES | 
| stimuli.js | javascript code defining the stimuli to use for each trial of the experiment. Needs to be uploaded to cognition.run as an "External JS/CSS". | YES |
| stimuli.xlsx | excel version of the stimuli.js. Lists the stimuli to display on each trial. Each row = single trial. | YES |
| style.css | a cascading style sheet (.css). Controls the "style" of different elements of the experiment. Font size, color, position on the screen, etc. Needs to be uploaded to cognition.run as an "External JS/CSS". | YES |

## Directories

| directory | description  |
|--| --|
| ./data | directory containing an example output dataset.  |
| ./img | directory containing example images from the jsPsych software package. |
| ./r | directory containing R helper and analysis scripts.  |
| ./sound | directory containing example sound files.  |
| ./video | directory containing example video files.  |


## cognition.run

To run a new experiment, complete the following steps:

### Step 1

Create an account with [cognition.run](https://www.cognition.run/).

![](./guide/cognition_run.png)

### Step 2

Sign in to your account.

![](./guide/step2.gif)

### Step 3

Create a new task by selecting "+ New task". Give your new task a name. Hit Save.

![](./guide/step3.gif)

### Step 4

Go to "Source code". Copy and paste the code from the "index.js" file into the "Task Code" section. There should be no need to edit any code contained within this section.

![](./guide/step4.gif)

### Step 5

Upload these files to the "External JS/CSS" section:

| file | description  | need to edit? |
|--| --| -- |
| functions.js | javascript file containing custom written functions supporting the experimental protocol. | NO |
| index.browser.js | code for conducting mouse tracking. | NO |
| parameters.js | javascript code for defining experimental parameters. Edit this to customize the experiment. | YES |
| stimuli.js | javascript code defining the stimuli to use for each trial of the experiment. | YES |
| style.css | a cascading style sheet (.css). Controls the "style" of different elements of the experiement. Font size, color, position on the screen, etc. | YES | 

![](./guide/step5.gif)

### Step 6

Upload relevant stimuli to the "Stimuli" section.

![](./guide/step6.gif)

### Step 7

If you completed Steps 1-7 correctly, you should see a preview of the template experiment in the "Task Preview" section:

![](./guide/step7.gif)

Note: the fullscreen module at the beginning of the experiment does not work in the task preview section of cognition.run. It does work when given to participants. When previewing the template task with the fullscreen module, hit "Esc" on your keyboard to escape out of the fullscreen mode.

### Step 8

Edit these files to customize your experiment:

| file | description  | edit this file? |
|--| --| -- |
| parameters.js | javascript code for defining experimental parameters. Edit this to customize various aspects of the experiment. Parameters are organized by "event" type. | YES |

![](./guide/step8a.gif)

| file | description  | edit this file? |
|--| --| -- |
| stimuli.js | javascript code defining the stimuli to use for each trial of the experiment. Use the R helper script `r/csv_to_json.r` for assistance creating this file. | YES | 

Edit an excel file:

![](./guide/step8b.gif)

Use the R helper script `r/csv_to_json.r` to convert excel --> js:

![](./guide/step8bb.gif)

| file | description  | edit this file? |
|--| -- | -- |
| style.css | a cascading style sheet (.css). Controls the "style" of different elements of the experiement. Font size, color, position on the screen, etc. Basic styles are included in the template. For more advanced options, [I really like this tutorial fromm w3schools](https://www.w3schools.com/css/default.asp). | YES |

![](./guide/step8c.gif)


### Step 9

When you are happy with your edits, replace the files on cognition.run with the files that you edited:

![](./guide/step9a.gif)

Notice that the the changes have been made in the Task Preview:

![](./guide/step9b.gif)

### Step 10

When you are happy with your experiment and you are ready to collect data, return to the "task options" tab. Copy the link and share this link with participants:

![](./guide/step10a.gif)

When participants complete the experiment, data will show up in the "Data collection" section of this page. You can download the data from here:

![](./guide/step10b.gif)
