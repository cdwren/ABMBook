; patch choice model from optimal foraging theory
; Copyright Michael Barton, Arizona State University
; Updated 2015 to NetLogo v. 5

breed [foragers forager]
breed [animals animal]

foragers-own [energy diet-breadth]
animals-own [species food-value processing-costs rank]
patches-own [ptimer]
globals [rank-list prey-list diversity ]

to Setup
  clear-all
  Setup_Animals
  Setup_Foragers
  Setup_Patches
  reset-ticks
end

to Go
  ask foragers [
    Move
    set energy energy - 1
    Forage
    Calculate-Diversity
    Check-Death
    ]

  ask animals [
    Move
    ;;Reproduce
    ]

  ask patches [Patch_Color]

  tick
  if not any? foragers [stop]
end

to Setup_Foragers
  create-foragers init-foragers
    [
    set shape "hunter2"
    set size 3
    set color 38
    set energy 100
    set prey-list [] ; rolling list of prey species taken
    ]
  ask foragers [setxy random-xcor random-ycor] ; place the foragers randomly in the world
end

to Setup_Animals
  ; Create 4 animal species with different processing costs, food values, birth rates, and initial population densities

  let total-density (density1 + density2 + density3 + density4)
  let number1 round (init-prey * density1 / total-density)
  let number2 round (init-prey * density2 / total-density)
  let number3 round (init-prey * density3 / total-density)
  let number4 round (init-prey * density4 / total-density)

  set rank-list (list (food-value1 - processing-cost1) (food-value2 - processing-cost2)
    (food-value3 - processing-cost3) (food-value4 - processing-cost4))

  set rank-list sort-by > rank-list

  create-animals number1 [
    set species 1
    set shape "cow"
    set size 2
    set color brown
    set food-value food-value1
    set processing-costs processing-cost1
    set rank position (food-value1 - processing-cost1) rank-list + 1
  ]

  create-animals number2 [
    set species 2
    set shape "rabbit"
    set size 1.5
    set color grey
    set food-value food-value2
    set processing-costs processing-cost2
    set rank position (food-value2 - processing-cost2) rank-list + 1
    ]

  create-animals number3 [
    set species 3
    set shape "fish"
    set size 1.5
    set color blue
    set food-value food-value3
    set processing-costs processing-cost3
    set rank position (food-value3 - processing-cost3) rank-list + 1
    ]

  create-animals number4 [
    set species 4
    set shape "turtle"
    set size 1.5
    set color lime
    set food-value food-value4
    set processing-costs processing-cost4
    set rank position (food-value4 - processing-cost4) rank-list + 1
    ]

  ask animals [setxy random-xcor random-ycor] ; place the animals randomly in the world

end

to Setup_Patches
  ask patches [set ptimer 20]
end

to Move
  rt random 45
  lt random 45
  fd 1
end

to Forage
  let prey one-of animals-here                  ;; seek a random animal
  if prey != nobody  [                          ;; did we get one?  If so,
    if (energy >= 85 and [rank] of prey = 1) or  ;; see how hungry we are and decide whether to take it
       (energy < 85 and energy >= 70 and [rank] of prey < 3) or
       (energy < 70 and energy >= 55 and [rank] of prey < 4) or
       (energy < 55)
        [ ask patch-here [set pcolor red ]
          ask patch-here [set ptimer 0]
          set energy energy + [food-value] of prey  ;; get energy from eating animal
          set prey-list fput ([species] of prey) prey-list ; add prey-species to running list of prey taken
        ]
      ]
  while [length prey-list > 10] [set prey-list remove-item 10 prey-list] ; manage running list of prey taken
end

to Patch_Color
  ifelse ptimer < 20
    [set ptimer ptimer + 1]
    [if pcolor != black [set pcolor black]]
end

to Calculate-Diversity
  set diversity 0
  if member? 1 prey-list [set diversity diversity + 1]
  if member? 2 prey-list [set diversity diversity + 1]
  if member? 3 prey-list [set diversity diversity + 1]
  if member? 4 prey-list [set diversity diversity + 1]
end

to Check-Death
  ask foragers [if energy <= 0 [die]]
