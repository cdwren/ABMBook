extensions [palette]
breed [foragers forager]

globals [ ]
patches-own [ resources max-resources occupation-frequency ]
foragers-own [ storage ]

; # Palette testing here.
; Output from dialog picker, which is run using palette:scheme-dialog in the command window.
; "Sequential"  "YlGnBu" 5

; palette:scale-gradient rgb-color-list number range1 range2
; I think this would be used thus:
; palette:scheme-colors "Sequential"  "YlGnBu" 5

;show palette:scheme-colors "Divergent" "Spectral" 3
;=> [[252 141 89] [255 255 191] [153 213 148]]
;
;; The schemes-color primitive can be used with the scale-gradient primitive
;ask patches
;  [set pcolor palette:scale-gradient palette:scheme-colors "Divergent" "Spectral" 9 pxcor min-pxcor max-pxcor]



to setup
  ca

  ifelse hills? [make-hills][make-plain]

  create-foragers number-foragers [
    set shape "house"
    set storage 10
    set color blue
    ;setxy random max-pxcor + 1 random max-pycor + 1
    move-to one-of patches with [not any? foragers-here]
  ]
  update-display
  reset-ticks
end

to go
  ask foragers [
    gather
    eat
    move
    record-occupation
  ]

  ask patches [
    regrow-patches-slow
  ]

  ifelse viz-archrecord? [update-display-occupation][update-display]
  tick
end

to gather
  let current-gather 0
  ;type "[resources] of patch-here: " print [resources] of patch-here
  ifelse max [resources] of patch-here < gather-rate
  [
    set current-gather max [resources] of patch-here
    ;type "current-gather: "print current-gather
    let i position current-gather [resources] of patch-here
    ;type "i: " print i
    ask patch-here [ set resources replace-item i resources 0 ]
    ;type "[resources] of patch-here: " print [resources] of patch-here
  ][
    ;resources are in order of preference, but they only gather one resource type per month
    let resources-available map [x -> x >= gather-rate] resources
    ;type "resources-available: " print resources-available
    let i position true resources-available
    ;type "i: " print i
    set current-gather gather-rate
    ;type "current-gather: " print current-gather
    ask patch-here [ set resources replace-item i resources (item i resources - current-gather) ]
    ;type "[resources] of patch-here: " print [resources] of patch-here
  ]
  set storage storage + current-gather
end

to update-display
  ;let max-color max [resources] of patches * 2      ; We add * 2 to the max, so that the color is scaled from black-green instead of black-green-white
  let max-color max-plants * 2 * num-resources
  ; ask patches [ set pcolor scale-color green sum resources 0 max-color ] ; ORIGINAL CODE
  ask patches [set pcolor palette:scale-gradient palette:scheme-colors "Sequential" "YlGnBu" 5 sum resources 0 max-color]
  ; ask patches [set pcolor palette:scale-gradient palette:scheme-colors "Sequential" "OrRd" 5 sum resources 0 max-color]
  ; the number after the colorbrewer name is how many RGB values are generated for the list of RGBs

  ; test inferno here with custom palette to see if it's working... archrecord with inferno isn't convincing me it's right
;  ask patches
;  [
;    set pcolor palette:scale-gradient [[0 0 4] [186 54 85] [252 255 164]] sum resources 0 max-color
;  ]

  ask foragers [
    ifelse storage > 0
    [
      set color blue
    ][
      if color = red [die]   ; we'll allow one hungry day, but if there is a second in a row, they die.
      set color red
    ]
  ]
end

to eat
  ifelse storage >= consumption-rate [
    set storage storage - consumption-rate
  ][
    set storage 0
  ]
end

to move
  if max [resources] of patch-here < consumption-rate
  [
    let p one-of patches with [not any? foragers-here and max resources >= consumption-rate]
    if p != nobody [move-to p]
  ]
end

to regrow-patches-instant
  if min resources < max-resources [
    set resources n-values num-resources [max-resources]
  ]
end

to regrow-patches-slow
  set resources map [x -> ifelse-value (x < max-resources) [x + growth-rate] [x] ] resources
