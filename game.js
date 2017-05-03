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

document.body.onload = function() {
    fetch("./game.wasm")
        .then(res => res.arrayBuffer())
        .then(buffer =>  WebAssembly.instantiate(
            buffer, {
                imports: {
                    draw_player: (x, y) => draw_player(x, y),
                    draw_shot: (x, y) => draw_shot(x, y),
                }
            }
        ))
        .then(({module, instance}) => {
            let canvas = document.getElementById("screen");
            context = canvas.getContext('2d');
            context.globalAlpha = 0.7;
            context.globalCompositeOperation = "screen";

            new WebAssembly.Memory({initial: 512 / 4});
            ram = new Uint8Array(instance.exports.ram.buffer);
            document.onkeydown = e => {
                ram[e.keyCode + 256] = 1;
            };
            document.onkeyup = e => {
                ram[e.keyCode + 256] = 0;
            };
            update(instance);
        });
}

function update(instance) {
    context.clearRect(0, 0, 640, 640);
    instance.exports.update();
    requestAnimationFrame(() => update(instance));
}

