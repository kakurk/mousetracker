function construct_button() {
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

function construct_both() {
    return construct_stim_one() + construct_stim_two()
}