/* 
Parameters.
Edit this file to change how aspects of how the experiment will run.

  Instructions Page(s) Parameters

    instructions_pages    = a javascript array. Each array element contains a string with text to display on each "page" of an instructions module.
    button_label_next     = a javascript string. Text to display on the button that advances the participant to the next instructions page.
    button_lebel_previous = a javascript string. Text to display on the button that returns the participants to the previous instructions page.
    show_page_number      = a javascript boolean. Should the instructions display what page number the participant is on? true = yes, false = no.
    page_label            = a javascript string. Text to display next to the page number.

  Trial Instructions Parameters

    trial_inst_prompt_text = a javascript string. Text displayed to participants in the middle of the screen prior to the start of each trial. Set to null to display no message.
    start_button_text      = a javascript string. Text to display on the button that starts next the mouse tracking event.

  Trial Parameters

    trial_prompt   = a javascript string. Text displayed underneath the center image/video. Set to null to display no message.
    video_autoplay = a javascript string. Set to "autoplay" to autoplay the centered video stimulus (if it exists). Ignored if no video stimulus. Set as blank (i.e., '') to avoid autoplay.
    video_loop     = a javasript string. Set to "loop" to loop the centered video stimulus (if it exists). Ignored if no video stimulus. Set as blank (i.e, '') to avoid looping.

  Farewell Parameters

    farewell_massage   = a javascript string. Text to display to participant at the very end of the experiment.
    farewell_link_text = a javascript string. Text to display to participants as a link to send them to another webpage.
    farewell_link      = a javascript string. A URL to sent participants to.

*/

// instructions
var instructions_pages    = ['Welcome to the experiment!', 
                             'In this experiment, you will be making precribing decisions.',
                             'For each trial, you will press start when you are ready to begin.',
                             'After clicking start, please click on the image associated with your preferred treatment option.',
                             'Press next when you are ready to begin.'];
var button_label_next     = "Next";
var button_label_previous = "Previous";
var show_page_number      = true;
var page_label            = 'Page';

// trial instructions
var trial_inst_prompt_text = 'Which treatment? Please click on your response as quickly and accurately as you can. Press start to begin trial.'; // can be null
var start_button_text      = 'Start';

// trial
var trial_prompt        = 'Given these two options, which one would you choose?'; // can be null
var video_autoplay      = 'autoplay'; // leave blank to remove autoplay
var video_loop          = 'loop'; // leave blank to remove looping

// farewell
var farewell_messsage  = "You have completed the experiment. Thank you for participating!";
var farewell_link_text = "Click here to return to the survey.";
var farewell_link      = "https://healogix.com/";