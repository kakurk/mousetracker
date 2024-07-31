/* 
  Parameters.
  Edit these parameters to change aspects of how the experiment will run.

  Images are loaded via the stimuli.js file.

*/

// instructions
var instructions_pages    = ['Welcome to the experiment!', 
                             'In this experiment, you will be classifying images as either fruits or veggitables',
                             'For each trial, you will press start when you are ready to begin.',
                             'After clicking start, please click the correct category for the displayed image in the upper right or upper left of the screen.',
                             'Press next when you are ready to begin.'];
var button_label_next     = "Next";
var button_label_previous = "Previous";
var show_page_number      = true;
var page_label            = 'Page';

// prompt
var prompt_text         = 'Is the image a fruit or a vegetable? Please click on your response as quickly and accurately as you can. Press start to begin trial.';

// button
var start_button_text   = 'Start';

// trial timing
var trial_duration      = null;
var response_ends_trial = true;
var time_after_response = null;

// farewell
var farewell_messsage  = "You have completed the experiment. Thank you for participating!";
var farewell_link_text = "Click here to return to the survey.";
var farewell_link      = "https://app.prolific.co/submissions/complete?cc=C995R784";