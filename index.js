// initialze jsPsych
var jsPsych = initJsPsych({
    on_finish: build_mousetrack_fig,
    extensions: [
      { type: jsPsychExtensionMouseTracking, params: {minimum_sample_time: 0} }
    ]
  });

  // preload
  var preload = {
    type: jsPsychPreload,
    images: find_unique_stim(stim_list)
  }
  
var instructions = {
  type: jsPsychInstructions,
  pages: ['Page 1', 'Page 2'],
  buttom_label_next: "",
  button_label_previous: "",
  show_clicable_nav: true
}

  // instructions
  var instruct = {
    type: jsPsychHtmlButtonResponse,
    stimulus: construct_instr_stim,
    choices: ['Start'],
    button_html: construct_instr_buttn,
    prompt: null,
    data: {
      task: 'instructions'
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
    timeline: [instruct, trial],
    timeline_variables: stim_list,
  }
  
  // run the experiment
  jsPsych.run([preload, instructions, mouse_track_procedure]);