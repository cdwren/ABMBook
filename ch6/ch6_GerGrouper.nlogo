globals [
  grass
  summer-patches
  winter-patches
]

breed [
  lineageA lineA ;; 100% cooperation
]
breed [
  lineageB lineB;; 50% cooperation
]
breed [
  lineageC lineC;; 25% cooperation
]
breed [
  lineageD lineD;; 0% cooperation
]

turtles-own [
  visited-patches
  energy
  trait
]

patches-own [countdown]

to setup
  ca ;; shorthand for "clear all"
  create-lineageA N
  [
    set shape "ger"
    set size 3
    setxy random-xcor random-ycor
    set trait random 1000
    set label lineageA
    set energy 20
    set color blue
    set visited-patches (list patch-here)
  ]
  create-lineageB N
  [
    set shape "ger"
    set size 3
    setxy random-xcor random-ycor
    set trait random 1000
    set label lineageB
    set energy 20
    set color pink
    set visited-patches (list patch-here)
  ]
  create-lineageC N
  [
    set shape "ger"
    set size 3
    setxy random-xcor random-ycor
    set trait random 1000
    set label trait
    set label lineageC
    set energy 20
    set color red
    set visited-patches (list patch-here)
  ]
  create-lineageD N
  [
    set shape "ger"
    set size 3
    setxy random-xcor random-ycor
    set trait random 1000
    set energy 20
    set label lineageD
    set color yellow
    set visited-patches (list patch-here)
  ]

  set summer-patches patches with [ pxcor < 0 ]
  ask summer-patches [ set pcolor green ] ;;one-of [ green brown ]]

  set winter-patches patches with [ pxcor >= 0 ]
  ask winter-patches  [ set countdown random grass-regrowth-time ;; initialize grass grow clocks randomly
    ifelse random-float 1 < 0.5 [ set pcolor grey ]
  [
    ifelse random-float 1 < 0.33 [ set pcolor green ][ set pcolor brown]
  ]
  ]

  ask patches [
    set countdown random grass-regrowth-time ;; initialize grass grow clocks randomly
  ]
  ;;  ]

  file-open "ger_grouper2.csv"
  file-close

  reset-ticks

  ;;  tick

end


to go
  if not any? turtles [ stop ]
  if ticks >= 500 [ stop ]

  move_spring
  ask turtles [
    set energy energy - energy-loss-from-dead-patches  ;; deduct energy if they land on a bad patch
    eat-grass
  ]
  ;; write-spring

  move_autumn
  ask turtles [
    set energy energy - energy-loss-from-dead-patches  ;; deduct energy if they land on a bad patch
    eat-grass

    update-history
  ]

  ask lineageA [
    if energy <= 10 [
      ask one-of lineageA in-radius 5 [
        set energy energy + 10 ]
      set energy energy - 10
    ]
  ]
  ask lineageB [
    if energy <= 10 [
      if random-float 100 < 50 [
        ask one-of lineageB in-radius 5 [
          set energy energy + 10 ]
        set energy energy - 10
      ]
    ]
  ]

  ask lineageC [
    if energy <= 10 [
      if random-float 100 < 25 [
        ask one-of lineageC in-radius 5 [
          set energy energy + 10 ]
        set energy energy - 10
      ]
    ]
  ]
  ;;  write-autumn

  ask patches
  [ grow-grass ]
  set grass count patches with [pcolor = green]

  if count turtles >= 500
  [ stop ]

  ask patches
  [ variability ]

end

to move_spring
  ask turtles
  [
    move-to-empty-one-of summer-patches
    if pcolor != green [
      ifelse any? neighbors with [ pcolor = green ]
      [
        move-to one-of neighbors with [ pcolor = green ]
        set energy energy - 1 + ger-gain-from-food
      ]
      [
        set energy energy - energy-loss-from-dead-patches ;; deduct energy if they don't end up on a green patch
      ]
    ]
  ]
  tick
end

