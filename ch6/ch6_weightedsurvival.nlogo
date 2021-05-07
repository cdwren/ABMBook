extensions [Rnd]
turtles-own [ done age ]
globals [ birthrate_month deathrate_month ]
patches-own [ suitability ]

to setup
  ca

  ;; The model's timestep is one month, so the annual birthrates are divided into monthly values for use in the population dynamics
  set birthrate_month birthrate / 12
  ;; Deathrate setup options
  ifelse hs_death? = false [           ;deathrate is set to be equal to the birthrate which will keep the population roughly stable
    set deathrate_month birthrate_month
  ][ ;else hs_death? = true so use hs_benefit to sort out the effect of HS on deathrates by deriving a linear equation
    let death_hs_0.5 birthrate_month
    let death_hs_1.0 death_hs_0.5 - (birthrate_month * hs_benefit)
    set death_slope precision ((death_hs_1.0 - death_hs_0.5) / (1 - 0.5)) 7
    set death_yintercept precision (death_hs_1.0 + (-1 * death_slope * 1)) 7
  ]

  make-hills
  setup-turtles

  reset-ticks
end

to setup-turtles
  create-turtles number
  [
    set size 1 set shape "circle"
    set color cyan
    move-to one-of patches with [not any? turtles-here]
  ]
end

to go
  ask turtles [
    set age age + 1
    Reproduce
  ]

  ;; death routine with options for whether HS is considered in the death routine or not
  ifelse hs_death? [
    habitatsuitability_check_death
  ][
    Check_death
  ]

  tick
end

to Check_Death           ;in initial experiments (see supplement) habitat suitability is not considered in the deathrates
  ask turtles with [age > 0] [
      if random-float 1 < deathrate_month [die]
    ]
end

to habitatsuitability_check_death        ;calculates the deathrate based on the agent's current habitat suitability value (lower values = deathrate is higher)
  ask turtles with [age > 0] [
    if random-float 1 < (death_slope * suitability) + death_yintercept [die]          ;y = death_slope*x + death_yintercept    calculated in setup
  ]
end

to Reproduce
  if random-float 1 < birthrate_month [
    hatch 1 [
      set age 0
      ;the offspring agent moves to an empty suitable cell using a weighted-random-walk
      let p choose-patch 5
      ifelse p != nobody [move-to p][die]
    ]
  ]
end

to-report choose-patch [radius]                ;weighted random-select of an empty patch with suitability value as the weighting
  report rnd:weighted-one-of other patches in-radius radius with [suitability >= 0 and not any? turtles-here] [suitability]
end

to make-hills   ; Adjusted SugarScape from ch. 3
  let hills (patch-set patch (max-pxcor * .33) (max-pycor * .33) patch (max-pxcor * .67) (max-pycor * .67))
  ask patches [
    let dist distance min-one-of hills [distance myself]
    set suitability 1 - (distance min-one-of hills [distance myself] / (max-pxcor * .75))
  ]
  ask patches [ set pcolor scale-color green suitability 0 2 ]
end
@#$#@#$#@
GRAPHICS-WINDOW
160
50
548
439
-1
-1
3.8
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
30.0

BUTTON
60
10
115
43
go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
5
10
60
43
setup
setup
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
50
135
83
number
number
100
1000
1000.0
100
1
NIL
HORIZONTAL

SLIDER
5
85
135
118
birthrate
birthrate
0
0.4
0.176
.01
1
%/yr
HORIZONTAL

BUTTON
115
10
170
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

SWITCH
5
120
115
153
hs_death?
hs_death?
0
1
-1000

PLOT
555
50
755
200
Agent ages (months)
Age
Freequency
0.0
500.0
0.0
10.0
true
false
"" ""
PENS
"default" 10.0 1 -16777216 true "" "histogram [age] of turtles with [age < ticks]"

INPUTBOX
5
320
115
380
death_slope
-0.0293333
1
0
Number

INPUTBOX
5
380
115
440
death_yintercept
0.0293333
1
0
Number

SLIDER
15
155
125
188
hs_benefit
hs_benefit
0
1
1.0
0.25
1
NIL
HORIZONTAL

TEXTBOX
10
260
155
341
Calculated in setup using hs_benefit to determine the strength of the environmental impact on death rates.
11
0.0
1

PLOT
555
200
755
350
Population size
Ticks
Population
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot count turtles"

@#$#@#$#@
## WHAT IS IT?

Simplified version of the LGM Ecodynamics model by Wren & Burke.  

