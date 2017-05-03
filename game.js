'use strict';

let game = null; // exported functions
let ram = null;  // game buffer

let context = null;

function draw_circle(x, y, r) {
    context.beginPath();
    context.arc(x, y, r, 0, Math.PI * 2.0, false);
    context.fill();
}


document.body.onload = function() {
    fetch("./game.wasm")
        .then(res => res.arrayBuffer())
        .then(buffer =>  WebAssembly.instantiate(
            buffer, {
                imports: {
                    draw_circle: (x, y, z) => draw_circle(x, y, z)
                }
            }
        ))
        .then(({module, instance}) => {
            let canvas = document.getElementById("screen");
            context = canvas.getContext('2d');
            context.fillStyle = "red";
            context.strokeStyle = "red";
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
    context.clearRect(0, 0, 300, 300);
    instance.exports.update();
    requestAnimationFrame(() => update(instance));
}

