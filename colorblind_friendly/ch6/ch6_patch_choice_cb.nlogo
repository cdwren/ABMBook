; patch choice model from optimal foraging theory
; by Michael Barton, Arizona State University

breed [foragers forager]

foragers-own [encounter-list avg-cost encounter-rate]
patches-own [food]
globals [global-return ]

to Setup
  clear-all
  Setup_Patches
  Setup_Foragers
  reset-ticks
end

to Go
  Forage
  Leave-patch
  Regrow
  Do_Plots
  tick
  if not any? foragers [stop]
end

to Setup_Patches
  ask patches
    [
    set pcolor brown + 3
    if random 100 < resource-density [
      set food food-value ; put a food item on patches according to resource density
      set pcolor green
    ]
  ]
end

to Setup_Foragers
  create-foragers init-foragers
  ask foragers
    [
    set shape "person"
    set size 2
    set color black
    setxy random-xcor random-ycor ; place the foragers in the world
    set encounter-list n-values 10 [food-value] ; rolling list encounters with cells that have food
    pen-down
    ]
end

to Forage
  ask foragers [
    rt random 360
    forward 1
    ifelse food > 0 [
      let current-harvest random food
      set encounter-list fput current-harvest encounter-list ; if there is food, count it as a successful encounter in the rolling encounters list
      ask patch-here [set food food - current-harvest set pcolor pcolor + current-harvest
        if food <= 0 [set pcolor brown + 3]
      ] ; harvest the food and turn the patch white
    ]
    [
      set encounter-list fput 0 encounter-list    ; if no food, count it as an unsuccessful encounter
    ]

    set encounter-list but-last encounter-list ; take last list item off the rolling encounters list
    set encounter-rate mean encounter-list
  ]
end

to Leave-patch
  ask foragers
    [
      if encounter-rate < (resource-density / 100) [ ; check whether encounter rate in ecopatch is less than average encounter rate (=resource density)
        rt random 360
        forward 10
        set encounter-list n-values 10 [food-value] ;reset the encounter list to full
      ]
  ]
end

to Regrow
  ask patches [ ; regrow food in harvested patches
    if random 100 < regrow-rate [ set food food-value set pcolor green]
  ]
end

to Do_Plots ; track simulation values
  set-current-plot-pen "encounter rate"
  if count foragers > 0 [plot sum [encounter-rate] of foragers / count foragers]
end
@#$#@#$#@
GRAPHICS-WINDOW
419
10
892
484
-1
-1
15.0
1
10
1
1
1
0
1
1
1
0
30
0
30
1
1
1
ticks
30.0

BUTTON
5
10
71
43
setup
Setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
75
10
138
43
run
Go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
5
50
177
83
init-foragers
init-foragers
1
20
6.0
1
1
NIL
HORIZONTAL

SLIDER
190
120
362
153
regrow-rate
regrow-rate
0
20
0.1
.1
1
%
HORIZONTAL

PLOT
-4
303
401
453
Search costs & encounters per forager
NIL
NIL
0.0
10.0
0.0
5.0
true
true
"" ""
PENS
"encounter rate" 1.0 0 -2674135 true "" ""

SLIDER
190
85
362
118
food-value
food-value
1
50
5.0
1
1
NIL
HORIZONTAL

BUTTON
145
10
208
43
step
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
190
50
362
83
resource-density
resource-density
0
100
74.0
1
1
%
HORIZONTAL

MONITOR
106
217
208
262
encounter rate
sum [encounter-rate] of foragers / count foragers
17
1
11

MONITOR
106
171
245
216
NIL
[encounter-list] of turtle 0
17
1
11

@#$#@#$#@
## OVERVIEW

This is an agent-based simulation of the classic "patch choice model" of optimal foraging theory.

This has been used as an example in chapter 6 of Romanowska, I., Wren, C., Crabtree, S. 2021 Agent-Based Modeling for Archaeology: Simulating the Complexity of Societies. Santa Fe Institute Press.

Code blocks: 6.9-6.10

## SIMULATION OPERATION

SETUP: The world is divided into 9 eco-patches, each with their own ID number. Each cell in the eco-patch (i.e., a NetLogo "patch") has a food value (e.g., edible plants), set by the user (<food-value> in energy units or eu's). The density of patches with food also can be set (<resource-density> ranging fro 0-100%)

FORAGERS: One or more foragers (<init-foragers> selected by the user) are placed randomly in the eco-patches and given 100 energy units (eu's) to start with. They begin to move in random directions a distance <move-dist> set by the user. Each cell moved costs the forager <search-cost> energy units (set by the user).

FORAGING: The forager gains energy (<food-value>) by harvesting and consuming the food in each cell he/she encounters that has food. Processing the food can optionally also cost the forager <processing-cost> (set by the user).

REGROWTH: When the food is harvested, the cell's food value goes to zero. Optionally, exhausted cells can regrow using a random function set by the user <regrow-rate>.

MOVING: According to the patch choice model, a forager will continue to forage in a patch until the rate of encountering new food in a patch drops below the encounter rante for the entire region. The encounter rate for a forager is calculated as a rolling average of (successful encounters / total encounters) over some time interval. The time interval of the rolling average is set by the user <avg-interval> and varies from 2-100.

## HOW TO USE IT

Set the options (see above). Press "setup". Then press "run".

## THINGS TO TRY

The classic patch choice model considers only one forager. What happens if more than one forager are placed in the simulation? Try changing the food values in each cell or the distance moved by each forger each cycle.

## EXTENDING THE MODEL

Other OFT models could be simulated in this way.

## CREDITS AND REFERENCES

C. Michael Barton, Arizona State University
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.2.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
