(module
    (func $draw_circle (import "imports" "draw_circle") (param f32 f32 f32))
    (memory (export "ram") 1)

    (global $player_x (mut f32) (f32.const 100))
    (global $player_y (mut f32) (f32.const 100))

    (func $update (export "update")
        (call $move_player)

        (call $draw_circle (get_global $player_x) (get_global $player_y) (f32.const 30))
    )

    (func $move_player

        (if (i32.load8_u (i32.const 293)) ;; left key pressed
            (then
               (set_global $player_x (f32.sub (get_global $player_x) (f32.const 5)))
            )
        )

        (if (i32.load8_u (i32.const 295)) ;; right key pressed
            (then
               (set_global $player_x (f32.add (get_global $player_x) (f32.const 5)))
            )
        )

        (if (i32.load8_u (i32.const 294)) ;; up key pressed
            (then
               (set_global $player_y (f32.sub (get_global $player_y) (f32.const 5)))
            )
        )

        (if (i32.load8_u (i32.const 296)) ;; down key pressed
            (then
               (set_global $player_y (f32.add (get_global $player_y) (f32.const 5)))
            )
        )
    )
)


