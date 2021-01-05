# Manipulating NetLogo's vector architecture

NetLogo's vector architecture is fairly complicated and tricky to manipulate. A basic example of reading in a vector attribute is included in the main text, but this supplementary file goes farther into the details. 

Make sure `set quarries-dataset gis:load-dataset "quarries.shp"` is still in the setup procedure and run setup. Then,
in the command console on the interface tab, type:

```
gis:shape-type-of quarries-dataset
```

Console will automatically add `show` to the front of your command
and should return `"POINT"` to the console to confirm that the shapefile data is indeed of the point type. Next, let's check how these points are stored within the
`quarries-dataset`. Type in the console:

```
gis:feature-list-of quarries-dataset
```

This will return a messy looking dataset that represents several types
of data as a series of nested lists:

```
[{{gis:VectorFeature ["ID":"0.0"]["NAME":"Cero"]}} 
{{gis:VectorFeature ["ID": "1.0"]["NAME":"Uno"]}} ...]
```

These nested lists echo the way that NetLogo represents a
matrix, array, or table, but with some added colons and curly brackets.
We represent these same data in a human readable format in table 3.1.3 in the main chapter
(just the first two features are shown). 

Notice that the coordinates are not represented in the `gis:feature-list-of` report as those data are still buried within the `VectorFeature`. 
Instead of the full list, let us ask for just one point, although in
the end we will use `foreach` to loop through the following steps for
all of the points. Within the console, enter:

```
gis:find-features quarries-dataset "ID" "10.0"
```

NetLogo will then return the results of this query to the console
window prefixed with the word `observer` to indicate that this is an
output (so in the steps below don't type in the
``observer:'' part, as this is written only to indicate that you, the
coder, are using the console).

```
observer: [{{gis:VectorFeature ["ID":"10.0"]
["NAME":"Diez"]}}]
```

This returns just one `VectorFeature`, which is what we need for the
next step, namely the one where the property-name `"ID"` matches the
`property-value "10.0"`. However, notice that it is bookended by square brackets,
which means that it is not actually a `VectorFeature`, but a
NetLogo list with just one `VectorFeature` inside. We need to take our
`VectorFeature` out of that list by asking NetLogo to report the first
item of that list.

```
first gis:find-features quarries-dataset "ID" "10.0"
```

Alternatively, we could have asked for just one feature using

```
gis:find-one-feature quarries-dataset "ID" "*"
```

This returns a `VectorFeature` without a list. However, note that
this command breaks with NetLogo's usual pattern of returning a random
item from a list when asked for `one-of` something. Instead, even
though we have used the `"*"` as a wildcard to request any ID number,
it will always return the first item in the file.

Now that we have identified a single `VectorFeature`, we can ask for
its `Vertex`. Since we are still typing in console we can't use
temporary variables, so we will copy in the entry above (in parentheses
for readability):

```
gis:vertex-lists-of (first gis:find-features quarries-dataset "ID" "10.0")
observer: [[{{gis:Vertex }}]]
```

You might have thought that NetLogo would give us the coordinates of
that `Vertex`, but instead it just reports a single `Vertex` inside
of a double list. To get it out of those lists, we use:

```
first first gis:vertex-lists-of (first gis:find-features quarries-dataset "ID" "10.0")
observer: {{gis:Vertex }}
```

This is the `pxcor` and the `pycor` of the point, inside of a list. 
We can get at those two actual values with `item 0` for
the `pxcor` and `item 1` for the `pycor`. To join up with the example in the main text, we assign this to a 
temporary variable `location` and then sprout a quarry agent using each item of the location list for its coordinates.

```
let location gis:location-of (first first gis:vertex-lists-of (first gis: 
find-features quarries-dataset "ID" "10.0") )
sprout-quarry 1 [
  setxy item 0 location item 1 location
]
```
