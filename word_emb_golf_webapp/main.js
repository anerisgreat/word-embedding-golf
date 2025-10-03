import { ungzip } from 'https://cdn.jsdelivr.net/npm/pako@2.1.0/dist/pako.esm.mjs';

const DIST_PER_SECOND = 1;

const GLOW_DURATION = 0.5;
const GLOW_TIMER_TICK = 0.05;

function get_graph_from_gzip_str(gzip_str){
    //https://stackoverflow.com/questions/69179292/i-want-to-decompress-a-gzip-string-with-javascript
    const gziped_data = atob(gzip_str);
    const gziped_data_byte_array = Uint8Array.from(gziped_data,
                                                    c => c.charCodeAt(0));
    const ungziped_data = ungzip(gziped_data_byte_array);
    const ungziped_json = new TextDecoder().decode(ungziped_data);
    return JSON.parse(ungziped_json);
}

function get_graph(){
    return get_graph_from_gzip_str(document.getElementById('graph_gzip_base64').innerHTML);
}

const GRAPH_DICT = get_graph();

class GameState {
    constructor() {
        if (GameState._instance) {
            return GameState._instance;
        }

        GameState._instance = this;

    }

    init_game(){
        let all_words = Object.keys(GRAPH_DICT);
        this.source_word = _random_element(all_words);
        this.target_word = _random_element(all_words);
        this.current_word = this.source_word;
        this.current_path = [this.current_word];
        this.update_time = 0;
        this.just_updated_path = false;
        this.button_glow_amounts = new Array(20).fill(0.0);
    }

    static get_instance() {
        return GameState._instance || new GameState();
    }

    //Ticks button glow makes dimmer
    static tick_button_glow() {
        let gs = GameState.get_instance();
        for(let i = 0; i < 20; ++i){
            gs.button_glow_amounts[i] = Math.max(
                0.0, gs.button_glow_amounts[i] - GLOW_TIMER_TICK / GLOW_DURATION);
        }
    }

    //Returns button glow for button number i
    get_button_glow(i) {
        return this.button_glow_amounts[i];
    }

    set_button_glow(i, x) {
        this.button_glow_amounts[i] = x;
    }

    get_current_path() {
        return this.current_path;
    }

    step_word_game(word){
        this.current_word = word;

        if(this.target_word == word){
            // init_game(); //Completion, game won!
            this.init_game();
            this.just_updated_path = false;
        } else {
            this.update_time = new Date();
            this.just_updated_path = true; //Used for drawing line

            this.current_path.push(this.current_word);
        }
    }

    unset_just_updated_path(){
        this.just_updated_path = false;
    }
}

//Updates word glow for all buttons
function update_word_glow(){
    const root = document.documentElement;
    let glow_color = getComputedStyle(root).getPropertyValue('--glow-color');
    for(let i = 0; i < 20; ++i){
        let button_elem = document.getElementById("neighbor-btn-" + i);
        let gs = GameState.get_instance();
        let glow_alpha_hex = (Math.floor(gs.get_button_glow(i)*255)).toString(16);
        button_elem.style.boxShadow = 'inset 0px 0px 3px 1px ' + glow_color + glow_alpha_hex;
    }
}

