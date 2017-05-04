# wast-game

wast-game is a game written in WebAssembly text format (wast).
inspired by https://github.com/abagames/wasm-game-by-hand

# How to build

wast-game needs `wast2wasm`  
get from `https://github.com/WebAssembly/wabt`.  

and run `wast2wasm game.wast -o game.wasm` in this directory.  
then, open `index.html`

# Memory

Whole (905byte)
```
+------------------------------+- 0
|       Shot  * 30  (510byte)  |
+------------------------------+- 510
|                              |
|      Bullet * 40  (680byte)  |
|                              |
+--------------+---------------+- 1190
| Keys (5byte) |
+--------------+
```

Shot Data (17byte)
```
  u8    f32      f32       f32      f32
+----+--------+--------+--------+--------+
|live|   x    |   y    |    dx  |    dy  |
+----+--------+--------+--------+--------+
```

Bullet Data (17byte)
```
  u8    f32      f32       f32      f32
+----+--------+--------+--------+--------+
|live|   x    |   y    |    dx  |    dy  |
+----+--------+--------+--------+--------+
```

Keys (5byte)
```
   u8     u8     u8     u8     u8
+------+------+------+------+------+
| Left |  Up  | Right| Down |  Z   |
+------+------+------+------+------+
```

# Copyright
Copyright (C) 2017 akitsu sanae.  
Distributed under the Boost Software License, Version 1.0. 
(See accompanying file LICENSE or copy at http://www.boost/org/LICENSE_1_0.txt)  


