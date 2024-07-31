/* Functions for constructing instructions stimuli */

function add_para_tag_to_instrt(element, index, array){
    // take a string 'x' and add paragraph tags around it, giving it a unique id
    // designed for the jspsych instructions module
    var el = document.createElement("p");
    el.appendChild(document.createTextNode(element));
    el.className = 'instructionsPara';
    el.id = `instructPage${index+1}`
    debugger
    el.outerHTML
    return el.outerHTML
}

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

function build_end_screen() {

    // Display the link so participants can give themselves SONA credit
    var el = jsPsych.getDisplayElement();
    var a  = document.createElement('a');
    var farewell_paragraph = document.createElement('p');

    var farewell_text = document.createTextNode(farewell_messsage);
    farewell_paragraph.appendChild(farewell_text);
    
    var linkText = document.createTextNode(farewell_link_text);
    a.appendChild(linkText);
    
    // farewell link based on the session
    a.href = farewell_link;
    
    el.appendChild(farewell_paragraph);
    el.appendChild(a);

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