end

to make-plain
  ask patches [
    set resources n-values num-resources [max-plants]
    set max-resources max resources
  ]
end

to make-hills
  let hills (patch-set patch (max-pxcor * .33) (max-pycor * .33) patch (max-pxcor * .67) (max-pycor * .67))
  ask patches [
    let dist distance min-one-of hills [distance myself]
    set resources n-values num-resources [round (max-plants - (distance min-one-of hills [distance myself] / (max-pxcor * .75) * max-plants))]
    set max-resources max resources
  ]
end

to record-occupation
  set occupation-frequency occupation-frequency + 1
end

to update-display-occupation
  let max-color max [occupation-frequency] of patches
  ; ask patches [set pcolor scale-color red occupation-frequency 0 max-color]
  ; Note: I could use OrRd from colorbrewer here instead.
  ; TODO: Compare OrRd to custom.
  ; custom color palette test
  ;    RGB for inferno:
  ;    start: 0 0 4
  ;    middle: 186 54 85
  ;    end: 252 255 164
;  ask patches
;  [
;    set pcolor palette:scale-gradient [[0 0 4] [186 54 85] [252 255 164]] occupation-frequency 0 max-color
;  ]

; all 256 RGB
;  ask patches
;  [
;    set pcolor palette:scale-gradient [[0 4 0] [1 5 0] [1 6 1] [1 8 1] [2 10 1] [2 12 2] [2 14 2] [3 16 2] [4 18 3] [4 20 3] [5 23 4] [6 25 4] [7 27 5] [8 29 5] [9 31 6] [10 34 7] [11 36 7] [12 38 8] [13 41 8] [14 43 9] [16 45 9] [17 48 10] [18 50 10] [20 52 11] [21 55 11] [22 57 11] [24 60 12] [25 62 12] [27 65 12] [28 67 12] [30 69 12] [31 72 12] [33 74 12] [35 76 12] [36 79 12] [38 81 12] [40 83 11] [41 85 11] [43 87 11] [45 89 11] [47 91 10] [49 92 10] [50 94 10] [52 95 10] [54 97 9] [56 98 9] [57 99 9] [59 100 9] [61 101 9] [62 102 9] [64 103 10] [66 104 10] [68 104 10] [69 105 10] [71 106 11] [73 106 11] [74 107 12] [76 107 12] [77 108 13] [79 108 13] [81 108 14] [82 109 14] [84 109 15] [85 109 15] [87 110 16] [89 110 16] [90 110 17] [92 110 18] [93 110 18] [95 110 19] [97 110 19] [98 110 20] [100 110 21] [101 110 21] [103 110 22] [105 110 22] [106 110 23] [108 110 24] [109 110 24] [111 110 25] [113 110 25] [114 110 26] [116 110 26] [117 110 27] [119 109 28] [120 109 28] [122 109 29] [124 109 29] [125 109 30] [127 108 30] [128 108 31] [130 108 32] [132 107 32] [133 107 33] [135 107 33] [136 106 34] [138 106 34] [140 105 35] [141 105 35] [143 105 36] [144 104 37] [146 104 37] [147 103 38] [149 103 38] [151 102 39] [152 102 39] [154 101 40] [155 100 41] [157 100 41] [159 99 42] [160 99 42] [162 98 43] [163 97 44] [165 96 44] [166 96 45] [168 95 46] [169 94 46] [171 94 47] [173 93 48] [174 92 48] [176 91 49] [177 90 50] [179 90 50] [180 89 51] [182 88 52] [183 87 53] [185 86 53] [186 85 54] [188 84 55] [189 83 56] [191 82 57] [192 81 58] [193 80 58] [195 79 59] [196 78 60] [198 77 61] [199 76 62] [200 75 63] [202 74 64] [203 73 65] [204 72 66] [206 71 67] [207 70 68] [208 69 69] [210 68 70] [211 67 71] [212 66 72] [213 65 74] [215 63 75] [216 62 76] [217 61 77] [218 60 78] [219 59 80] [221 58 81] [222 56 82] [223 55 83] [224 54 85] [225 53 86] [226 52 87] [227 51 89] [228 49 90] [229 48 92] [230 47 93] [231 46 94] [232 45 96] [233 43 97] [234 42 99] [235 41 100] [235 40 102] [236 38 103] [237 37 105] [238 36 106] [239 35 108] [239 33 110] [240 32 111] [241 31 113] [241 29 115] [242 28 116] [243 27 118] [243 25 120] [244 24 121] [245 23 123] [245 21 125] [246 20 126] [246 19 128] [247 18 130] [247 16 132] [248 15 133] [248 14 135] [248 12 137] [249 11 139] [249 10 140] [249 9 142] [250 8 144] [250 7 146] [250 7 148] [251 6 150] [251 6 151] [251 6 153] [251 6 155] [251 7 157] [252 7 159] [252 8 161] [252 9 163] [252 10 165] [252 12 166] [252 13 168] [252 15 170] [252 17 172] [252 18 174] [252 20 176] [252 22 178] [252 24 180] [251 26 182] [251 29 184] [251 31 186] [251 33 188] [251 35 190] [250 38 192] [250 40 194] [250 42 196] [250 45 198] [249 47 199] [249 50 201] [249 53 203] [248 55 205] [248 58 207] [247 61 209] [247 64 211] [246 67 213] [246 70 215] [245 73 217] [245 76 219] [244 79 221] [244 83 223] [244 86 225] [243 90 227] [243 93 229] [242 97 230] [242 101 232] [242 105 234] [241 109 236] [241 113 237] [241 117 239] [241 121 241] [242 125 242] [242 130 244] [243 134 245] [243 138 246] [244 142 248] [245 146 249] [246 150 250] [248 154 251] [249 157 252] [250 161 253] [252 164 255]] occupation-frequency 0 max-color
;  ]