Wren, Colin D., and Ariane Burke. 2019. “Habitat Suitability and the Genetic Structure of Human Populations during the Last Glacial Maximum (LGM) in Western Europe.” PLOS ONE 14 (6): e0217996. https://doi.org/10.1371/journal.pone.0217996.

This is an example model used in chapter 6 of Romanowska, I., Wren, C., Crabtree, S. 2021. Agent-Based Modeling for Archaeology: Simulating the Complexity of Societies. Santa Fe, NM: SFI Press.

Code blocks: 6.18-6.19

## HOW IT WORKS

Agents reproduce at a rate specified by the birthrate slider, which is then divided in setup into a monthly probability. While agents themselves don't move, the hatch command during reproduction uses a weighted-random-walk to move offspring agents to better cells (suitability) if there is an empty one available. 

If hs_death? is off, death rates are equal to reproduction rates and the population size stays relatively stable (though populations often die off eventually due to stochasticity). If hs_death? is on, agents on less suitable cells (darker) are more likely to die and agents on more suitable cells (lighter green) are more likely to survive. *hs_benefit* controls the strength of this inverse linear relationship between death rate and suitability. 

## HOW TO USE IT

Choose the number of agents using the *number* slider, adjust *birthrate* based on your empirical evidence, and pick whether or not habitat suitability should impact death rates (*hs_death?*) and by how much (higher *hs_benefit* will more substantially decrease death rates for high suitability cells). Finally click on setup then on go.

## THINGS TO NOTICE

Over generations of agents, the population will tend to move towards hilltops whether *hs_death?* is on or not (though a little haphazardly if off). However, when *hs_death?* is on and *hs_benefit* is higher, the low suitability parts of the landscape will be increasingly difficult to survive on, leading to further concentration on the hill tops. 

When *hs_death?* is off, agent population sizes will oscillate but remain relatively constant. Additionally, the age histogram shows that the long term survival of individual agents is relatively unlikely.

When *hs_death?* is on, agent population size will grow faster on the hilltops leading to overall population increase, then flatten out as they fill up all suitability values above 0.5. The age histogram will also show that a handful of lucky agents on the top of the hill will live much longer.  


## THINGS TO TRY

Once you understand the population dynamics, look at the original LGM_ecodynamics code for how this code was implemented within their larger study. https://doi.org/10.25937/na38-tj46
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

box 2
false
0
Polygon -7500403 true true 150 285 270 225 270 90 150 150
Polygon -13791810 true false 150 150 30 90 150 30 270 90
Polygon -13345367 true false 30 90 30 225 150 285 150 150

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

train switcher engine
false
0
Polygon -7500403 true true 45 210 45 180 45 150 53 130 151 123 248 131 255 150 255 195 255 210 60 210
Circle -16777216 true false 225 195 30
Circle -16777216 true false 195 195 30
Circle -16777216 true false 75 195 30
Circle -16777216 true false 45 195 30
Line -7500403 true 150 135 150 165
Rectangle -7500403 true true 120 90 180 195
Rectangle -16777216 true false 132 98 170 120
Line -7500403 true 150 90 150 150
Rectangle -16777216 false false 120 90 180 180
Rectangle -7500403 true true 30 180 270 195
Rectangle -16777216 false false 30 180 270 195
Line -16777216 false 270 150 270 180
Rectangle -1 true false 245 131 252 138
Rectangle -1 true false 48 131 55 138
Polygon -16777216 true false 255 179 227 169 227 158 255 168
Polygon -16777216 true false 255 162 227 152 227 141 255 151
Polygon -16777216 true false 45 162 73 152 73 141 45 151
Polygon -16777216 true false 45 179 73 169 73 158 45 168
Rectangle -16777216 true false 112 195 187 210
Rectangle -16777216 true false 264 180 279 195
Rectangle -16777216 true false 21 180 36 195
Line -16777216 false 30 150 30 180
Line -16777216 false 120 98 180 98

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
  <experiment name="ex1" repetitions="10" sequentialRunOrder="false" runMetricsEveryStep="false">
    <setup>reset-timer
setup</setup>
    <go>go</go>
    <final>display-cores
