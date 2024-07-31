// initialze jsPsych
var jsPsych = initJsPsych({
    on_finish: build_mousetrack_fig,
    extensions: [
      { type: jsPsychExtensionMouseTracking, params: {minimum_sample_time: 0} }
    ]
  });

// preload stimuli
// jsPsych module that preloads stimuli prior to the start of the experiment
// ensures that there is no delay during trials
var preload = {
  type: jsPsychPreload,
  images: find_unique_stim(stim_list)
}

// enter full screen mode
// forces the participant to enter full screen mode to complete the experiment
var fullscreen = {
  type: jsPsychFullscreen,
  fullscreen_mode: true,
  stimulus: '<p>The experiment will switch to fullscreen mode when you press the button below</p>',
  choices: ['Continue'],
  delay_after: 1000
}

// Navigateable participant instructions
var instructions = {
  type: jsPsychInstructions,
  pages: instructions_pages,
  buttom_label_next: button_label_next,
  button_label_previous: button_label_previous,
  show_clicable_nav: true,
  show_page_number: show_page_number,
  page_label: page_label,
  data: {
    task: 'instructions'
  }
}

// trial instructions
var trial_instrct = {
  type: jsPsychHtmlButtonResponse,
  stimulus: construct_instr_stim,
  choices: ['Start'],
  button_html: construct_instr_buttn,
  prompt: null,
  data: {
    task: 'trial_instructions'
  },
};

// trial
var trial = {
  type: jsPsychHtmlButtonResponse,
  stimulus: construct_trial_stim,
  choices: [jsPsych.timelineVariable('stim1'), jsPsych.timelineVariable('stim2')],
  prompt: null,
  button_html: construct_trial_bttns,
  extensions: [
    {type: jsPsychExtensionMouseTracking, params: {targets: []}}
  ],  
}

// experimental procedure
mouse_track_procedure = {
  timeline: [trial_instrct, trial],
  timeline_variables: stim_list,
}

// run the experiment
jsPsych.run([preload, fullscreen, instructions, mouse_track_procedure]);