(module
    (func $draw_circle (import "imports" "draw_circle") (param f32 f32 f32))
    (memory (export "ram") 1)

    (global $player_x (mut f32) (f32.const 100))
    (global $player_y (mut f32) (f32.const 100))
    (global $shot_x (mut f32) (f32.const 0))
    (global $shot_y (mut f32) (f32.const 0))
    (global $is_shot_alive (mut i32) (i32.const 0))

    (func $update (export "update")
        (call $move_player)

        (call $draw_circle (get_global $player_x) (get_global $player_y) (f32.const 30))

        (call $shot_update)
        (if (i32.eq (get_global $is_shot_alive) (i32.const 1))
            (then
                (call $draw_circle (get_global $shot_x) (get_global $shot_y) (f32.const 15))
            )
        )
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

        (if (f32.le (get_global $player_x) (f32.const 0))
            (then
                (set_global $player_x (f32.const 0))
            )
        )

        (if (f32.gt (get_global $player_x) (f32.const 640))
            (then
                (set_global $player_x (f32.const 640))
            )
        )

        (if (f32.le (get_global $player_y) (f32.const 0))
            (then
                (set_global $player_y (f32.const 0))
            )
        )

        (if (f32.gt (get_global $player_y) (f32.const 640))
            (then
                (set_global $player_y (f32.const 640))
            )
        )
    )


    (func $shot_update
        (if
            (i32.and
                (i32.load8_u (i32.const 346))
                (i32.eq (get_global $is_shot_alive) (i32.const 0)))
            (then
                (set_global $is_shot_alive (i32.const 1))
                (set_global $shot_x (get_global $player_x))
                (set_global $shot_y (get_global $player_y))
            )
        )

        (if (i32.eq (get_global $is_shot_alive) (i32.const 1))
            (then
                (set_global $shot_y (f32.sub (get_global $shot_y) (f32.const 6)))
                (if (f32.lt (get_global $shot_y) (f32.const 0))
                    (then
                        (set_global $is_shot_alive (i32.const 0))
                    )
                )
            )
        )
    )

)


