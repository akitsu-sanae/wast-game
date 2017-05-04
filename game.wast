(module
    (func $draw_player (import "imports" "draw_player") (param f32 f32))
    (func $draw_shot (import "imports" "draw_shot") (param f32 f32))
    (func $draw_enemy (import "imports" "draw_enemy") (param f32 f32))
    (func $sin (import "imports" "sin") (param f32) (result f32))
    (func $cos (import "imports" "cos") (param f32) (result f32))
    (memory (export "ram") 1)

    (global $player_x (mut f32) (f32.const 320))
    (global $player_y (mut f32) (f32.const 320))

    (global $shot_x (mut f32) (f32.const 0))
    (global $shot_y (mut f32) (f32.const 0))
    (global $is_shot_alive (mut i32) (i32.const 0))

    (global $enemy_x (mut f32) (f32.const 320))
    (global $enemy_y (mut f32) (f32.const 120))
    (global $enemy_counter (mut f32) (f32.const 0))

    (global $pi f32 (f32.const 3.141592))

    (func $update (export "update")
        (call $move_player)

        (call $draw_player (get_global $player_x) (get_global $player_y))

        (call $shot_update)
        (if (i32.eq (get_global $is_shot_alive) (i32.const 1))
            (then
                (call $draw_shot (get_global $shot_x) (get_global $shot_y))
            )
        )

        (call $enemy_update)
        (call $draw_enemy (get_global $enemy_x) (get_global $enemy_y))
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

    (func $enemy_update
        (local $angle f32)
        (set_global $enemy_counter (f32.add (get_global $enemy_counter) (f32.const 1)))
        (if (f32.gt (get_global $enemy_counter) (f32.const 120))
            (then
                (set_global $enemy_counter (f32.sub (get_global $enemy_counter) (f32.const 120)))
            )
        )

        ;; angle = 2 * PI * counter / 120
        (set_local $angle
            (f32.div
                (f32.mul
                    (f32.const 2)
                    (f32.mul
                        (get_global $pi)
                        (get_global $enemy_counter)))
                (f32.const 120)))

        ;; enemy_x = 320 + 80 * cos(angle)
        (set_global $enemy_x
            (f32.add
                (f32.const 320)
                (f32.mul
                    (f32.const 80)
                    (call $cos (get_local $angle)))))

        ;; enemy_y = 120 + 80 * sin(angle)
        (set_global $enemy_y
            (f32.add
                (f32.const 120)
                (f32.mul
                    (f32.const 80)
                    (call $sin (get_local $angle)))))

    )

)