;  ask patches
;  [
;    set pcolor palette:scale-gradient [[0 0 4] [1 0 5] [1 1 6] [1 1 8] [2 1 10] [2 2 12] [2 2 14] [3 2 16] [4 3 18] [4 3 20] [5 4 23] [6 4 25] [7 5 27] [8 5 29] [9 6 31] [10 7 34] [11 7 36] [12 8 38] [13 8 41] [14 9 43] [16 9 45] [17 10 48] [18 10 50] [20 11 52] [21 11 55] [22 11 57] [24 12 60] [25 12 62] [27 12 65] [28 12 67] [30 12 69] [31 12 72] [33 12 74] [35 12 76] [36 12 79] [38 12 81] [40 11 83] [41 11 85] [43 11 87] [45 11 89] [47 10 91] [49 10 92] [50 10 94] [52 10 95] [54 9 97] [56 9 98] [57 9 99] [59 9 100] [61 9 101] [62 9 102] [64 10 103] [66 10 104] [68 10 104] [69 10 105] [71 11 106] [73 11 106] [74 12 107] [76 12 107] [77 13 108] [79 13 108] [81 14 108] [82 14 109] [84 15 109] [85 15 109] [87 16 110] [89 16 110] [90 17 110] [92 18 110] [93 18 110] [95 19 110] [97 19 110] [98 20 110] [100 21 110] [101 21 110] [103 22 110] [105 22 110] [106 23 110] [108 24 110] [109 24 110] [111 25 110] [113 25 110] [114 26 110] [116 26 110] [117 27 110] [119 28 109] [120 28 109] [122 29 109] [124 29 109] [125 30 109] [127 30 108] [128 31 108] [130 32 108] [132 32 107] [133 33 107] [135 33 107] [136 34 106] [138 34 106] [140 35 105] [141 35 105] [143 36 105] [144 37 104] [146 37 104] [147 38 103] [149 38 103] [151 39 102] [152 39 102] [154 40 101] [155 41 100] [157 41 100] [159 42 99] [160 42 99] [162 43 98] [163 44 97] [165 44 96] [166 45 96] [168 46 95] [169 46 94] [171 47 94] [173 48 93] [174 48 92] [176 49 91] [177 50 90] [179 50 90] [180 51 89] [182 52 88] [183 53 87] [185 53 86] [186 54 85] [188 55 84] [189 56 83] [191 57 82] [192 58 81] [193 58 80] [195 59 79] [196 60 78] [198 61 77] [199 62 76] [200 63 75] [202 64 74] [203 65 73] [204 66 72] [206 67 71] [207 68 70] [208 69 69] [210 70 68] [211 71 67] [212 72 66] [213 74 65] [215 75 63] [216 76 62] [217 77 61] [218 78 60] [219 80 59] [221 81 58] [222 82 56] [223 83 55] [224 85 54] [225 86 53] [226 87 52] [227 89 51] [228 90 49] [229 92 48] [230 93 47] [231 94 46] [232 96 45] [233 97 43] [234 99 42] [235 100 41] [235 102 40] [236 103 38] [237 105 37] [238 106 36] [239 108 35] [239 110 33] [240 111 32] [241 113 31] [241 115 29] [242 116 28] [243 118 27] [243 120 25] [244 121 24] [245 123 23] [245 125 21] [246 126 20] [246 128 19] [247 130 18] [247 132 16] [248 133 15] [248 135 14] [248 137 12] [249 139 11] [249 140 10] [249 142 9] [250 144 8] [250 146 7] [250 148 7] [251 150 6] [251 151 6] [251 153 6] [251 155 6] [251 157 7] [252 159 7] [252 161 8] [252 163 9] [252 165 10] [252 166 12] [252 168 13] [252 170 15] [252 172 17] [252 174 18] [252 176 20] [252 178 22] [252 180 24] [251 182 26] [251 184 29] [251 186 31] [251 188 33] [251 190 35] [250 192 38] [250 194 40] [250 196 42] [250 198 45] [249 199 47] [249 201 50] [249 203 53] [248 205 55] [248 207 58] [247 209 61] [247 211 64] [246 213 67] [246 215 70] [245 217 73] [245 219 76] [244 221 79] [244 223 83] [244 225 86] [243 227 90] [243 229 93] [242 230 97] [242 232 101] [242 234 105] [241 236 109] [241 237 113] [241 239 117] [241 241 121] [242 242 125] [242 244 130] [243 245 134] [243 246 138] [244 248 142] [245 249 146] [246 250 150] [248 251 154] [249 252 157] [250 253 161] [252 255 164]] occupation-frequency 0 max-color
;  ]

  ask patches [set pcolor palette:scale-gradient palette:scheme-colors "Sequential" "OrRd" 5 occupation-frequency 0 max-color]

  ask foragers [set hidden? true]
