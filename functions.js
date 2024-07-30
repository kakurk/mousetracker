/* Functions for constructing instructions stimuli */

function construct_instr_buttn() {
    return `<button id=buttonStyle>${start_button_text}</button>`
}

function construct_prompt() {
    return `<p id=promptStyle>${prompt_text}</p>`
}

function construct_stim_one() {
    return `<img id=topLeftStim src="${jsPsych.timelineVariable('stim1')}">`
}

function construct_stim_two() {
    return `<img id=topRightStim src="${jsPsych.timelineVariable('stim2')}">`
}

function construct_trial_stim(){
    return `<img id=StimCenter src=${jsPsych.timelineVariable('stimCenter')}></img>`
}

function construct_instr_stim() {
    return construct_stim_one() + construct_stim_two() + construct_prompt()
}

/* Functions for constructing trial stimuli */

function construct_trial_bttns(x) {

    if(jsPsych.timelineVariable('stim1') == x){
        return construct_stim_one()
    } else if(jsPsych.timelineVariable('stim2') == x){
        return construct_stim_two()
    }

}

function build_mousetrack_fig() {

    var mouse_tracking_data = jsPsych.data.get().select('mouse_tracking_data').values;
    var trace = mouse_tracking_data.map((j, idx) => {
      var x = j.map((k) => k.x)
      x = x.map((t) => t - x[0])
      var y = j.map((k) => k.y)
      y = y.map((t) => (t - y[0]) * -1 )
      return {x:x, y:y, type: 'scatter', name: `trial ${idx+1}`}
    })

    content = document.getElementById('jspsych-content');
    Plotly.newPlot(content, trace);

    jsPsych.data.get().localSave('csv','mydata.csv');

  }

  function find_unique_stim(stim_array){
    // find unique stimuli contained within an array of stimuli
    var stim1 = stim_array.map((x) => x.stim1)
    var stim2 = stim_array.map((x) => x.stim2)
    var stim3 = stim_array.map((x) => x.stimCenter)
    var allStim = stim1.concat(stim2).concat(stim3)
    var unique_values = [...new Set(allStim)]
    var unique_values_array = Array.from(unique_values)
    return unique_values_array
  }