ask groups [set size 4]
export-view (word "stills/ex1" "_wm" weight-move? "_rad" fradius "_" behaviorspace-run-number ".png")
display-occ2
export-view (word "stills/ex1" "_wm" weight-move? "_rad" fradius "_" behaviorspace-run-number "o.png")
export-plot "Regional population sizes" (word "stills/ex1" "_wm" weight-move? "_rad" fradius "_" behaviorspace-run-number ".csv")</final>
    <timeLimit steps="3000"/>
    <metric>count groups</metric>
    <metric>mean [port_freq] of groups with [region = 1]</metric>
    <metric>mean [spain_freq] of groups with [region = 1]</metric>
    <metric>mean [france_freq] of groups with [region = 1]</metric>
    <metric>mean [valencia_freq] of groups with [region = 1]</metric>
    <metric>mean [jura_freq] of groups with [region = 1]</metric>
    <metric>mean [italy_freq] of groups with [region = 1]</metric>
    <metric>mean [port_freq] of groups with [region = 2]</metric>
    <metric>mean [spain_freq] of groups with [region = 2]</metric>
    <metric>mean [france_freq] of groups with [region = 2]</metric>
    <metric>mean [valencia_freq] of groups with [region = 2]</metric>
    <metric>mean [jura_freq] of groups with [region = 2]</metric>
    <metric>mean [italy_freq] of groups with [region = 2]</metric>
    <metric>mean [port_freq] of groups with [region = 3]</metric>
    <metric>mean [spain_freq] of groups with [region = 3]</metric>
    <metric>mean [france_freq] of groups with [region = 3]</metric>
    <metric>mean [valencia_freq] of groups with [region = 3]</metric>
    <metric>mean [jura_freq] of groups with [region = 3]</metric>
    <metric>mean [italy_freq] of groups with [region = 3]</metric>
    <metric>mean [port_freq] of groups with [region = 4]</metric>
    <metric>mean [spain_freq] of groups with [region = 4]</metric>
    <metric>mean [france_freq] of groups with [region = 4]</metric>
    <metric>mean [valencia_freq] of groups with [region = 4]</metric>
    <metric>mean [jura_freq] of groups with [region = 4]</metric>
    <metric>mean [italy_freq] of groups with [region = 4]</metric>
    <metric>mean [port_freq] of groups with [region = 5]</metric>
    <metric>mean [spain_freq] of groups with [region = 5]</metric>
    <metric>mean [france_freq] of groups with [region = 5]</metric>
    <metric>mean [valencia_freq] of groups with [region = 5]</metric>
    <metric>mean [jura_freq] of groups with [region = 5]</metric>
    <metric>mean [italy_freq] of groups with [region = 5]</metric>
    <metric>mean [port_freq] of groups with [region = 6]</metric>
    <metric>mean [spain_freq] of groups with [region = 6]</metric>
    <metric>mean [france_freq] of groups with [region = 6]</metric>
    <metric>mean [valencia_freq] of groups with [region = 6]</metric>
    <metric>mean [jura_freq] of groups with [region = 6]</metric>
    <metric>mean [italy_freq] of groups with [region = 6]</metric>
    <metric>count groups with [region = 1]</metric>
    <metric>count groups with [region = 2]</metric>
    <metric>count groups with [region = 3]</metric>
    <metric>count groups with [region = 4]</metric>
    <metric>count groups with [region = 5]</metric>
    <metric>count groups with [region = 6]</metric>
    <metric>mean [suitability] of groups</metric>
    <metric>mean [suitability] of groups with [region = 1]</metric>
    <metric>mean [suitability] of groups with [region = 2]</metric>
    <metric>mean [suitability] of groups with [region = 3]</metric>
    <metric>mean [suitability] of groups with [region = 4]</metric>
    <metric>mean [suitability] of groups with [region = 5]</metric>
    <metric>mean [suitability] of groups with [region = 6]</metric>
    <metric>death_slope</metric>
    <metric>death_yintercept</metric>
    <metric>timer</metric>
    <enumeratedValueSet variable="number">
      <value value="7000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="birthrate">
      <value value="0.176"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="weight-move?">
      <value value="false"/>
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fradius">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-ticks">
      <value value="3001"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trait_list_size">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hs_death?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hs_benefit">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="idw-weight">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="plots?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="plotpop-on?">
      <value value="true"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="ex2" repetitions="10" sequentialRunOrder="false" runMetricsEveryStep="false">
    <setup>reset-timer
setup</setup>
    <go>go</go>
    <final>display-cores