//Redraws the path on the canvas
function update_path(){
    const canvas = document.getElementById("canvas");
    const ctx = canvas.getContext("2d");
    const dpr = window.devicePixelRatio || 1;

    //Canvas init
    canvas.width = canvas.clientWidth * dpr;
    canvas.height = canvas.clientHeight * dpr;
    ctx.setTransform(1, 0, 0, 1, 0, 0); // Reset transformations
    ctx.scale(dpr, dpr);

    const canvas_height = canvas.height;
    const canvas_width = canvas.width;

    ctx.lineWidth = 1;
    //Clear
    ctx.clearRect(0, 0, canvas_width, canvas_height);


    //Game state
    let gs = GameState.get_instance();
    var cc = GRAPH_DICT[gs.current_path[0]]['tsne_emb'];
    ctx.moveTo(cc[0]*canvas_width, cc[1] * canvas_height);
    ctx.beginPath();

    //Drawing whole path
    for(let i = 0; i < gs.current_path.length - 1; ++i){
        cc = GRAPH_DICT[gs.current_path[i]]['tsne_emb'];
        ctx.lineTo(cc[0]*canvas_width, cc[1] * canvas_height);
    }
    var current_word_coords = null;

    if(gs.just_updated_path){
        if(gs.current_path.length > 1){
            // Drawing the last leg as 'animated'
            let cca = GRAPH_DICT[gs.current_path[gs.current_path.length - 1]]['tsne_emb'];
            let ccb = GRAPH_DICT[gs.current_path[gs.current_path.length - 2]]['tsne_emb'];

            // Coordinates of last line segment
            let ccax = cca[0];
            let ccbx = ccb[0];
            let ccay = cca[1];
            let ccby = ccb[1];

            // Delta X, delta Y
            let ccxd = ccax - ccbx;
            let ccyd = ccay - ccby;

            // Distance of last leg
            let total_traverse_len = Math.sqrt(ccxd * ccxd + ccyd * ccyd);

            // Getting time passed since last update to know how far to draw
            let current_time = new Date();
            let milliseconds_passed = (current_time - gs.update_time);

            let target_traverse_dist = (DIST_PER_SECOND / 1000 )* (milliseconds_passed);
            var target_dist_as_frac = target_traverse_dist / total_traverse_len;
            //If we've already finished the line
            if(target_dist_as_frac > 1){
                target_dist_as_frac = 1;
                gs.unset_just_updated_path();
            }

            let ccx = ccbx + ccxd * target_dist_as_frac;
            let ccy = ccby + ccyd * target_dist_as_frac;
            current_word_coords = [ccx, ccy];
            ctx.lineTo(ccx*canvas_width, ccy * canvas_height);
        } else {
            gs.unset_just_updated_path();
        }
    } else {
        // If we've finished updating, and just wnat to draw last line as is
        current_word_coords = GRAPH_DICT[gs.current_path[gs.current_path.length - 1]]['tsne_emb'];
        ctx.lineTo(current_word_coords[0]*canvas_width, current_word_coords[1] * canvas_height);

    }
    ctx.stroke();

    const root = document.documentElement;
    const source_color = getComputedStyle(root).getPropertyValue('--source-color');
    const target_color = getComputedStyle(root).getPropertyValue('--target-color');

    // Source dot
    ctx.beginPath();
    cc = GRAPH_DICT[gs.source_word]['tsne_emb'];
    ctx.arc(cc[0]*canvas_width, cc[1]*canvas_height, 5, 0, 2 * Math.PI);
    ctx.fillStyle = source_color;
    ctx.fill()

    // Dest dot
    ctx.beginPath();
    cc = GRAPH_DICT[gs.target_word]['tsne_emb'];
    ctx.arc(cc[0]*canvas_width, cc[1]*canvas_height, 5, 0, 2 * Math.PI);
    ctx.fillStyle = target_color;
    ctx.fill()

    // Current dot
    ctx.beginPath();
    cc = GRAPH_DICT[gs.current_word]['tsne_emb'];
    ctx.arc(current_word_coords[0]*canvas_width,
            current_word_coords[1]*canvas_height, 2, 0, 2 * Math.PI);
    ctx.fillStyle = "#0000FF";
    ctx.stroke()
}


function _random_element(arr){
    let i = Math.floor(Math.random() * arr.length);
    return arr[i];
}

function update_word_buttons(word){
    if(word in GRAPH_DICT){
        var neighbors = GRAPH_DICT[word]['neighbors'];
        for(let i = 0; i < 20; ++i){
            let buttonElem = document.getElementById("neighbor-btn-" + i);
            buttonElem.innerHTML = neighbors[i];
            buttonElem.dataset.word = neighbors[i];
        }
    }
}

export function word_button_callback(elem){
    let word = elem.dataset.word;
    GameState.get_instance().step_word_game(word);
    update_word_buttons(word);
    update_word_state();
}

function update_word_state(){
    let gs = GameState.get_instance();

    document.getElementById("source").innerHTML = gs.source_word;
    document.getElementById("current").innerHTML = gs.current_word;
    document.getElementById("target").innerHTML = gs.target_word;

    update_path();
}

export function setup() {
    let gs = GameState.get_instance();
    gs.init_game();
    setInterval(update_path, 50);
    setInterval(GameState.tick_button_glow, 50);
    setInterval(update_word_glow, 50);
    update_word_buttons();
    update_word_state();
}

function _reconstruct_shortest_path(parent_map, start_node, target_node) {
    let path = [];
    let current_node = target_node;

    while (current_node !== null) {
        path.unshift(current_node); // Add to the beginning to get correct order
        current_node = parent_map.get(current_node);
    }

    // Check if the path actually starts with the start_node
    if (path[0] === start_node) {
        return path;
    } else {
        return null; // Target was found but path reconstruction failed (e.g., target not reachable from start)
    }
}

function _find_shortest_path(graph, start_node, target_node) {
    if (!graph[start_node] || !graph[target_node]) {
        return null; // Start or target node not in graph
    }

    let queue = [];
    let visited = new Set();
    let parent_map = new Map(); // Stores {child: parent}

    queue.push(start_node);
    visited.add(start_node);
    parent_map.set(start_node, null); // Start node has no parent

    while (queue.length > 0) {
        let current_node = queue.shift();

        if (current_node === target_node) {
            return _reconstruct_shortest_path(parent_map, start_node, target_node);
        }

        for (let neighbor of graph[current_node]['neighbors']) {
            if (!visited.has(neighbor)) {
                visited.add(neighbor);
                parent_map.set(neighbor, current_node);
                queue.push(neighbor);
            }
        }
    }

    return null; // Target not reachable
}

export function hint_callback(){
    let gs = GameState.get_instance();
    let path = _find_shortest_path(GRAPH_DICT, gs.current_word, gs.target_word);

    let next_word = path[1];
    var found = false;
    for(let i = 0; i < 20 && !found; ++i){
        let button_elem = document.getElementById("neighbor-btn-" + i);
        if(button_elem.innerHTML == next_word){
            found = true;
            gs.set_button_glow(i, 1.0);
        }
    }
}