end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
693
494
-1
-1
27.9412
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
16
0
16
0
0
1
ticks
30.0

BUTTON
20
19
83
52
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
20
85
83
118
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

SLIDER
17
130
189
163
number-foragers
number-foragers
0
100
10.0
10
1
NIL
HORIZONTAL

SLIDER
17
165
189
198
gather-rate
gather-rate
0
10
7.0
1
1
NIL
HORIZONTAL

SLIDER
17
199
189
232
consumption-rate
consumption-rate
0
10
6.0
1
1
NIL
HORIZONTAL

BUTTON
20
52
83
85
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
17
233
189
266
growth-rate
growth-rate
0
10
1.0
1
1
NIL
HORIZONTAL

SLIDER
17
268
189
301
max-plants
max-plants
0
100
10.0
10
1
NIL
HORIZONTAL

PLOT
824
251
1024
401
plot 1
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot mean [storage] of farms"

PLOT
772
79
972
229
plot 2
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot count turtles"

BUTTON
85
510
170
543
NIL
make-hills
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
98
20
201
53
hills?
hills?
0
1
-1000

SLIDER
17
302
189
335
num-resources
num-resources
1
10
5.0
1
1
NIL
HORIZONTAL

SWITCH
17
336
158
369
viz-archrecord?
viz-archrecord?
0
1
-1000

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
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
