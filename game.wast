(module
    (func $draw_player (import "imports" "draw_player") (param f32 f32))
    (func $draw_shot (import "imports" "draw_shot") (param f32 f32))
    (func $draw_enemy (import "imports" "draw_enemy") (param f32 f32))
    (func $console (import "imports" "console") (param i32))
    (func $console_f (import "imports" "console") (param f32))
    (func $sin (import "imports" "sin") (param f32) (result f32))
    (func $cos (import "imports" "cos") (param f32) (result f32))
    (memory (export "ram") 1)

    (global $player_x (mut f32) (f32.const 320))
    (global $player_y (mut f32) (f32.const 320))

    (global $shot_index (mut i32) (i32.const 0))

    (global $enemy_x (mut f32) (f32.const 320))
    (global $enemy_y (mut f32) (f32.const 120))
    (global $enemy_counter (mut f32) (f32.const 0))

    (global $pi f32 (f32.const 3.141592))

    (func $update (export "update")
        (call $move_player)

        (call $draw_player (get_global $player_x) (get_global $player_y))

        (call $update_shots)
        (call $draw_shots)

        (call $enemy_update)
        (call $draw_enemy (get_global $enemy_x) (get_global $enemy_y))
    )

    (func $move_player

        (if (i32.load8_u (i32.const 1020)) ;; left key pressed
            (then
               (set_global $player_x (f32.sub (get_global $player_x) (f32.const 5)))
            )
        )

        (if (i32.load8_u (i32.const 1022)) ;; right key pressed
            (then
               (set_global $player_x (f32.add (get_global $player_x) (f32.const 5)))
            )
        )

        (if (i32.load8_u (i32.const 1021)) ;; up key pressed
            (then
               (set_global $player_y (f32.sub (get_global $player_y) (f32.const 5)))
            )
        )

        (if (i32.load8_u (i32.const 1023)) ;; down key pressed
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

    (func $update_shots
        (local $shot_i i32)
        (local $data_addr i32)
        (local $y f32)

        (set_local $shot_i (i32.const 0))
        (block $update_break
            (loop $update
                (br_if $update_break (i32.eq (get_local $shot_i) (i32.const 20)))
                ;; 17 * shot_i
                (set_local $data_addr
                    (i32.mul
                        (i32.const 17)
                        (get_local $shot_i)))

                (set_local $shot_i (i32.add (get_local $shot_i) (i32.const 1)))

                ;; continue if is_alive == 0
                (br_if $update
                    (i32.eq
                        (i32.load8_u (get_local $data_addr))
                        (i32.const 0)))

                (set_local $y (f32.load (i32.add (get_local $data_addr) (i32.const 5))))

                (set_local $y (f32.sub (get_local $y) (f32.const 4)))

                (if (f32.lt (get_local $y) (f32.const 0))
                    (then
                        (i32.store8 (get_local $data_addr) (i32.const 0))
                    )
                )


                (f32.store (i32.add (get_local $data_addr) (i32.const 5)) (get_local $y))

                (br $update)
            )
        )

        (if (i32.load8_u (i32.const 1024))
            (then
                (call $fire_shot)
            )
        )
    )

    (func $fire_shot
        (local $new_shot_addr i32)
        ;; addr = 180 + 9 * $shot_index
        (set_local $new_shot_addr
            (i32.mul
                (i32.const 17)
                (get_global $shot_index)))

        (i32.store8 (get_local $new_shot_addr) (i32.const 1))
        (f32.store (i32.add (get_local $new_shot_addr) (i32.const 1)) (get_global $player_x))
        (f32.store (i32.add (get_local $new_shot_addr) (i32.const 5)) (get_global $player_y))

        (set_global $shot_index
            (i32.rem_s
                (i32.add
                    (get_global $shot_index)
                    (i32.const 1))
                (i32.const 20)))
    )

    (func $draw_shots
        (local $shot_i i32)
        (local $data_addr i32)
        (set_local $shot_i (i32.const 0))
        (block $update_break
            (loop $update
                (br_if $update_break (i32.eq (get_local $shot_i) (i32.const 20)))
                ;; 17 * shot_i
                (set_local $data_addr
                    (i32.mul
                        (i32.const 17)
                        (get_local $shot_i)))

                (set_local $shot_i (i32.add (get_local $shot_i) (i32.const 1)))

                ;; continue if is_alive == 0
                (br_if $update
                    (i32.eq
                        (i32.load8_s (get_local $data_addr))
                        (i32.const 0)))

                (call $draw_shot
                    (f32.load (i32.add (get_local $data_addr) (i32.const 1)))
                    (f32.load (i32.add (get_local $data_addr) (i32.const 5))))

                (br $update)
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


