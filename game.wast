(module
    (func $draw_player (import "imports" "draw_player") (param f32 f32))
    (func $draw_player_hp (import "imports" "draw_player_hp") (param i32))
    (func $draw_shot (import "imports" "draw_shot") (param f32 f32))
    (func $draw_enemy (import "imports" "draw_enemy") (param f32 f32))
    (func $draw_bullet (import "imports" "draw_bullet") (param f32 f32))
    (func $draw_enemy_hp (import "imports" "draw_enemy_hp") (param i32))
    (func $draw_gameclear_scene (import "imports" "draw_gameclear_scene"))
    (func $console (import "imports" "console") (param i32))
    (func $console_f (import "imports" "console") (param f32))
    (func $sin (import "imports" "sin") (param f32) (result f32))
    (func $cos (import "imports" "cos") (param f32) (result f32))
    (memory (export "ram") 1)

    (global $player_x (mut f32) (f32.const 320))
    (global $player_y (mut f32) (f32.const 320))
    (global $player_hp (mut i32) (i32.const 5))

    (global $shot_index (mut i32) (i32.const 0))
    (global $bullet_index (mut i32) (i32.const 0))

    (global $enemy_x (mut f32) (f32.const 320))
    (global $enemy_y (mut f32) (f32.const 120))
    (global $enemy_counter (mut f32) (f32.const 0))

    (global $enemy_hp (mut i32) (i32.const 500))

    (global $pi f32 (f32.const 3.141592))

    (func $update (export "update")
        (if (i32.eq (get_global $enemy_hp) (i32.const 0))
            (then
                (call $draw_gameclear_scene)
                (return)
            ))


        (call $move_player)


        (call $update_shots)

        (call $update_bullets)

        (call $enemy_update)
        (call $draw_enemy (get_global $enemy_x) (get_global $enemy_y))
        (call $draw_enemy_hp (get_global $enemy_hp))
    )

    (func $move_player

        (if (i32.load8_u (i32.const 1190)) ;; left key pressed
            (then
               (set_global $player_x (f32.sub (get_global $player_x) (f32.const 5)))
            )
        )

        (if (i32.load8_u (i32.const 1192)) ;; right key pressed
            (then
               (set_global $player_x (f32.add (get_global $player_x) (f32.const 5)))
            )
        )

        (if (i32.load8_u (i32.const 1191)) ;; up key pressed
            (then
               (set_global $player_y (f32.sub (get_global $player_y) (f32.const 5)))
            )
        )

        (if (i32.load8_u (i32.const 1193)) ;; down key pressed
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

        (call $draw_player (get_global $player_x) (get_global $player_y))
        (call $draw_player_hp (get_global $player_hp))
    )

    (func $update_shots
        (local $shot_i i32)
        (local $data_addr i32)
        (local $x f32)
        (local $y f32)

        (set_local $shot_i (i32.const 0))
        (block $update_break
            (loop $update
                (br_if $update_break (i32.eq (get_local $shot_i) (i32.const 30)))
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

                (set_local $x (f32.load (i32.add (get_local $data_addr) (i32.const 1))))
                (set_local $y (f32.load (i32.add (get_local $data_addr) (i32.const 5))))

                (set_local $x (f32.add (get_local $x) (f32.load (i32.add (get_local $data_addr) (i32.const 9)))))
                (set_local $y (f32.add (get_local $y) (f32.load (i32.add (get_local $data_addr) (i32.const 13)))))

                 ;; if abs(enemy_x - shot_x)  < 32 && abs(enemy_y - shot_y) < 32 then enemy_hp = enemy_hp - 1
                 (if
                     (i32.and
                         (f32.lt
                             (f32.abs (f32.sub (get_global $enemy_x) (get_local $x)))
                             (f32.const 32))
                         (f32.lt
                             (f32.abs (f32.sub (get_global $enemy_y) (get_local $y)))
                             (f32.const 32)))
                     (then
                         (set_global $enemy_hp (i32.sub (get_global $enemy_hp) (i32.const 1)))
                         (i32.store8 (get_local $data_addr) (i32.const 0))
                         (br $update)))

                (if (f32.lt (get_local $y) (f32.const 0))
                    (then
                        (i32.store8 (get_local $data_addr) (i32.const 0))
                    )
                )

                (f32.store (i32.add (get_local $data_addr) (i32.const 1)) (get_local $x))
                (f32.store (i32.add (get_local $data_addr) (i32.const 5)) (get_local $y))
                (f32.store (i32.add (get_local $data_addr) (i32.const 9))
                    (f32.mul
                        (f32.load (i32.add (get_local $data_addr) (i32.const 9)))
                        (f32.const 0.9)))

                (call $draw_shot
                    (f32.load (i32.add (get_local $data_addr) (i32.const 1)))
                    (f32.load (i32.add (get_local $data_addr) (i32.const 5))))


                (br $update)
            )
        )

        (if (i32.load8_u (i32.const 1194))
            (then
                (call $fire_shot (f32.const -5.0) (f32.const -5.0))
                (call $fire_shot (f32.const 0) (f32.const -5.5))
                (call $fire_shot (f32.const 5.0) (f32.const -5.0))
            )
        )
    )

    (func $fire_shot (param $dx f32) (param $dy f32)
        (local $new_shot_addr i32)
        ;; addr = 17 * $shot_index
        (set_local $new_shot_addr
            (i32.mul
                (i32.const 17)
                (get_global $shot_index)))

        (i32.store8 (get_local $new_shot_addr) (i32.const 1))
        (f32.store (i32.add (get_local $new_shot_addr) (i32.const 1)) (get_global $player_x))
        (f32.store (i32.add (get_local $new_shot_addr) (i32.const 5)) (get_global $player_y))
        (f32.store (i32.add (get_local $new_shot_addr) (i32.const 9)) (get_local $dx))
        (f32.store (i32.add (get_local $new_shot_addr) (i32.const 13)) (get_local $dy))

        (set_global $shot_index
            (i32.rem_s
                (i32.add
                    (get_global $shot_index)
                    (i32.const 1))
                (i32.const 30)))
    )

    (func $update_bullets
        (local $bullet_i i32)
        (local $data_addr i32)
        (local $x f32)
        (local $y f32)

        (set_local $bullet_i (i32.const 0))
        (block $update_break
            (loop $update
                (br_if $update_break (i32.eq (get_local $bullet_i) (i32.const 40)))
                ;; 510 + 17 * bullet_i
                (set_local $data_addr
                    (i32.add
                        (i32.const 510)
                        (i32.mul
                            (i32.const 17)
                            (get_local $bullet_i))))

                (set_local $bullet_i (i32.add (get_local $bullet_i) (i32.const 1)))

                ;; continue if is_alive == 0
                (br_if $update
                    (i32.eq
                        (i32.load8_u (get_local $data_addr))
                        (i32.const 0)))

                (set_local $x (f32.load (i32.add (get_local $data_addr) (i32.const 1))))
                (set_local $y (f32.load (i32.add (get_local $data_addr) (i32.const 5))))

                (set_local $x (f32.add (get_local $x) (f32.load (i32.add (get_local $data_addr) (i32.const 9)))))
                (set_local $y (f32.add (get_local $y) (f32.load (i32.add (get_local $data_addr) (i32.const 13)))))

                 ;; if abs(player_x - bullet_x)  < 8 && abs(player_y - bullet_y) < 8 then player_hp--;
                 (if
                     (i32.and
                         (f32.lt
                             (f32.abs (f32.sub (get_global $player_x) (get_local $x)))
                             (f32.const 8))
                         (f32.lt
                             (f32.abs (f32.sub (get_global $player_y) (get_local $y)))
                             (f32.const 8)))
                     (then
                         (call $console (i32.const 42))
                         (i32.store8 (get_local $data_addr) (i32.const 0))
                         (set_global $player_hp (i32.sub (get_global $player_hp) (i32.const 1)))
                         (br $update)))

                (if (f32.gt (get_local $y) (f32.const 640))
                    (then
                        (i32.store8 (get_local $data_addr) (i32.const 0))))

                (f32.store (i32.add (get_local $data_addr) (i32.const 1)) (get_local $x))
                (f32.store (i32.add (get_local $data_addr) (i32.const 5)) (get_local $y))
                (f32.store (i32.add (get_local $data_addr) (i32.const 9))
                    (f32.mul
                        (f32.load (i32.add (get_local $data_addr) (i32.const 9)))
                        (f32.const 0.9)))
                (call $draw_bullet
                    (f32.load (i32.add (get_local $data_addr) (i32.const 1)))
                    (f32.load (i32.add (get_local $data_addr) (i32.const 5))))



                (br $update))))

    (func $fire_bullet (param $dx f32) (param $dy f32)
        (local $new_bullet_addr i32)
        ;; addr = 510 + 17 * $bullet_index
        (set_local $new_bullet_addr
            (i32.add
                (i32.const 510)
                (i32.mul
                    (i32.const 17)
                    (get_global $bullet_index))))

        (i32.store8 (get_local $new_bullet_addr) (i32.const 1))
        (f32.store (i32.add (get_local $new_bullet_addr) (i32.const 1)) (get_global $enemy_x))
        (f32.store (i32.add (get_local $new_bullet_addr) (i32.const 5)) (get_global $enemy_y))
        (f32.store (i32.add (get_local $new_bullet_addr) (i32.const 9)) (get_local $dx))
        (f32.store (i32.add (get_local $new_bullet_addr) (i32.const 13)) (get_local $dy))

        (set_global $bullet_index
            (i32.rem_s
                (i32.add
                    (get_global $bullet_index)
                    (i32.const 1))
                (i32.const 40)))
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

        (if (i32.eq (i32.rem_u (i32.trunc_u/f32 (get_global $enemy_counter)) (i32.const 5)) (i32.const 0))
            (then
                (call $fire_bullet (f32.mul (f32.const 3) (call $cos (get_local $angle))) (f32.const 3))
            )
        )
    )

)