ask groups [set size 4]
export-view (word "stills/ex2" "_wm" weight-move? "_rad" fradius "_" behaviorspace-run-number ".png")
display-occ2
export-view (word "stills/ex2" "_wm" weight-move? "_rad" fradius "_" behaviorspace-run-number "o.png")
export-plot "Regional population sizes" (word "stills/ex2" "_wm" weight-move? "_rad" fradius "_" behaviorspace-run-number ".csv")</final>
    <timeLimit steps="3000"/>
    <metric>count groups</metric>
    <metric>mean [port_freq] of groups with [region = 1]</metric>
    <metric>mean [spain_freq] of groups with [region = 1]</metric>
    <metric>mean [france_freq] of groups with [region = 1]</metric>
    <metric>mean [valencia_freq] of groups with [region = 1]</metric>
    <metric>mean [jura_freq] of groups with [region = 1]</metric>
    <metric>mean [italy_freq] of groups with [region = 1]</metric>
    <metric>mean [port_freq] of groups with [region = 2]</metric>
    <metric>mean [spain_freq] of groups with [region = 2]</metric>
    <metric>mean [france_freq] of groups with [region = 2]</metric>
    <metric>mean [valencia_freq] of groups with [region = 2]</metric>
    <metric>mean [jura_freq] of groups with [region = 2]</metric>
    <metric>mean [italy_freq] of groups with [region = 2]</metric>
    <metric>mean [port_freq] of groups with [region = 3]</metric>
    <metric>mean [spain_freq] of groups with [region = 3]</metric>
    <metric>mean [france_freq] of groups with [region = 3]</metric>
    <metric>mean [valencia_freq] of groups with [region = 3]</metric>
    <metric>mean [jura_freq] of groups with [region = 3]</metric>
    <metric>mean [italy_freq] of groups with [region = 3]</metric>
    <metric>mean [port_freq] of groups with [region = 4]</metric>
    <metric>mean [spain_freq] of groups with [region = 4]</metric>
    <metric>mean [france_freq] of groups with [region = 4]</metric>
    <metric>mean [valencia_freq] of groups with [region = 4]</metric>
    <metric>mean [jura_freq] of groups with [region = 4]</metric>
    <metric>mean [italy_freq] of groups with [region = 4]</metric>
    <metric>mean [port_freq] of groups with [region = 5]</metric>
    <metric>mean [spain_freq] of groups with [region = 5]</metric>
    <metric>mean [france_freq] of groups with [region = 5]</metric>
    <metric>mean [valencia_freq] of groups with [region = 5]</metric>
    <metric>mean [jura_freq] of groups with [region = 5]</metric>
    <metric>mean [italy_freq] of groups with [region = 5]</metric>
    <metric>mean [port_freq] of groups with [region = 6]</metric>
    <metric>mean [spain_freq] of groups with [region = 6]</metric>
    <metric>mean [france_freq] of groups with [region = 6]</metric>
    <metric>mean [valencia_freq] of groups with [region = 6]</metric>
    <metric>mean [jura_freq] of groups with [region = 6]</metric>
    <metric>mean [italy_freq] of groups with [region = 6]</metric>
    <metric>count groups with [region = 1]</metric>
    <metric>count groups with [region = 2]</metric>
    <metric>count groups with [region = 3]</metric>
    <metric>count groups with [region = 4]</metric>
    <metric>count groups with [region = 5]</metric>
    <metric>count groups with [region = 6]</metric>
    <metric>mean [suitability] of groups</metric>
    <metric>mean [suitability] of groups with [region = 1]</metric>
    <metric>mean [suitability] of groups with [region = 2]</metric>
    <metric>mean [suitability] of groups with [region = 3]</metric>
    <metric>mean [suitability] of groups with [region = 4]</metric>
    <metric>mean [suitability] of groups with [region = 5]</metric>
    <metric>mean [suitability] of groups with [region = 6]</metric>
    <metric>death_slope</metric>
    <metric>death_yintercept</metric>
    <metric>timer</metric>
    <enumeratedValueSet variable="number">
      <value value="7000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="birthrate">
      <value value="0.176"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="weight-move?">
      <value value="true"/>
    </enumeratedValueSet>
    <steppedValueSet variable="fradius" first="10" step="10" last="40"/>
    <enumeratedValueSet variable="max-ticks">
      <value value="3001"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trait_list_size">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hs_death?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hs_benefit">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="idw-weight">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="plots?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="plotpop-on?">
      <value value="true"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="ex3_r10" repetitions="10" sequentialRunOrder="false" runMetricsEveryStep="false">
    <setup>reset-timer
setup</setup>
    <go>go</go>
    <final>display-cores
