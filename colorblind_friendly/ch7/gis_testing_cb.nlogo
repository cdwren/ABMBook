extensions [ gis palette ]

breed [hominids hominid]

globals
[
  elevation-dataset
  stable?
  nummap
  chosen-map
]

hominids-own
[
  aforesight
]

patches-own
[
  elevation
]

; 2.10 and 12 is decent for movement splitting
; 2.20 and 20 !!!
; 2.20 and 73 is ok
; 2.30 and 55
; 2.40 and 45

;###############################################################################################################


to setup
  clear-all
  if ch-map = 1 [set chosen-map "fig4b.asc"]
  if ch-map = 2 [set chosen-map "fig4c.asc"]
  if ch-map = 3 [set chosen-map "frac201.asc"]
  set elevation-dataset gis:load-dataset chosen-map
  gis:set-world-envelope gis:envelope-of elevation-dataset

  gis:apply-raster elevation-dataset elevation

  let mx gis:maximum-of elevation-dataset
  let mn gis:minimum-of elevation-dataset

  ask patches [
      set pcolor scale-color green elevation mn mx
    ; if ch-map = 2 [set pcolor scale-color green elevation -50 mx]
  ]
end

;to setup
;  ;random-seed 1
;  ca
;  set nummap 0
;  if first fmap = "2"
;  [
;    gis:load-coordinate-system (word "data/surf.prj")
;    set elevation-dataset gis:load-dataset (word "data/" fmap "/" run# ".asc")
;    gis:set-world-envelope (gis:envelope-of elevation-dataset)
;    set nummap read-from-string fmap
;  ]
;  if fmap = "cone"
;  [
;    gis:load-coordinate-system (word "data/surf.prj")
;    set elevation-dataset gis:load-dataset (word "data/" fmap "/" run# ".asc")
;    gis:set-world-envelope (gis:envelope-of elevation-dataset)
;  ]
;
;  gis:apply-raster elevation-dataset elevation
;  display-elevation
;
;  create-hominids N
;  [
;    set shape "circle"
;    set size 1
;    setxy max-pxcor - round(abs(random-normal 0 10)) max-pycor - round(abs(random-normal 0 10))
;    while [ elevation < 0 OR count hominids-here > 1 ] [ setxy max-pxcor - round(abs(random-normal 0 10)) max-pycor - round(abs(random-normal 0 10)) ]
;    set aforesight foresight
;    ; color-gradient aforesight
;    set color palette:scale-scheme "Sequential" "Purples" 5 aforesight 0 1
;    if trails [ pen-down ]
;  ]
;  reset-ticks
;end

to go
  fit-hill-w-evo

  ;plot map
  if one-of [hidden?] of hominids = TRUE [display-elevation]

  tick
end

to fit-hill-w-evo
  let numbabies 0
  ask hominids
  [
    ;Reproduction
    let maxfit max [elevation] of hominids
    let birth-adjust ( elevation / maxfit ) * birth-rate
    if (random-float 1 < birth-adjust) [
      hatch 1 [
        set aforesight aforesight + mutation-size - random-float (mutation-size * 2) ;mutation
        if aforesight > 1 [set aforesight 1]
        if aforesight < 0 [set aforesight 0]
        color-gradient aforesight
        if trails [ if (random 10 > 5 ) [ pen-down ] ]

        ;random drop hatching
        let p patch 0 0
        set p one-of neighbors with [not any? hominids-here = TRUE]
        ifelse (p != nobody) [
          move-to p
          ask one-of hominids [die]
        ][;else p=nobody
          die
        ]
      ] ;close hatch
    ];close birthrate

    ;Mobility
    ifelse (random-float 1 < aforesight)
      [;hill-climb if foresight correct
        let p max-one-of neighbors [elevation]
        if elevation < [elevation] of p
        [
          if not any? hominids-on p [ move-to p ]
        ]
      ]
      [;else random movement if foresight wrong
        let p one-of neighbors ;with [pcolor != 99]
        if not any? hominids-on p [ move-to p ]
      ]
  ];close ask hominids
end

to display-elevation
  let min-elevation gis:minimum-of elevation-dataset
  let max-elevation gis:maximum-of elevation-dataset
  ask patches
  [ ;
    set pcolor 99 ;in case some cells are inaccessible (e.g. water)
    if (elevation > 0) [
      ; set pcolor scale-color black elevation min-elevation max-elevation
      set pcolor scale-color green elevation 150 0
      ;set pcolor palette:scale-scheme "Sequential" "Greens" 8 elevation 0 150
    ]
  ]
  ask hominids [set hidden? false]
end

to color-gradient [number]
  ; ifelse (number <= 0.5) [set color red + ( number * 9.99 )] [set color 114 - (number * 9.99) ]
  set color palette:scale-scheme "Sequential" "Purples" 5 number -1 1
end
@#$#@#$#@
GRAPHICS-WINDOW
304
10
1014
721
-1
-1
7.02
1
10
1
1
1
0
0
0
1
0
99
0
99
1
1
1
ticks
1000.0

BUTTON
15
54
78
87
setup
setup
NIL
1
T
OBSERVER
NIL
S
NIL
NIL
1

BUTTON
15
86
78
119
go
ifelse ticks != 50000 [go][stop]\n;go\n
T
1
T
OBSERVER
NIL
G
NIL
NIL
1

BUTTON
15
119
78
152
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
82
92
254
125
N
N
0
1000
400.0
100
1
NIL
HORIZONTAL

CHOOSER
99
10
238
55
fmap
fmap
"2.001" "2.10" "2.20" "2.30" "2.40" "2.50" "2.60" "2.70" "2.80" "2.90" "2.999" "cone"
2

SLIDER
82
125
254
158
foresight
foresight
0
1
1.0
.05
1
NIL
HORIZONTAL

PLOT
12
357
253
477
AvgFitness
ticks
AvgFitness
0.0
10.0
50.0
55.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot mean [elevation] of hominids"
"biased" 1.0 0 -13345367 true "" ";if (mode = \"infoshare\" AND count hominids with [strategy = \"biased\"] > 0) [plot mean [elevation] of hominids with [strategy = \"biased\"]]"
"unbiased" 1.0 0 -2674135 true "" ";if (mode = \"infoshare\" AND count hominids with [strategy = \"unbiased\"] > 0) [plot mean [elevation] of hominids with [strategy = \"unbiased\"]]"

SLIDER
82
55
220
88
run#
run#
1
100
20.0
1
1
NIL
HORIZONTAL

SLIDER
82
191
253
224
birth-rate
birth-rate
0
.5
0.1
.1
1
NIL
HORIZONTAL

PLOT
12
226
253
357
AvgForesight
NIL
NIL
0.0
10.0
0.0
1.0
true
false
"" ""
PENS
"default" 1.0 2 -13345367 true "" ";ask n-of 10 hominids [plotxy ticks aforesight]"
"Dist" 100.0 0 -16777216 true "" "plotxy ticks mean [aforesight] of hominids"

MONITOR
252
226
302
271
AvgForesight
mean [aforesight] of hominids
2
1
11

SLIDER
82
158
254
191
mutation-size
mutation-size
0
.1
0.01
0.001
1
NIL
HORIZONTAL

BUTTON
220
55
275
88
rand
set run# random 100 + 1
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SWITCH
8
10
98
43
trails
trails
1
1
-1000

INPUTBOX
21
160
71
220
ch-map
3.0
1
0
Number

@#$#@#$#@
## WHAT IS IT?

Agent-based model evaluating the natural selection of foresight, the accuracy at which agents are able to assess their environment, under different degrees of environmental heterogeneity. 

The model is designed to connect a mechanism of local scale mobility, namely foraging, with the global scale phenomenon of population dispersal. 

## HOW IT WORKS

Agents are assigned the initial "foresight" parameter to their individual "aforesight" trait. This value controls the probability of either moving randomly to one of their 9-cell neighbours ("a mistake"), or choosing the neighbouring cell with the highest value. This value is mutated slightly either up or down with each successful reproduction, controled by the "birth-rate" parameter. Agents on high valued cells reprouced more frequently. This allows the population to find an optimal value for the foresight parameter.

## HOW TO USE IT

Maps are not generated by NetLogo. Download my map set from (includes a bash script for generating your own with GRASS GIS): https://dl.dropboxusercontent.com/u/1360468/surfaces.zip

Unzip the surfeq folder into the same folder as this nlogo file.

Choose a heterogeneity value from the "fmap" list running from 2.001 (least heterogeneous) to 2.999 (most heterogenous). Click rand to choose 1 of the 100 randomly generated surfaces at the selected heterogeneity level. Optionally also adjust the base birth-rate, mutation-size, and initial foresight parameters. Then click "setup". Assuming everything works, run with the "Go" button.

See the BehaviourSpace dialog for the run sets used in the article.

## THINGS TO NOTICE

The high resource clusters get crowded from high foresight agents which reduces the rate of successful reproductions. As a result, high levels of foresight are maladaptive due to reducing the available reproductive space and the mean foresight of the population falls to relatively low levels.

As heterogeneity is increased, the number of clusters increases while the size of them decreases. This disperses the population across the landscape which reduces the crowding, and favours higher foresight.

Success remains relatively high for all runs.

## THINGS TO TRY

Playing with the parameters for birth-rate and mutation-size alters the final values and variance of the runs but not the overall result. Higher birth-rate reduces the number of moves an individual agent has time for before being replaced. Lower mutation-size reduces the stochasticity of the mean, but requires a much longer run time before the mean foresight value stabilizes.

## EXTENDING THE MODEL

Try importing different types of surfaces, or even a landscape you're interested in classified by its presumed habitat quality. 

Introduce population growth, increase the range of the evaluated neighbourhood, or work out a way to share information between agents. Does increased information about the environment increase success or foresight?

## CREDITS AND REFERENCES

This model was designed for a paper submitted to the Journal of Human Evolution, submitted for publication in 2013.
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

sheep
false
0
Rectangle -7500403 true true 151 225 180 285
Rectangle -7500403 true true 47 225 75 285
Rectangle -7500403 true true 15 75 210 225
Circle -7500403 true true 135 75 150
Circle -16777216 true false 165 76 116

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
<experiments>
  <experiment name="Evo" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="50000"/>
    <metric>nummap</metric>
    <metric>mean [elevation] of agents</metric>
    <metric>mean [aforesight] of agents</metric>
    <enumeratedValueSet variable="N">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="foresight">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fmap">
      <value value="&quot;2.001&quot;"/>
      <value value="&quot;2.10&quot;"/>
      <value value="&quot;2.20&quot;"/>
      <value value="&quot;2.30&quot;"/>
      <value value="&quot;2.40&quot;"/>
      <value value="&quot;2.50&quot;"/>
      <value value="&quot;2.60&quot;"/>
      <value value="&quot;2.70&quot;"/>
      <value value="&quot;2.80&quot;"/>
      <value value="&quot;2.90&quot;"/>
      <value value="&quot;2.999&quot;"/>
    </enumeratedValueSet>
    <steppedValueSet variable="run#" first="1" step="1" last="100"/>
    <enumeratedValueSet variable="mutation-size">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="birth-rate">
      <value value="0.1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Evo - control" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="50000"/>
    <metric>nummap</metric>
    <metric>mean [elevation] of agents</metric>
    <metric>mean [aforesight] of agents</metric>
    <enumeratedValueSet variable="N">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="foresight">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fmap">
      <value value="&quot;2.001&quot;"/>
      <value value="&quot;2.10&quot;"/>
      <value value="&quot;2.20&quot;"/>
      <value value="&quot;2.30&quot;"/>
      <value value="&quot;2.40&quot;"/>
      <value value="&quot;2.50&quot;"/>
      <value value="&quot;2.60&quot;"/>
      <value value="&quot;2.70&quot;"/>
      <value value="&quot;2.80&quot;"/>
      <value value="&quot;2.90&quot;"/>
      <value value="&quot;2.999&quot;"/>
    </enumeratedValueSet>
    <steppedValueSet variable="run#" first="1" step="1" last="100"/>
    <enumeratedValueSet variable="mutation-size">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="birth-rate">
      <value value="0.1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Evo - fsplot" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <final>export-plot "AvgForesight" (word "evo/fsplot/f" nummap "_" run# ".csv")</final>
    <timeLimit steps="50000"/>
    <metric>nummap</metric>
    <metric>mean [elevation] of agents</metric>
    <metric>mean [aforesight] of agents</metric>
    <enumeratedValueSet variable="N">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="foresight">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fmap">
      <value value="&quot;2.001&quot;"/>
      <value value="&quot;2.10&quot;"/>
      <value value="&quot;2.20&quot;"/>
      <value value="&quot;2.30&quot;"/>
      <value value="&quot;2.40&quot;"/>
      <value value="&quot;2.50&quot;"/>
      <value value="&quot;2.60&quot;"/>
      <value value="&quot;2.70&quot;"/>
      <value value="&quot;2.80&quot;"/>
      <value value="&quot;2.90&quot;"/>
      <value value="&quot;2.999&quot;"/>
    </enumeratedValueSet>
    <steppedValueSet variable="run#" first="1" step="10" last="100"/>
    <enumeratedValueSet variable="mutation-size">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="birth-rate">
      <value value="0.1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Evo - fsplot - cone" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <final>export-plot "AvgForesight" (word "evo/fsplot/cone_" behaviorspace-run-number ".csv")</final>
    <timeLimit steps="50000"/>
    <metric>mean [elevation] of agents</metric>
    <metric>mean [aforesight] of agents</metric>
    <enumeratedValueSet variable="N">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="foresight">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fmap">
      <value value="&quot;cone&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="run#">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mutation-size">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="birth-rate">
      <value value="0.1"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
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