end
@#$#@#$#@
GRAPHICS-WINDOW
515
60
1138
609
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
40
0
35
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
180
83
init-foragers
init-foragers
1
20
1.0
1
1
NIL
HORIZONTAL

SLIDER
5
150
180
183
processing-cost1
processing-cost1
0
10
1.0
1
1
NIL
HORIZONTAL

SLIDER
5
115
180
148
food-value1
food-value1
5
100
25.0
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
5
185
180
218
density1
density1
0
100
15.0
1
1
%
HORIZONTAL

SLIDER
190
150
365
183
processing-cost2
processing-cost2
0
10
3.0
1
1
NIL
HORIZONTAL

SLIDER
5
285
180
318
processing-cost3
processing-cost3
0
10
1.0
1
1
NIL
HORIZONTAL

SLIDER
190
185
365
218
density2
density2
0
100
15.0
1
1
%
HORIZONTAL

SLIDER
5
320
180
353
density3
density3
0
100
40.0
1
1
%
HORIZONTAL

SLIDER
190
115
365
148
food-value2
food-value2
5
100
25.0
1
1
NIL
HORIZONTAL

SLIDER
5
250
180
283
food-value3
food-value3
5
100
15.0
1
1
NIL
HORIZONTAL

SLIDER
190
285
365
318
processing-cost4
processing-cost4
0
10
3.0
1
1
NIL
HORIZONTAL

SLIDER
190
320
365
353
density4
density4
0
100
40.0
1
1
%
HORIZONTAL

SLIDER
190
250
365
283
food-value4
food-value4
5
100
15.0
1
1
NIL
HORIZONTAL

TEXTBOX
15
95
80
113
Species 1
12
0.0
1

SLIDER
190
50
365
83
init-prey
init-prey
0
1000
200.0
1
1
NIL
HORIZONTAL

PLOT
5
365
510
510
Prey Taken
NIL
# /10 cycles
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Cows" 1.0 0 -6459832 true "" "plot length (filter [ ?1 -> ?1 = 1 ] prey-list)"
"Rabbits" 1.0 0 -7500403 true "" "plot length (filter [ ?1 -> ?1 = 2 ] prey-list)"
"Fish" 1.0 0 -13345367 true "" "plot length (filter [ ?1 -> ?1 = 3 ] prey-list)"
"Turtles" 1.0 0 -13840069 true "" "plot length (filter [ ?1 -> ?1 = 4 ] prey-list)"

MONITOR
375
115
480
160
Forager Energy
sum [energy] of foragers
17
1
11

MONITOR
375
165
480
210
Diet Diversity
diversity
17
1
11

MONITOR
375
265
440
310
Species 1
length (filter [ ?1 -> ?1 = 1 ] prey-list)
0
1
11

TEXTBOX
200
95
260
113
Species 2
12
0.0
1

TEXTBOX
15
230
75
248
Species 3
12
0.0
1

TEXTBOX
200
230
270
248
Species 4
12
0.0
1

MONITOR
440
265
505
310
Species 2
length (filter [ ?1 -> ?1 = 2 ] prey-list)
0
1
11

MONITOR
375
310
440
355
Species 3
length (filter [ ?1 -> ?1 = 3 ] prey-list)
0
1
11

MONITOR
440
310
505
355
Species 4
length (filter [ ?1 -> ?1 = 4 ] prey-list)
0
1
11

TEXTBOX
400
230
495
256
Species Taken\nOver 10 Cycles
11
0.0
1

PLOT
5
510
509
630
Forager Energy
NIL
energy
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"f-energy" 1.0 0 -2674135 true "" "plot (sum [energy] of foragers)"

TEXTBOX
650
30
1040
50
Diet Breadth Model (Optimal Foraging Theory)
16
103.0
1

@#$#@#$#@
## OVERVIEW

This is an agent-based simulation of the classic "diet breadth model" of optimal foraging theory (see Foley 1985).

This has been used as an example in chapter 6 of Romanowska, I., Wren, C., Crabtree, S. 2021 Agent-Based Modeling for Archaeology: Simulating the Complexity of Societies. Santa Fe Institute Press.

Code blocks: 6.11-6.12

## SIMULATION OPERATION

SETUP: Initialize the number of foragers and total number of prey.  