ask groups [set size 4]
export-view (word "stills/ex3" "_wm" weight-move? "_rad" fradius "_hsben" hs_benefit "_" behaviorspace-run-number ".png")
display-occ2
export-view (word "stills/ex3" "_wm" weight-move? "_rad" fradius "_hsben" hs_benefit "_" behaviorspace-run-number "o.png")
export-plot "Regional population sizes" (word "stills/ex3" "_wm" weight-move? "_rad" fradius "_hsben" hs_benefit "_" behaviorspace-run-number ".csv")</final>
    <timeLimit steps="3000"/>
    <metric>count groups</metric>
    <metric>mean [port_freq] of groups with [region = 1]</metric>
    <metric>mean [spain_freq] of groups with [region = 1]</metric>
    <metric>mean [france_freq] of groups with [region = 1]</metric>
    <metric>mean [valencia_freq] of groups with [region = 1]</metric>
    <metric>mean [jura_freq] of groups with [region = 1]</metric>
    <metric>mean [italy_freq] of groups with [region = 1]</metric>
    <metric>mean [port_freq] of groups with [region = 2]</metric>
    <metric>mean [spain_freq] of groups with [region = 2]</metric>
    <metric>mean [france_freq] of groups with [region = 2]</metric>
    <metric>mean [valencia_freq] of groups with [region = 2]</metric>
    <metric>mean [jura_freq] of groups with [region = 2]</metric>
    <metric>mean [italy_freq] of groups with [region = 2]</metric>
    <metric>mean [port_freq] of groups with [region = 3]</metric>
    <metric>mean [spain_freq] of groups with [region = 3]</metric>
    <metric>mean [france_freq] of groups with [region = 3]</metric>
    <metric>mean [valencia_freq] of groups with [region = 3]</metric>
    <metric>mean [jura_freq] of groups with [region = 3]</metric>
    <metric>mean [italy_freq] of groups with [region = 3]</metric>
    <metric>mean [port_freq] of groups with [region = 4]</metric>
    <metric>mean [spain_freq] of groups with [region = 4]</metric>
    <metric>mean [france_freq] of groups with [region = 4]</metric>
    <metric>mean [valencia_freq] of groups with [region = 4]</metric>
    <metric>mean [jura_freq] of groups with [region = 4]</metric>
    <metric>mean [italy_freq] of groups with [region = 4]</metric>
    <metric>mean [port_freq] of groups with [region = 5]</metric>
    <metric>mean [spain_freq] of groups with [region = 5]</metric>
    <metric>mean [france_freq] of groups with [region = 5]</metric>
    <metric>mean [valencia_freq] of groups with [region = 5]</metric>
    <metric>mean [jura_freq] of groups with [region = 5]</metric>
    <metric>mean [italy_freq] of groups with [region = 5]</metric>
    <metric>mean [port_freq] of groups with [region = 6]</metric>
    <metric>mean [spain_freq] of groups with [region = 6]</metric>
    <metric>mean [france_freq] of groups with [region = 6]</metric>
    <metric>mean [valencia_freq] of groups with [region = 6]</metric>
    <metric>mean [jura_freq] of groups with [region = 6]</metric>
    <metric>mean [italy_freq] of groups with [region = 6]</metric>
    <metric>count groups with [region = 1]</metric>
    <metric>count groups with [region = 2]</metric>
    <metric>count groups with [region = 3]</metric>
    <metric>count groups with [region = 4]</metric>
    <metric>count groups with [region = 5]</metric>
    <metric>count groups with [region = 6]</metric>
    <metric>mean [suitability] of groups</metric>
    <metric>mean [suitability] of groups with [region = 1]</metric>
    <metric>mean [suitability] of groups with [region = 2]</metric>
    <metric>mean [suitability] of groups with [region = 3]</metric>
    <metric>mean [suitability] of groups with [region = 4]</metric>
    <metric>mean [suitability] of groups with [region = 5]</metric>
    <metric>mean [suitability] of groups with [region = 6]</metric>
    <metric>death_slope</metric>
    <metric>death_yintercept</metric>
    <metric>timer</metric>
    <enumeratedValueSet variable="number">
      <value value="7000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="birthrate">
      <value value="0.176"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="weight-move?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fradius">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-ticks">
      <value value="3001"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trait_list_size">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hs_death?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hs_benefit">
      <value value="0"/>
      <value value="0.25"/>
      <value value="0.5"/>
      <value value="0.75"/>
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="idw-weight">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="plots?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="plotpop-on?">
      <value value="true"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="ex3_r20" repetitions="10" sequentialRunOrder="false" runMetricsEveryStep="false">
    <setup>reset-timer
setup</setup>
    <go>go</go>
    <final>display-cores
