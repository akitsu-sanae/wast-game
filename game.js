'use strict';

let game = null; // exported functions
let ram = null;  // game buffer

let context = null;

function draw_player(x, y) {
    context.fillStyle = "rgba(100, 100, 160, 200)";
    context.beginPath();
    context.arc(x, y, 30, 0, Math.PI * 2.0, false);
    context.fill();
    context.fillRect(x-7.5, y-40, 15, 80);
    context.fillRect(x-37.5, y-30, 15, 80);
    context.fillRect(x+22.5, y-30, 15, 80);
}

function draw_shot(x, y) {
    context.fillStyle = "rgba(100, 120, 200, 200)";
    context.beginPath();
    context.arc(x, y, 10, 0, Math.PI * 2.0, false);
    context.fill();
}

function draw_enemy(x, y) {
    context.fillStyle = "rgba(250, 150, 150, 200)";
    context.beginPath();
    context.arc(x, y, 40, 0, Math.PI * 2.0, false);
    context.fill();
}

document.body.onload = function() {
    fetch("./game.wasm")
        .then(res => res.arrayBuffer())
        .then(buffer =>  WebAssembly.instantiate(
            buffer, {
                imports: {
                    draw_player: (x, y) => draw_player(x, y),
                    draw_shot: (x, y) => draw_shot(x, y),
                    draw_enemy: (x, y) => draw_enemy(x, y),
                    sin: (angle) => Math.sin(angle),
                    cos: (angle) => Math.cos(angle),
                    console: (i) => console.log(i)
                }
            }
        ))
        .then(({module, instance}) => {
            let canvas = document.getElementById("screen");
            context = canvas.getContext('2d');
            context.globalAlpha = 0.7;
            context.globalCompositeOperation = "screen";

            new WebAssembly.Memory({initial: 905});
            ram = new Uint8Array(instance.exports.ram.buffer);

            /*
             * ram[300 + 0] ... left key
             * ram[300 + 1] ... up key
             * ram[300 + 2] ... right key
             * ram[300 + 3] ... down key
             * ram[300 + 4] ... z key
             */
            document.onkeydown = e => {
                switch (e.keyCode) {
                case 37: // left
                    ram[900 + 0] = 1;
                    break;
                case 38: // up
                    ram[900 + 1] = 1;
                    break;
                case 39: // right
                    ram[900 + 2] = 1;
                    break;
                case 40: // down
                    ram[900 + 3] = 1;
                    break;
                case 90: // z
                    ram[900 + 4] = 1;
                    break;
                }
            };

            document.onkeyup = e => {
                switch (e.keyCode) {
                case 37: // left
                    ram[900] = 0;
                    break;
                case 38: // up
                    ram[900 + 1] = 0;
                    break;
                case 39: // right
                    ram[900 + 2] = 0;
                    break;
                case 40: // down
                    ram[900 + 3] = 0;
                    break;
                case 90: // z
                    ram[900 + 4] = 0;
                    break;
                }
            };
            update(instance);
        });
}

function update(instance) {
    context.clearRect(0, 0, 640, 640);
    instance.exports.update();
    ram[904] = 0; // z key
    requestAnimationFrame(() => update(instance));
}