FORAGERS: One or more foragers (<init-foragers> selected by the user) are placed randomly and given 100 energy units (eu's) to start with. Each forager begins to move in random directions; each cell moved costs the forager 1 energy unit. 

PREY: Prey (total determined by <init-prey>, selected by the user) are placed randomly and move randomly. Up to 4 distinct prey species can be defined. The user selects the relative density of the species, its food value (when consumed by a forager), and the costs to process the species before it can be eaten. Prey are ranked according to their net food value = gross food value - processing costs.

FORAGING: When a forager encounters prey, she/he decides whether to take it or continue searching for prey. If she/he is not very hungry (energy >= 85), she/he will only take the 1st ranked prey; if she/he is hungrier (energy 70-85), she/he will take 1st or 2nd order prey; if she/he is even hungrier (energy 55-70, she/he will take prey ranked 1st through 3rd; if she/he is very hungry (energy < 55), she/he will take any prey. On taking any prey, the forager received the net food value. A patch turns red briefly to mark when a prey is taken.

MONITORING DIET BREADTH: The species of any prey taken is added to the beginning of a running list of the 10 most recent prey taken; if the length of the list is over 10, the last prey on the list is removed. The number of different prey species in the list is monitored as diet breadth.

## HOW TO USE IT

Set the options (see above). Press "setup". Then press "run".

## THINGS TO TRY

Try changing the density of the 1st ranked species or of other species. What happens to diet diversity? Try changing the food values in each cell or the distance moved by each forger each cycle. The classic diet breadth model considers only one forager. What happens if more than one forager are placed in the simulation? 

## EXTENDING THE MODEL

Other OFT models could be simulated in this way.

## CREDITS AND REFERENCES

C. Michael Barton, Arizona State University 

For an overview of OFT models, see Foley, R. (1985). Optimality theory in anthropology. Man, 20, 222-242.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

acorn
false
0
Polygon -7500403 true true 146 297 120 285 105 270 75 225 60 180 60 150 75 105 225 105 240 150 240 180 225 225 195 270 180 285 155 297
Polygon -6459832 true false 121 15 136 58 94 53 68 65 46 90 46 105 75 115 234 117 256 105 256 90 239 68 209 57 157 59 136 8
Circle -16777216 false false 223 95 18
Circle -16777216 false false 219 77 18
Circle -16777216 false false 205 88 18
Line -16777216 false 214 68 223 71
Line -16777216 false 223 72 225 78
Line -16777216 false 212 88 207 82
Line -16777216 false 206 82 195 82
Line -16777216 false 197 114 201 107
Line -16777216 false 201 106 193 97
Line -16777216 false 198 66 189 60
Line -16777216 false 176 87 180 80
Line -16777216 false 157 105 161 98
Line -16777216 false 158 65 150 56
Line -16777216 false 180 79 172 70
Line -16777216 false 193 73 197 66
Line -16777216 false 237 82 252 84
Line -16777216 false 249 86 253 97
Line -16777216 false 240 104 252 96

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

bird
false
0
Polygon -7500403 true true 135 165 90 270 120 300 180 300 210 270 165 165
Rectangle -7500403 true true 120 105 180 237
Polygon -7500403 true true 135 105 120 75 105 45 121 6 167 8 207 25 257 46 180 75 165 105
Circle -16777216 true false 128 21 42
Polygon -7500403 true true 163 116 194 92 212 86 230 86 250 90 265 98 279 111 290 126 296 143 298 158 298 166 296 183 286 204 272 219 259 227 235 240 241 223 250 207 251 192 245 180 232 168 216 162 200 162 186 166 175 173 171 180
Polygon -7500403 true true 137 116 106 92 88 86 70 86 50 90 35 98 21 111 10 126 4 143 2 158 2 166 4 183 14 204 28 219 41 227 65 240 59 223 50 207 49 192 55 180 68 168 84 162 100 162 114 166 125 173 129 180

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

caterpillar
true
0
Polygon -7500403 true true 165 210 165 225 135 255 105 270 90 270 75 255 75 240 90 210 120 195 135 165 165 135 165 105 150 75 150 60 135 60 120 45 120 30 135 15 150 15 180 30 180 45 195 45 210 60 225 105 225 135 210 150 210 165 195 195 180 210
Line -16777216 false 135 255 90 210
Line -16777216 false 165 225 120 195
Line -16777216 false 135 165 180 210
Line -16777216 false 150 150 201 186
Line -16777216 false 165 135 210 150
Line -16777216 false 165 120 225 120
Line -16777216 false 165 106 221 90
Line -16777216 false 157 91 210 60
Line -16777216 false 150 60 180 45
Line -16777216 false 120 30 96 26
Line -16777216 false 124 0 135 15

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

hunter
false
0
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 105 90 60 195 90 210 135 105
Polygon -7500403 true true 195 90 270 135 255 165 165 105
Circle -6459832 true false 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Polygon -6459832 true false 120 90 105 90 180 195 180 165
Line -6459832 false 109 105 139 105
Line -6459832 false 122 125 151 117
Line -6459832 false 137 143 159 134
Line -6459832 false 158 179 181 158
Line -6459832 false 146 160 169 146
Rectangle -6459832 true false 120 193 180 201
Rectangle -6459832 true false 114 187 128 208
Rectangle -6459832 true false 177 187 191 208
Polygon -16777216 true false 225 30 255 75 270 120 270 150 255 195 225 240 255 210 270 195 285 150 285 120 270 75 225 30

hunter2
false
0
Rectangle -7500403 true true 142 79 187 94
Polygon -7500403 true true 30 75 135 135 150 105 45 60
Polygon -7500403 true true 210 90 270 165 255 180 180 105
Circle -7500403 true true 125 5 80
Polygon -7500403 true true 120 90 135 195 105 300 150 300 135 285 165 225 180 300 225 300 210 285 195 195 210 90
Polygon -14835848 true false 135 90 120 90 195 195 195 165
Line -6459832 false 109 105 139 105
Line -6459832 false 122 125 151 117
Line -6459832 false 137 143 159 134
Line -6459832 false 158 179 181 158
Line -6459832 false 146 160 169 146
Polygon -14835848 true false 135 180 105 240 225 240 195 180
Rectangle -16777216 true false 132 178 199 188
Rectangle -6459832 true false 5 63 228 72
Polygon -11221820 true false 192 50 285 60 211 83

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

mouse side
false
0
Polygon -7500403 true true 38 162 24 165 19 174 22 192 47 213 90 225 135 230 161 240 178 262 150 246 117 238 73 232 36 220 11 196 7 171 15 153 37 146 46 145
Polygon -7500403 true true 289 142 271 165 237 164 217 185 235 192 254 192 259 199 245 200 248 203 226 199 200 194 155 195 122 185 84 187 91 195 82 192 83 201 72 190 67 199 62 185 46 183 36 165 40 134 57 115 74 106 60 109 90 97 112 94 92 93 130 86 154 88 134 81 183 90 197 94 183 86 212 95 211 88 224 83 235 88 248 97 246 90 257 107 255 97 270 120
Polygon -16777216 true false 234 100 220 96 210 100 214 111 228 116 239 115
Circle -16777216 true false 246 117 20
Line -7500403 true 270 153 282 174
Line -7500403 true 272 153 255 173
Line -7500403 true 269 156 268 177

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

rabbit
false
0
Polygon -7500403 true true 61 150 76 180 91 195 103 214 91 240 76 255 61 270 76 270 106 255 132 209 151 210 181 210 211 240 196 255 181 255 166 247 151 255 166 270 211 270 241 255 240 210 270 225 285 165 256 135 226 105 166 90 91 105
Polygon -7500403 true true 75 164 94 104 70 82 45 89 19 104 4 149 19 164 37 162 59 153
Polygon -7500403 true true 64 98 96 87 138 26 130 15 97 36 54 86
Polygon -7500403 true true 49 89 57 47 78 4 89 20 70 88
Circle -16777216 true false 37 103 16
Line -16777216 false 44 150 104 150
Line -16777216 false 39 158 84 175
Line -16777216 false 29 159 57 195
Polygon -5825686 true false 0 150 15 165 15 150
Polygon -5825686 true false 76 90 97 47 130 32
Line -16777216 false 180 210 165 180
Line -16777216 false 165 180 180 165
Line -16777216 false 180 165 225 165
Line -16777216 false 180 210 210 240

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
NetLogo 6.1.1
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
