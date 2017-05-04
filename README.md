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
+------------------------------+
|       Enemy * 20  (180byte)  |
+------------------------------+
|       Shot  * 20  (180byte)  |
+------------------------------+
|                              |
|      Bullet * 60  (540byte)  |
|                              |
+--------------+---------------+
| Keys (5byte) |
+--------------+
```


Enemy Data (9byte)
```
  u8    f32      f32
+----+--------+--------+
|live|   x    |   y    |
+----+--------+--------+
```

Shot Data (9byte)
```
  u8    f32     f32
+----+--------+--------+
|live|   x    |   y    |
+----+--------+--------+
```

Bullet Data (9byte)
```
  u8    f32      f32
+----+--------+--------+
|live|   x    |   y    |
+----+--------+--------+
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


