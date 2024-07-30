// initialze jsPsych
var jsPsych = initJsPsych({
    on_finish: build_mousetrack_fig,
    extensions: [
      { type: jsPsychExtensionMouseTracking, params: {minimum_sample_time: 0} }
    ]
  });

  var preload = {
    type: jsPsychPreload,
    images: find_unique_stim(stim_list)
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
  
  // fixations
  var fixation = {
    type: jsPsychHtmlKeyboardResponse,
    stimulus: '',
    choices: "NO_KEYS",
    trial_duration: 1,
  }
  
  // experimental procedure
  mouse_track_procedure = {
    timeline: [instruct, trial],
    timeline_variables: stim_list,
  }
  
  // run the experiment
  jsPsych.run([preload, mouse_track_procedure]);