ask groups [set size 4]
export-view (word "stills/ex3" "_wm" weight-move? "_rad" fradius "_hsben" hs_benefit "_" behaviorspace-run-number ".png")
display-occ2
export-view (word "stills/ex3" "_wm" weight-move? "_rad" fradius "_hsben" hs_benefit "_" behaviorspace-run-number "o.png")
export-plot "Regional population sizes" (word "stills/ex3" "_wm" weight-move? "_rad" fradius "_hsben" hs_benefit "_" behaviorspace-run-number ".csv")</final>
    <timeLimit steps="3000"/>
    <metric>count groups</metric>
    <metric>mean [port_freq] of groups with [region = 1]</metric>
    <metric>mean [spain_freq] of groups with [region = 1]</metric>
    <metric>mean [france_freq] of groups with [region = 1]</metric>
    <metric>mean [valencia_freq] of groups with [region = 1]</metric>
    <metric>mean [jura_freq] of groups with [region = 1]</metric>
    <metric>mean [italy_freq] of groups with [region = 1]</metric>
    <metric>mean [port_freq] of groups with [region = 2]</metric>
    <metric>mean [spain_freq] of groups with [region = 2]</metric>
    <metric>mean [france_freq] of groups with [region = 2]</metric>
    <metric>mean [valencia_freq] of groups with [region = 2]</metric>
    <metric>mean [jura_freq] of groups with [region = 2]</metric>
    <metric>mean [italy_freq] of groups with [region = 2]</metric>
    <metric>mean [port_freq] of groups with [region = 3]</metric>
    <metric>mean [spain_freq] of groups with [region = 3]</metric>
    <metric>mean [france_freq] of groups with [region = 3]</metric>
    <metric>mean [valencia_freq] of groups with [region = 3]</metric>
    <metric>mean [jura_freq] of groups with [region = 3]</metric>
    <metric>mean [italy_freq] of groups with [region = 3]</metric>
    <metric>mean [port_freq] of groups with [region = 4]</metric>
    <metric>mean [spain_freq] of groups with [region = 4]</metric>
    <metric>mean [france_freq] of groups with [region = 4]</metric>
    <metric>mean [valencia_freq] of groups with [region = 4]</metric>
    <metric>mean [jura_freq] of groups with [region = 4]</metric>
    <metric>mean [italy_freq] of groups with [region = 4]</metric>
    <metric>mean [port_freq] of groups with [region = 5]</metric>
    <metric>mean [spain_freq] of groups with [region = 5]</metric>
    <metric>mean [france_freq] of groups with [region = 5]</metric>
    <metric>mean [valencia_freq] of groups with [region = 5]</metric>
    <metric>mean [jura_freq] of groups with [region = 5]</metric>
    <metric>mean [italy_freq] of groups with [region = 5]</metric>
    <metric>mean [port_freq] of groups with [region = 6]</metric>
    <metric>mean [spain_freq] of groups with [region = 6]</metric>
    <metric>mean [france_freq] of groups with [region = 6]</metric>
    <metric>mean [valencia_freq] of groups with [region = 6]</metric>
    <metric>mean [jura_freq] of groups with [region = 6]</metric>
    <metric>mean [italy_freq] of groups with [region = 6]</metric>
    <metric>count groups with [region = 1]</metric>
    <metric>count groups with [region = 2]</metric>
    <metric>count groups with [region = 3]</metric>
    <metric>count groups with [region = 4]</metric>
    <metric>count groups with [region = 5]</metric>
    <metric>count groups with [region = 6]</metric>
    <metric>mean [suitability] of groups</metric>
    <metric>mean [suitability] of groups with [region = 1]</metric>
    <metric>mean [suitability] of groups with [region = 2]</metric>
    <metric>mean [suitability] of groups with [region = 3]</metric>
    <metric>mean [suitability] of groups with [region = 4]</metric>
    <metric>mean [suitability] of groups with [region = 5]</metric>
    <metric>mean [suitability] of groups with [region = 6]</metric>
    <metric>death_slope</metric>
    <metric>death_yintercept</metric>
    <metric>timer</metric>
    <enumeratedValueSet variable="number">
      <value value="7000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="birthrate">
      <value value="0.176"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="weight-move?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fradius">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-ticks">
      <value value="3001"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trait_list_size">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hs_death?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hs_benefit">
      <value value="0"/>
      <value value="0.25"/>
      <value value="0.5"/>
      <value value="0.75"/>
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="idw-weight">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="plots?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="plotpop-on?">
      <value value="true"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="ex3_r40" repetitions="1" sequentialRunOrder="false" runMetricsEveryStep="false">
    <setup>reset-timer
setup</setup>
    <go>go</go>
    <final>display-cores