to move_autumn
  ask turtles [
    if ticks >= 2 [
      move-to one-of visited-patches
      move-to-empty-one-of winter-patches
    ]
  ]

  ; ask patch
  ; if the patch is brown, a.k.a dead
  ; look at your neighborhood
  ; if you find a patch in the neighborhood that's green move there

  ask turtles [
    if pcolor != green [
      ifelse any? neighbors with [ pcolor = green ]
      [
        move-to one-of neighbors with [ pcolor = green ]
        set energy energy - 1 + ger-gain-from-food
      ]
      [
        set energy energy - energy-loss-from-dead-patches ;; deduct energy if they don't end up on a green patch
      ]
      set label round energy

      death
      reproduce-gers
    ]
  ]
  tick
end

to eat-grass  ;; get procedure
              ;; get eat grass, turn the patch brown
  if pcolor = green [
    set pcolor brown
    set energy energy + ger-gain-from-food  ;; ger gain energy by eating
  ]
end

to variability
  if random-float 100 < patch-variability
  [
    if pcolor = green  [
      set pcolor brown ]
  ]
end

to reproduce-gers1  ;; ger procedure
  if energy >= 20 [
    if random-float 100 < gerreproduce [  ;; throw "dice" to see if you will reproduce
      set energy (energy / 2)   ;; divide energy between parent and offspring
      hatch 1 [ rt random-float 360 fd 1 ]
    ]
  ]
end


to reproduce-gers  ;; ger procedure
  if energy >= 20 [
    if random-float 100 < gerreproduce [  ;; throw "dice" to see if you will reproduce

      let target-patch one-of neighbors with [count turtles-here = 0]
      if target-patch != nobody [
        set energy (energy / 2)           ;; divide energy between parent and offspring
        hatch 1   [
        move-to target-patch
        ]
    ]
  ]
  ]
end

to death  ;; turtle procedure
          ;  when energy dips below zero, die
  if energy < 5 [ die ]
end

to grow-grass  ;; patch procedure
               ;; countdown on brown patches: if reach 0, grow some grass
  if pcolor = brown [
    ifelse countdown <= 0
      [ set pcolor green
        set countdown grass-regrowth-time ]
    [ set countdown countdown - 1 ]
  ]
end

to move-to-empty-one-of [locations]  ;; turtle procedure
  move-to one-of locations
  while [any? other turtles-here] [
    move-to one-of locations
  ]

end

;; here the gers remember the last 4 patches they went to that were green
;; since update-history is only called in the winter
;; the gers only remember the last few winter camps that were productive

to update-history
  if pcolor = green
  [
    set visited-patches (lput patch-here visited-patches)
  ]
end

;;to write-autumn
;;file-open "ger_grouper2.csv"
;;file-type (word behaviorspace-run-number ",")
;;file-type (word ticks ",")
;;file-type (word seed ",")
;;file-type (word count lineageA",")
;;file-type (word count lineageB",")
;;file-type (word count lineageC",")
;;file-type (word count lineageD",")
;;file-type (word N ",")
;;file-type (word gerreproduce ",")
;;file-type (word patch-variability ",")
;;file-type (word ger-gain-from-food ",")
;;file-type (word grass-regrowth-time ",")
;;file-print (word energy-loss-from-dead-patches ",")

;;file-close
;;end

;;to write-spring
;;file-open "ger_grouper2.csv"
;;file-type (word behaviorspace-run-number ",")
;;file-type (word ticks ",")
;;file-type (word seed ",")
;;file-type (word count lineageA",")
;;file-type (word count lineageB",")
;;file-type (word count lineageC",")
;;file-type (word count lineageD",")
;;file-type (word N ",")
;;file-type (word gerreproduce ",")
;;file-type (word patch-variability ",")
;;file-type (word ger-gain-from-food ",")
;;file-type (word grass-regrowth-time ",")
;;file-print (word energy-loss-from-dead-patches ",")

