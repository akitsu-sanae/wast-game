# wast-game

wast-game is a game written in WebAssembly text format (wast).
inspired by https://github.com/abagames/wasm-game-by-hand

# How to build

wast-game needs `wast2wasm`  
get from `https://github.com/WebAssembly/wabt`.  

and run `wast2wasm game.wast -o game.wasm` in this directory.  
then, open `index.html`

# Memory

Whole (1876byte)
```
+------------------------------+- 0
|       Shot  * 30  (510byte)  |
+------------------------------+- 510
|                              |
|      Bullet * 80  (1360byte) |
|                              |
+--------------+-------+-------+- 1870
| Keys (5byte) | Scene |
+--------------+-------+
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

Keys (6byte)
```
   u8     u8     u8     u8     u8      u8
+------+------+------+------+------+--------+
| Left |  Up  | Right| Down |Z push| Z hold |
+------+------+------+------+------+--------+
```

Scene (1byte)
```
0 ... title scene
1 ... game scene
2 ... game clear scene
3 ... gane over scene
```

# Copyright
Copyright (C) 2017 akitsu sanae.  
Distributed under the Boost Software License, Version 1.0. 
(See accompanying file LICENSE or copy at http://www.boost/org/LICENSE_1_0.txt)  