ask groups [set size 4]
let randnum random 100
export-view (word "stills/ex3" "_wm" weight-move? "_rad" fradius "_hsben" hs_benefit "_" behaviorspace-run-number randnum ".png")
display-occ2
export-view (word "stills/ex3" "_wm" weight-move? "_rad" fradius "_hsben" hs_benefit "_" behaviorspace-run-number randnum "o.png")
export-plot "Regional population sizes" (word "stills/ex3" "_wm" weight-move? "_rad" fradius "_hsben" hs_benefit "_" behaviorspace-run-number randnum ".csv")</final>
    <timeLimit steps="3000"/>
    <metric>count groups</metric>
    <metric>mean [port_freq] of groups with [region = 1]</metric>
    <metric>mean [spain_freq] of groups with [region = 1]</metric>
    <metric>mean [france_freq] of groups with [region = 1]</metric>
    <metric>mean [valencia_freq] of groups with [region = 1]</metric>
    <metric>mean [jura_freq] of groups with [region = 1]</metric>
    <metric>mean [italy_freq] of groups with [region = 1]</metric>
    <metric>mean [port_freq] of groups with [region = 2]</metric>
    <metric>mean [spain_freq] of groups with [region = 2]</metric>
    <metric>mean [france_freq] of groups with [region = 2]</metric>
    <metric>mean [valencia_freq] of groups with [region = 2]</metric>
    <metric>mean [jura_freq] of groups with [region = 2]</metric>
    <metric>mean [italy_freq] of groups with [region = 2]</metric>
    <metric>mean [port_freq] of groups with [region = 3]</metric>
    <metric>mean [spain_freq] of groups with [region = 3]</metric>
    <metric>mean [france_freq] of groups with [region = 3]</metric>
    <metric>mean [valencia_freq] of groups with [region = 3]</metric>
    <metric>mean [jura_freq] of groups with [region = 3]</metric>
    <metric>mean [italy_freq] of groups with [region = 3]</metric>
    <metric>mean [port_freq] of groups with [region = 4]</metric>
    <metric>mean [spain_freq] of groups with [region = 4]</metric>
    <metric>mean [france_freq] of groups with [region = 4]</metric>
    <metric>mean [valencia_freq] of groups with [region = 4]</metric>
    <metric>mean [jura_freq] of groups with [region = 4]</metric>
    <metric>mean [italy_freq] of groups with [region = 4]</metric>
    <metric>mean [port_freq] of groups with [region = 5]</metric>
    <metric>mean [spain_freq] of groups with [region = 5]</metric>
    <metric>mean [france_freq] of groups with [region = 5]</metric>
    <metric>mean [valencia_freq] of groups with [region = 5]</metric>
    <metric>mean [jura_freq] of groups with [region = 5]</metric>
    <metric>mean [italy_freq] of groups with [region = 5]</metric>
    <metric>mean [port_freq] of groups with [region = 6]</metric>
    <metric>mean [spain_freq] of groups with [region = 6]</metric>
    <metric>mean [france_freq] of groups with [region = 6]</metric>
    <metric>mean [valencia_freq] of groups with [region = 6]</metric>
    <metric>mean [jura_freq] of groups with [region = 6]</metric>
    <metric>mean [italy_freq] of groups with [region = 6]</metric>
    <metric>count groups with [region = 1]</metric>
    <metric>count groups with [region = 2]</metric>
    <metric>count groups with [region = 3]</metric>
    <metric>count groups with [region = 4]</metric>
    <metric>count groups with [region = 5]</metric>
    <metric>count groups with [region = 6]</metric>
    <metric>mean [suitability] of groups</metric>
    <metric>mean [suitability] of groups with [region = 1]</metric>
    <metric>mean [suitability] of groups with [region = 2]</metric>
    <metric>mean [suitability] of groups with [region = 3]</metric>
    <metric>mean [suitability] of groups with [region = 4]</metric>
    <metric>mean [suitability] of groups with [region = 5]</metric>
    <metric>mean [suitability] of groups with [region = 6]</metric>
    <metric>death_slope</metric>
    <metric>death_yintercept</metric>
    <metric>timer</metric>
    <enumeratedValueSet variable="number">
      <value value="7000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="birthrate">
      <value value="0.176"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="weight-move?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fradius">
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-ticks">
      <value value="3001"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trait_list_size">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hs_death?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hs_benefit">
      <value value="0"/>
      <value value="0.25"/>
      <value value="0.5"/>
      <value value="0.75"/>
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="idw-weight">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="plots?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="plotpop-on?">
      <value value="true"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="ex1_test" repetitions="10" sequentialRunOrder="false" runMetricsEveryStep="false">
    <setup>reset-timer