;;file-close
;;end
@#$#@#$#@
GRAPHICS-WINDOW
606
10
1139
544
-1
-1
12.805
1
10
1
1
1
0
0
0
1
-20
20
-20
20
0
0
1
ticks
30.0

SLIDER
63
75
235
108
seed
seed
0
1000
822.0
1
1
NIL
HORIZONTAL

SLIDER
63
110
235
143
N
N
1
20
5.0
1
1
NIL
HORIZONTAL

BUTTON
271
89
337
122
NIL
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

BUTTON
271
134
334
167
NIL
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
271
177
334
210
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

PLOT
361
47
561
197
populations
time
pop.
0.0
50.0
0.0
100.0
true
false
"" ""
PENS
"gers" 1.0 0 -10022847 true "" "plot count turtles"

SLIDER
63
213
248
246
grass-regrowth-time
grass-regrowth-time
0
20
5.0
1
1
NIL
HORIZONTAL

SLIDER
63
178
243
211
ger-gain-from-food
ger-gain-from-food
0
50
5.0
1
1
NIL
HORIZONTAL

SLIDER
63
247
312
280
energy-loss-from-dead-patches
energy-loss-from-dead-patches
0
20
5.0
1
1
NIL
HORIZONTAL

SLIDER
63
144
235
177
patch-variability
patch-variability
0
100
20.0
1
1
NIL
HORIZONTAL

PLOT
45
308
584
551
Population by lineage
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"A-100" 1.0 0 -13791810 true "" "plot count lineageA"
"B-50" 1.0 0 -3508570 true "" "plot count lineageB"
"C-25" 1.0 0 -5298144 true "" "plot count lineageC"
"D-0" 1.0 0 -1184463 true "" "plot count lineageD"

SLIDER
63
41
235
74
gerreproduce
gerreproduce
0
20
5.0
1
1
%
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

This model was designed to explore fission/fusion dynamics among semi-nomadic pastoralists in Mongolia. Anecdotal information states that Mongolians cluster into groups of 4 to 6 nuclear families during wintertime. However, this has never been truly tested. This model makes an attempt at understanding what a very basic distribution of households would be on a patchy environment when these households are trying to maximize their own fitness.

Clark, Julia K., Stefani A. Crabtree. 2015. “Examining Social Adaptations in a Volatile Landscape in Northern Mongolia Via the Agent-Based Model Ger Grouper.” Land 2015, 4(1), 157-181; doi:10.3390/land4010157. http://www.mdpi.com/2073-445X/4/1/157

This is example model used in chapter 6 of Romanowska, I., Wren, C., Crabtree, S. 2021 Agent-Based Modeling for Archaeology: Simulating the Complexity of Societies. Santa Fe Institute Press.

Code blocks: 6.13

## ENTITIES, STATE VARIABLES AND SCALES

This model has three kinds of entities: gers, green patches and brown patches.

Gers: in Mongolia, gers are the yurt-like housing unit ubiquitous across the country (Honeychurch and Amartuvshin 2010). In this model agents are represented by gers, each ger representing one household.

Green patches: These are "productive" during autumn. When an agent lands on one they gain one resource.

Brown patches: These are "unproductive" during autumn. When an agent lands on one they lose one resource.

The landscape consists of 40 x 40 patches. In reality a ger's footprint could be up to a few kilometers (because of the animals they posess). Here, we assume one "cell" will be enough to sustain a ger and it does not represent real space.

## PROCESS OVERVIEW AND SCHEDULING

The ony process in the model is the movement of the gers. However, this movement happens in two seasons: spring and autumn. During each of these seasons each ger moves once. The order of execution of movement does not matter since there is no interaction among the gers.

## DESIGN CONCEPTS

The basic principle addressed by Ger Grouper is the concept of locational decision making. This concept, and how it relates to potential emergence of fission/fusion dynamics, is explored in this model.