setup</setup>
    <go>go</go>
    <final>display-cores
ask groups [set size 4]
export-view (word "stills/ex1" "_wm" weight-move? "_rad" fradius "_" behaviorspace-run-number ".png")
display-occ2
export-view (word "stills/ex1" "_wm" weight-move? "_rad" fradius "_" behaviorspace-run-number "o.png")
export-plot "Regional population sizes" (word "stills/s1" "_wm" weight-move? "_rad" fradius "_" behaviorspace-run-number ".csv")</final>
    <timeLimit steps="30"/>
    <metric>count groups</metric>
    <metric>mean [port_freq] of groups with [region = 1]</metric>
    <metric>mean [spain_freq] of groups with [region = 1]</metric>
    <metric>mean [france_freq] of groups with [region = 1]</metric>
    <metric>mean [valencia_freq] of groups with [region = 1]</metric>
    <metric>mean [jura_freq] of groups with [region = 1]</metric>
    <metric>mean [italy_freq] of groups with [region = 1]</metric>
    <metric>mean [port_freq] of groups with [region = 2]</metric>
    <metric>mean [spain_freq] of groups with [region = 2]</metric>
    <metric>mean [france_freq] of groups with [region = 2]</metric>
    <metric>mean [valencia_freq] of groups with [region = 2]</metric>
    <metric>mean [jura_freq] of groups with [region = 2]</metric>
    <metric>mean [italy_freq] of groups with [region = 2]</metric>
    <metric>mean [port_freq] of groups with [region = 3]</metric>
    <metric>mean [spain_freq] of groups with [region = 3]</metric>
    <metric>mean [france_freq] of groups with [region = 3]</metric>
    <metric>mean [valencia_freq] of groups with [region = 3]</metric>
    <metric>mean [jura_freq] of groups with [region = 3]</metric>
    <metric>mean [italy_freq] of groups with [region = 3]</metric>
    <metric>mean [port_freq] of groups with [region = 4]</metric>
    <metric>mean [spain_freq] of groups with [region = 4]</metric>
    <metric>mean [france_freq] of groups with [region = 4]</metric>
    <metric>mean [valencia_freq] of groups with [region = 4]</metric>
    <metric>mean [jura_freq] of groups with [region = 4]</metric>
    <metric>mean [italy_freq] of groups with [region = 4]</metric>
    <metric>mean [port_freq] of groups with [region = 5]</metric>
    <metric>mean [spain_freq] of groups with [region = 5]</metric>
    <metric>mean [france_freq] of groups with [region = 5]</metric>
    <metric>mean [valencia_freq] of groups with [region = 5]</metric>
    <metric>mean [jura_freq] of groups with [region = 5]</metric>
    <metric>mean [italy_freq] of groups with [region = 5]</metric>
    <metric>mean [port_freq] of groups with [region = 6]</metric>
    <metric>mean [spain_freq] of groups with [region = 6]</metric>
    <metric>mean [france_freq] of groups with [region = 6]</metric>
    <metric>mean [valencia_freq] of groups with [region = 6]</metric>
    <metric>mean [jura_freq] of groups with [region = 6]</metric>
    <metric>mean [italy_freq] of groups with [region = 6]</metric>
    <metric>count groups with [region = 1]</metric>
    <metric>count groups with [region = 2]</metric>
    <metric>count groups with [region = 3]</metric>
    <metric>count groups with [region = 4]</metric>
    <metric>count groups with [region = 5]</metric>
    <metric>count groups with [region = 6]</metric>
    <metric>mean [suitability] of groups</metric>
    <metric>mean [suitability] of groups with [region = 1]</metric>
    <metric>mean [suitability] of groups with [region = 2]</metric>
    <metric>mean [suitability] of groups with [region = 3]</metric>
    <metric>mean [suitability] of groups with [region = 4]</metric>
    <metric>mean [suitability] of groups with [region = 5]</metric>
    <metric>mean [suitability] of groups with [region = 6]</metric>
    <metric>death_slope</metric>
    <metric>death_yintercept</metric>
    <metric>timer</metric>
    <enumeratedValueSet variable="number">
      <value value="7000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="birthrate">
      <value value="0.176"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="weight-move?">
      <value value="false"/>
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fradius">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-ticks">
      <value value="3001"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trait_list_size">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hs_death?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hs_benefit">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="idw-weight">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="plots?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="plotpop-on?">
      <value value="true"/>
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
1
@#$#@#$#@