Gers do not have perfect world knowledge, but use sensing to determine the productivity of the patch they are on relative to patches around them. In the spring gers choose a random direction and move 10 cells. In the autumn gers choose a random direction and move 10 cells as well. However, in the autumn gers "ask" the patch they land on if it is brown or green. If the patch is brown agents query the nearby patches and move to a green patch. If there is no green patch they stay on the brown patch and deduct one resource. If a ger gets below 0 resources they die.

While we do not think that such a myopic view is realistic, the behavior modeled here approximates what a purely optimal behavior might be.

The current implementation does not include interaction among the agents; however, in future implementation the ability to learn from other gers may be included.

Stochasticity is only used with the random generation of productive patches on the landscape and with the random number generator for ger movement.

## INITIALIZATION

The patches are intialized when the model starts. The creation of these patches follows the "patch clusters" code example that comes with Netlogo (with slight modifications).

Gers are also initialized on the landscape once the patches are set (see "sliders and buttons" below).

## EXTENDING THE MODEL

In future versions of the model Gers will be able to "remember" good patches and return to them with a cost to their fitness. Gers might also be able to learn from other gers where good patches are.

Additionally, in future versions of the model there will be random bad winters whose productivity will decrease the productivity of patches. This will mimic "zuds" or bad winter storms in Mongolia. During zuds, which are unpredictable storms that usually happen on a decadal basis, normal wintering grounds are untenable and households have to find more productive areas.

## SLIDERS AND BUTTONS

Z--this relates to the productivity of the land. In this study I kept Z at a constant 2 (fairly patchy). If you wish to move this slider 1 makes the landscape all green, and 5 makes the landscape all brown (most of the time).

Seed--this is the random number seed in the model. In behavior space I chose 5 random numbers by using a random number generator, but any seed can be chosen between 1 and 1000.

N--this is the number of gers on the landscape. User can specify between 0 and 40 in increments of 10.

## OUTPUTS

Ger grouper writes a text file that has the x, y information for each ger in the final time-step. Because we aren't interested in time dependent processes the final time-step is fine for collection. The data is then fed into R code to analyze the Index of Dispersion statistic to test for clustering or regularity.
## CREDITS AND REFERENCES

Hanks, Bryan
2010	Archaeology of the Eurasian Steppes and Mongolia. Annual Review of Anthropology, 29:469-486.

Honeychurch, William and Ch. Amartuvshin
2007	Hinterlands, Urban Centers, and Mobile Settings: The “New” Old World Archaeology from the Eurasian Steppe. Asian Perspectives 46(1):36-64.

Houle, Jean-Luc
2009	Socially Integrative Facilities’ and the Emergence of Societal Complexity on the Mongolian Steppe. In Monuments, Metals and Mobility: Trajectories of Complexity in the Late Prehistory of the Eurasian Steppe, edited by Bryan K. Hanks and K. M. Linduff. Cambridge University Press.

Rogers, J. Daniel et al.
2012	Modeling scale and variability in human-environmental interactions in Inner Asia. Ecological Modelling 241:5-14.
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

ger
false
0
Rectangle -1 true false 45 105 255 225
Polygon -1 true false 45 105 120 45 180 45 255 105
Rectangle -16777216 true false 120 0 135 45
Rectangle -14835848 true false 120 150 180 225
Line -955883 false 45 105 255 105
Line -955883 false 45 135 255 135
Line -955883 false 135 150 135 225
Line -955883 false 165 150 165 225
Line -955883 false 150 150 150 225

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
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

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

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

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
<experiments>
  <experiment name="experiment" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>behaviorspace-run-number</metric>
    <metric>count lineageA</metric>
    <metric>count lineageB</metric>
    <metric>count lineageC</metric>
    <metric>count lineageD</metric>
    <enumeratedValueSet variable="patch-variability">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="N">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="seed">
      <value value="197"/>
      <value value="312"/>
      <value value="414"/>
      <value value="599"/>
      <value value="822"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-loss-from-dead-patches">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="gerreproduce">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ger-gain-from-food">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="grass-regrowth-time">
      <value value="5"/>
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
