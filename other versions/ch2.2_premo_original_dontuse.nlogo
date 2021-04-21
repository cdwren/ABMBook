;;______________________________________________________________________________
;;This source code accompanies:
;;Premo, L.S. 2014. Cultural transmission and diversity in time-avereaged assemblages. *Current Anthropology* 55:#-#.

;;premo_CA_2014.nlogo (Version 1)

;;Programmer:
;;L.S. Premo (luke.premo@wsu.edu)

;;Department of Anthropology
;;Washington State University
;;Pullman, WA 99164-4910
;;and
;;Department of Human Evolution
;;Max Planck Institute for Evolutionary Anthropology
;;Deutscher Platz 6
;;Leipzig, Germany

;;See "Info" tab for full model description.

;;See "BehaviorSpace" for some of the experiments reported in Premo (2014).

;;This model runs on Netlogo version 5.0.2--modifications may be required to run on other versions of NetLogo.
;;______________________________________________________________________________


;;______________________
;;Variables defined
;;______________________

;;these are the global variables in the model, they can be accessed by any agent at any time
globals [
totalDiversity
totalDiversityList
totalFrequencyList
sampleDiversity1
sampleDiversityList1
sampleFrequencyList1
theta   ;;2*N*mu
F       ;;homogeneity
EF      ;;expected homogeneity
H       ;;heterogeneity (1- F)
tF
F_1%Sample
H_1%Sample
tF_1%Sample
ShannonsIndex
sampleSizeList
numberOfVariantsList
nextNovelVariant
timeSinceEquilibrium
numberTimesAtEquilibrium
numberTimesBelowEquilibrium
numberTimesAboveEquilibrium
numberTimesBelowEquilibriumtF
numberTimesAboveEquilibriumtF
numberTimesBelowEquilibriumtF_1%Sample
numberTimesAboveEquilibriumtF_1%Sample
meanF
meantF
meantF_1%Sample
maxF
minF
maxtF
mintF
maxtF_1%Sample
mintF_1%Sample

teachersPerGeneration
totalTeachers
meanTeachersPerGeneration
kbar
meanKbar
Vk
meanVk

allTimeListOfCulturalVariants
loggedList01  ;;s=0.01
loggedList05  ;;s=0.05
loggedList10  ;;s=0.1
loggedList25  ;;s=0.25
loggedList50  ;;s=0.5
loggedList75  ;;s=0.75
loggedList90  ;;s=0.9
loggedList100 ;;s=1

tF_assemblage_01  ;;s=0.01
F_assemblage_01   ;;s=0.01
tF_assemblage_05  ;;s=0.05
F_assemblage_05   ;;s=0.05
tF_assemblage_10  ;;s=0.1
F_assemblage_10   ;;s=0.1
tF_assemblage_25  ;;s=0.25
F_assemblage_25   ;;s=0.25
tF_assemblage_50  ;;s=0.5
F_assemblage_50   ;;s=0.5
tF_assemblage_75  ;;s=0.75
F_assemblage_75   ;;s=0.75
tF_assemblage_90  ;;s=0.9
F_assemblage_90   ;;s=0.9
tF_assemblage_100 ;;s=1
F_assemblage_100  ;;s=1
]



;;these are the state variables of each agent, which can be changed only be the agent that "owns" them
turtles-own [
t1                    ;;short for "trait 1", this is the only cultural trait displayed by the individual.  This is akin to a genetic model that represents multiple alleles at just one locus.
taughtThisGeneration  ;;the number of times that an individual serves as a teacher when a member of the "experienced" generation.
age                   ;;0=naive generation, cannot serve as a teacher; 1=member of the "experienced" generation, can serve as a teacher if chosen
]

;;___________________________________________________
;;___________________________________________________



;;___________
;;SETUP Procedure, this initializes the simulation
;;__________

to setup  ;;this is run when one hits the "setup" button in the interface
  clear-all      ;;clear everything from the plots and world

;;if file-exists? "sampledLoggedData.txt"   ;;when doing parameter sweeps with BehaviorSpace, comment these 2 lines out so as to collect all data in one file
;;[file-delete "sampledLoggedData.txt"]

;;if file-exists? "sampleSizeData.txt"   ;;when doing parameter sweeps with BehaviorSpace, comment these 2 lines out so as to collect all data in one file
;;[file-delete "sampleSizeData.txt"]

;;if file-exists? "exactTestData.txt"   ;;when doing parameter sweeps with BehaviorSpace, comment these 2 lines out so as to collect all data in one file
;;[file-delete "exactTestData.txt"]

;;if file-exists? "exactTestData_assemblage.txt"   ;;when doing parameter sweeps with BehaviorSpace, comment these 2 lines out so as to collect all data in one file
;;[file-delete "exactTestData_assemblage.txt"]

;;if file-exists? "numberVariantsData.txt"   ;;when doing parameter sweeps with BehaviorSpace, comment these 2 lines out so as to collect all data in one file
;;[file-delete "numberVariantsData.txt"]

random-seed seed   ;;set the random seed to the integer that appears in the "seed" slider in the interface

set nextNovelVariant 2

set timeSinceEquilibrium -1
set numberTimesAtEquilibrium -1

set numberTimesBelowEquilibrium 0
set numberTimesAboveEquilibrium 0
set numberTimesBelowEquilibriumtF 0
set numberTimesAboveEquilibriumtF 0
set numberTimesBelowEquilibriumtF_1%Sample 0
set numberTimesAboveEquilibriumtF_1%Sample 0

set maxF 0
set minF 1
set maxtF 0
set mintF 1000
set maxtF_1%Sample 0
set mintF_1%Sample 1000


set totalTeachers 0
set meanTeachersPerGeneration 0
set kbar 0
set meanKbar 0
set Vk 0
set meanVk 0

set allTimeListOfCulturalVariants (list)  ;;this results in any empty list that will eventually contain all of the cultural variants deposited during *d*

set theta (2 * N * mu)  ;;calculate the analytically derived expectation, theta; note that N = Ne under neutral conditions like those modelled here
set EF (1 / ((2 * N * mu) + 1))  ;;calculate the expected value of F (EF) for cultural diversity under neutral conditions

;;create the starting population of social learners
let numberNeeded N
while [numberNeeded > 0]
[
ask one-of patches   ;;seed patches randomly with individuals, this is a non-spatial model
  [
  sprout 1
  [   ;;set the state variable values for each newly created individual
   set t1 nextNovelVariant  ;;every individual gets a unique value for its cultural variant
   set nextNovelVariant nextNovelVariant + 1  ;;increment this so the next variant will be novel
   set color t1      ;;color reflects t1 value
   set taughtThisGeneration 0
   set age 0
   ]
  ]
set numberNeeded numberNeeded - 1
]

reset-ticks  ;;reset time steps to 0

printHeaders  ;;print the header information to the series of textfiles that collect data and results from each simulation
end  ;;end of "setup"

;;___________________________________________________
;;___________________________________________________




;;_______________
;;GO Procedure
;;_______________
;;"go" is the step function. It provides the schedule for what the observer does over the course of each time step.
;;go is executed recursively until the simulation is stopped.

to go

;;reset these variables to 0 at the start of each step, they are used as an independent check on unbiased transmission.
set kbar 0
set Vk 0

;;increment the # of time steps by one each time go is called
tick

;;if an earlier population already hit drift-copying error equilibrium
if timeSinceEquilibrium >= 0
 [
 set timeSinceEquilibrium timeSinceEquilibrium + 1  ;;then, increment the number of time steps since equilibrium by 1
 ]

;;"age" individuals from the previous time step so that they serve as the experienced generation in the current time step
ask turtles
 [
 set age 1  ;;every one alive at the beginning of the time step ages, they will serve as the potential teachers during this time step
 set taughtThisGeneration 0  ;;set this to 0 to reflect the fact that no one has served as a teacher at the beginnning of the time step.  It should be impossible for any of them to have anything other than a 0 anyways.
 ]


;;create the "naive" generation of individuals
let numberNeeded N
while [numberNeeded > 0]
[
ask one-of patches  ;;seed patches randomly with individuals, it doesn't really matter where they go, because this model is not spatial
  [
  sprout 1 [set age 0]  ;;set the new individual's age to 0
  ]
set numberNeeded numberNeeded - 1
]


;;cultural transmission
ask turtles with [age = 0]  ;;Ask naive generation of social learners...
 [
 learn  ;;...to learn from someone from the "experienced" generation (this includes making a copying error with probability = mu)
 ]


;;After cultural transmission, collect some data on the number of teachers.  These values are used as an independent check that cultural transmission is actually unbiased.
collectCTData


;;Cull the "experienced" generation from the simulation.  This maintains a constant population size.  Note that this must come BEFORE we calculate diversity and allow individuals to drop cultural variants.
ask turtles with [age = 1]
 [
 die
 ]


;;create list of unique variants and calculate F (homogeneity) for the total population, this must be done BEFORE checking for equilibrium in the population.
calculateDiversityFromTotalPopulation


;;check to see if cultural diversity is at equilibrium using F calculated above
checkForEquilibrium


;;Collect data and allow individuals to deposit cultural variants for d time steps after the first time that a population reaches equilibrium
if timeSinceEquilibrium > 0
 [
 durationOfAssemblageFormation
 ]


 ;;update plots on the interface
updatePlots  ;;None of these plots is absolutely necessary, they just provide an idea of what is going on in the populations in the model.  See textfiles for data used in the analysis.


;;finally, check for stop condition
if timeSinceEquilibrium = d  ;; the simulation ends d time steps after the first time a population reaches equilibrium
 [
 ;;before stopping, collect data from the assemblage
 collectSamplesFromAssemblage   ;;collect data used to calculate tF, tE, Slatkin's Exact test, and the variants frequency approach on samples of varying size from the assemblage
 ;;before stopping, collect some additional data from the population
 printExactTestOutput           ;;collect data used to calculate tE, Slatkin's Exact test, and the variants frequency approach on the population
 stop
 ]

end   ;;end of "go"


;;_____________________________________
;;All other procedures
;;_____________________________________
;;Listed alphabetically as follows:

;;calculateDiversityFrom1%SampleOfPopulation
;;calculateDiversityFromTotalPopulation
;;calculateFHtF
;;calculateShannonsIndex
;;calculatetFFrom1%SampleOfPopulation
;;checkForEquilibrium
;;collectCTData
;;collectEquilibriumPopulationData
;;collectSamplesFromAssemblage
;;durationOfAssemblageFormation
;;learn
;;printExactTestOutput
;;printHeaders
;;updatePlots

;;___________________________________________________
;;___________________________________________________

to calculateDiversityFrom1%SampleOfPopulation   ;;observer method, called within "collectEquilibriumPopulationData"
;;this gets called only if N >= 50

set sampleDiversityList1 (list)
;;show totalDiversityList1  ;;for testing
set sampleFrequencyList1 (list)

ask n-of round(count turtles * 0.01) turtles
 [
 let myVariant (list t1)
 ifelse member? myVariant sampleDiversityList1 = false
  [
  set sampleDiversityList1 lput myVariant sampleDiversityList1
  ;;show sampleDiversityList1  ;;for testing
  set sampleFrequencyList1 lput 1 sampleFrequencyList1
  ]
  [
  let oldFrequency item (position myVariant sampleDiversityList1) sampleFrequencyList1
  ;;show oldFrequency  ;;for testing
  ;;show sampleFrequencyList1  ;;for testing
  set sampleFrequencyList1 replace-item (position myVariant sampleDiversityList1) sampleFrequencyList1 (oldFrequency + 1)
  ;;show sampleFrequencyList1  ;;for testing
  ]
 ]

 set sampleFrequencyList1 sort-by [ [?1 ?2] -> ?1 > ?2 ] sampleFrequencyList1  ;;sort in descending order

set sampleDiversity1 length sampleDiversityList1
;;show length sampleDiversityList1  ;;for testing
end  ;;ends calculateDiversityFrom1%Sample

;;___________________________________________________
;;___________________________________________________



to calculateDiversityFromTotalPopulation   ;;observer method, called within "go"
;;this produces 2 lists from the population.
;;totalDiversityList is a list of all of the unique cultural variants displayed by the population.
;;totalFrequencyList is a list that provides the number of times that each of the items on the totalDiversityList occurs in the population.


set totalDiversityList (list)
;;show totalDiversityList   ;;for testing
set totalFrequencyList (list)

ask turtles
 [
 let myVariant (list t1)
 ifelse member? myVariant totalDiversityList = false
  [
  set totalDiversityList lput myVariant totalDiversityList
  ;;show totalDiversityList   ;;for testing
  set totalFrequencyList lput 1 totalFrequencyList
  ]
  [
  let oldFrequency item (position myVariant totalDiversityList) totalFrequencyList
  ;;show oldFrequency  ;;for testing
  ;;show totalFrequencyList  ;;for testing
  set totalFrequencyList replace-item (position myVariant totalDiversityList) totalFrequencyList (oldFrequency + 1)
  ;;show totalFrequencyList  ;;for testing
  ]
 ]

set totalDiversity length totalDiversityList
;;show length totalDiversityList  ;;for testing

calculateFHtF  ;;calculate F (homogeneity), H, and tF for the entire population

end  ;;ends calculateDiversityFromTotalPopulation

;;___________________________________________________
;;___________________________________________________




to calculateFHtF  ;;calculate F, H, and tF for the entire population. observer method, called every time step by calculateDiversityFromTotalPopulation
let sumOfSquares 0

foreach totalFrequencyList
 [ ?1 ->
 set sumOfSquares sumOfSquares + ((?1 / count turtles) ^ 2)
 ]

set F sumOfSquares
;;write "F:"   ;;for testing
;;print F  ;;for testing

set H (1 - sumOfSquares)
;;write "H:"   ;;for testing
;;print H  ;;for testing

set tF ((1 / sumOfSquares) - 1)
;;write "tF:"   ;;for testing
;;print tF  ;;for testing
end ;;ends calculateFHtF

;;___________________________________________________
;;___________________________________________________



to calculateShannonsIndex  ;;observer method, called within "collectEquilibriumPopulationData"
;;calculate shannon's index for the entire population

let summation 0

foreach totalFrequencyList
 [ ?1 ->
 set summation (summation + ((?1 / count turtles) * (ln (?1 / count turtles))))
 ]

set ShannonsIndex (-1 * summation)
;;write "Shannon's Index:"   ;;for testing
;;print ShannonsIndex  ;;for testing
end  ;;ends calculateShannonsIndex

;;___________________________________________________
;;___________________________________________________



to calculatetFFrom1%SampleOfPopulation  ;;calculate H and tF from a sample of 1% of the turtles.  observer method called within "collectEquilibriumPopulationData" every time step when timeSinceEquilibrium >= 0
;;this gets called only if N >= 50

let sumOfSquares 0

foreach sampleFrequencyList1
 [ ?1 ->
 set sumOfSquares sumOfSquares + ((?1 / round(count turtles * 0.01)) ^ 2)
 ]

set F_1%Sample sumOfSquares
;;write "F_1%Sample:"   ;;for testing
;;print F_1%Sample  ;;for testing

set H_1%Sample (1 - sumOfSquares)
;;write "H_1%Sample:"   ;;for testing
;;print H_1%Sample  ;;for testing

set tF_1%Sample ((1 / sumOfSquares) - 1)
;;write "tF_1%Sample:"  ;;for testing
;;print tF_1%Sample
end   ;;ends calculatetFFrom1%Sample

;;___________________________________________________
;;___________________________________________________



to checkForEquilibrium  ;;Check to see if cultural diversity is at equilibrium in the population. This is an observer method, called within "go".
if (F <= ( EF + 0.005)) and (F >= ( EF - 0.005)) ;;if the observed F (homogeneity) is within +-0.005 of the expected value, then this population is considered to be at equilibrium
  [
  ifelse numberTimesAtEquilibrium = -1  ;;if this is the first time at equilibrium
   [
   set numberTimesAtEquilibrium 0  ;;then change the -1 to 0
   set timeSinceEquilibrium 0  ;;and change timeSinceEquilibrium from -1 to 0
   ]
   [
   set numberTimesAtEquilibrium (numberTimesAtEquilibrium + 1)  ;;else just increment the numberOfTimesAtEquilibrium
   ]
  ]
end  ;;ends checkForEquilibrium

;;___________________________________________________
;;___________________________________________________



to collectCTData   ;;observer method, called within "go"
;;The variables set here can be used in an independent check that cultural transmission is actually unbiased.
 set teachersPerGeneration (count turtles with [taughtThisGeneration > 0])

 set kbar mean [taughtThisGeneration] of turtles with [age = 1]  ;;mean taughtThisGeneration, this should approximate 1 with unbiased cultural transmission

 set Vk variance [taughtThisGeneration] of turtles with [age = 1] ;;variance in taughtThisGeneration, this should approximate 1 with unbiased cultural transmission

 set totalTeachers totalTeachers + teachersPerGeneration

 set meanTeachersPerGeneration (totalTeachers / ticks)
end  ;;ends collectCTData

;;___________________________________________________
;;___________________________________________________



to collectEquilibriumPopulationData     ;;observer method, called within "go"

 set totalFrequencyList sort-by [ [?1 ?2] -> ?1 > ?2 ] totalFrequencyList  ;;sort in descending order, to collect data for exact test from entire population

 if N >= 50  ;;the population must have at least 50 individuals or else round(N * 0.01) equals 0 and this will cause a runtime error (cannot divide by zero).
 [
 calculateDiversityFrom1%SampleOfPopulation  ;;collect data for exact test from a sample size that is 1% of the population size, N must be at least 50

 calculatetFFrom1%SampleOfPopulation  ;;calculate H and tF from the relative frequencies collected in a 1% sample of the population, N must be at least 50
 ]

 calculateShannonsIndex
  ;;show totalFrequencyList  ;;for testing

;;then, print these measures and others calculated above to an output file
file-open "numberVariantsData.txt"
file-write ticks file-write count turtles file-write totalDiversity file-write F file-write tF file-write F_1%Sample file-write tF_1%Sample file-write EF file-write theta file-write minF file-write meanF file-write maxF file-write mintF file-write meantF file-write maxtF file-write mintF_1%Sample file-write meantF_1%Sample file-write maxtF_1%Sample file-write numberTimesAtEquilibrium file-write numberTimesBelowEquilibrium file-write numberTimesAboveEquilibrium file-write numberTimesBelowEquilibriumtF file-write numberTimesAboveEquilibriumtF file-write numberTimesBelowEquilibriumtF_1%Sample file-write numberTimesAboveEquilibriumtF_1%Sample file-write meanTeachersPerGeneration file-write meanKbar file-write meanVk file-print " "
file-close

end   ;;ends collectEquilibriumPopulationData

;;___________________________________________________
;;___________________________________________________




to collectSamplesFromAssemblage  ;;observer method, called within "go" only at the very end of the simulation run
;;this procedure does 3 things
;;1. collects the data needed to conduct Slatkin's Exact test, Ewens-Watterson homozygosity test, and estimate t_E on samples collected from the *assemblage* (not the population)
;;2. calculates tF for samples of various size collected from the *assemblage* (not the population)
;;3. collects the logged frequency distribitions for samples of various size collected from the *assemblage* (not the population). These data are needed to apply the variants frequency approach.

let tempList (list)
let tempVariantsList (list)
let tempFreqList (list)
let tempVariant 0
let oldFrequency 0
let totalNumberVariants 0

set loggedList01 (list)
set loggedList05 (list)
set loggedList10 (list)
set loggedList25 (list)
set loggedList50 (list)
set loggedList75 (list)
set loggedList90 (list)
set loggedList100 (list)

;;show length allTimeListOfCulturalVariants  ;;for testing

;;sample size = 1% of total assemblage
set tempList n-of round((length allTimeListOfCulturalVariants) * 0.01) allTimeListOfCulturalVariants

;;show length tempList  ;;for testing

;create tempVariantsList and tempFreqList
while [length(tempList) > 0]
[
set tempVariant first tempList

ifelse member? tempVariant tempVariantsList = false
  [  ;;this variant is not already on the list
  set tempVariantsList lput tempVariant tempVariantsList  ;;place it at the end
  set tempFreqList lput 1 tempFreqList  ;;place a 1 at the end of the tempFreqList
  ]
  [  ;;else, this variant is already on the list, so just increment the count at the correct position in tempFreqList
  set oldFrequency item (position tempVariant tempVariantsList) tempFreqList
  set tempFreqList replace-item (position tempVariant tempVariantsList) tempFreqList (oldFrequency + 1)
  ]

set tempList remove-item 0 tempList
]

 set tempFreqList sort-by [ [?1 ?2] -> ?1 > ?2 ] tempFreqList  ;;sort in descending order...this doesn't matter for the log-log stuff
 ;;show tempFreqList ;;for testing
 set totalNumberVariants length(tempFreqList)
 ;;show totalNumberVariants ;;for testing

 ;;;;;;;;;;;;;;;;;;;;;;;;;;  ;;extract the data needed to run the exact test, the homozygosity test, and calculate tE on a 1% sample of the *assemblage* not the population of social learners
   file-open "exactTestData_assemblage.txt"
   file-print ticks
   file-print "s=0.01"
   foreach tempFreqList [ ?1 -> file-write ?1 file-write "," ] file-print " "

   let variantsNeededforETD 1
   while [variantsNeededforETD <= length (tempFreqList)]
   [
   file-write variantsNeededforETD
   set variantsNeededforETD (variantsNeededforETD + 1)
   ]
   file-print" "
   file-close
 ;;;;;;;;;;;;;;;;;;;;;;;;;;


 set loggedList01 lput ((occurrences 1 tempFreqList) / totalNumberVariants) loggedList01
 set loggedList01 lput ((occurrences 2 tempFreqList) / totalNumberVariants) loggedList01

 let i 3
 let k 1
 let l floor(log max(tempFreqList) 2)

 while [l > 0]
 [
 set k (k * 2)
 let j k
 let sumPos 0
   while [j > 0]
   [
   set sumPos sumPos + ((occurrences i tempFreqList) / totalNumberVariants)
   set i i + 1
   set j j - 1
   ]
 set loggedList01 lput (sumPos / k) loggedList01
 set l l - 1
 ]

;;print out sampled data
   file-open "sampledLoggedData.txt"
   file-print ticks
   file-print " "
   file-print "1% sample"
   foreach loggedList01 [ ?1 -> file-write ?1 ] file-print " "

   let variantsNeeded length(loggedList01)
   let variant 1

   while [variantsNeeded > 0]
   [
   file-write variant
   set variant (variant * 2)
   set variantsNeeded variantsNeeded - 1
   ]
   file-print" "

   ;;
   set variantsNeeded length(loggedList01)

   file-write 0.5
   set variantsNeeded variantsNeeded - 1

   let topBin 2
   let bottomBin 1

   while [variantsNeeded > 0]
   [
   file-write bottomBin + ((topBin - bottomBin) / 2)

   set bottomBin topBin  ;;do this first
   set topBin (topBin * 2) ;;do this second
   set variantsNeeded variantsNeeded - 1
   ]

   file-print" "
   file-close


;;now use tempFreqList to calculate tF from assemblage data rather than from a population of individuals
let sumOfSquares 0

foreach tempFreqList
 [ ?1 ->
 set sumOfSquares sumOfSquares + ((?1 / (sum tempFreqList)) ^ 2)
 ]

set F_assemblage_01 sumOfSquares
;;write "F_assemblage_01:"   ;;for testing
;;print F_assemblage_01  ;;for testing

set tF_assemblage_01 ((1 / sumOfSquares) - 1)
;;write "tF_assemblage_01:"   ;;for testing
;;print tF_assemblage_01  ;;for testing

file-open "sampledLoggedData.txt"
file-print "theta"
file-print theta
file-print "tF_assemblage_01"
file-print tF_assemblage_01
file-print "EF"
file-print EF
file-print "F_assemblage_01"
file-print F_assemblage_01
file-print" "
file-print" "
file-close



;;reset lists
set tempList (list)
set tempVariantsList (list)
set tempFreqList (list)

;;start over with a sample of 5%
set tempList n-of round((length allTimeListOfCulturalVariants) * 0.05) allTimeListOfCulturalVariants

;create tempVariantsList and tempFreqList
while [length(tempList) > 0]
[
set tempVariant first tempList

ifelse member? tempVariant tempVariantsList = false
  [  ;;this variant is not already on the list
  set tempVariantsList lput tempVariant tempVariantsList  ;;place it at the end
  set tempFreqList lput 1 tempFreqList  ;;place a 1 at the end of the tempFreqList
  ]
  [  ;;else, this variant is already on the list, so just increment the count at the correct position in tempFreqList
  set oldFrequency item (position tempVariant tempVariantsList) tempFreqList
  set tempFreqList replace-item (position tempVariant tempVariantsList) tempFreqList (oldFrequency + 1)
  ]

set tempList remove-item 0 tempList
]

 set tempFreqList sort-by [ [?1 ?2] -> ?1 > ?2 ] tempFreqList  ;;sort in descending order...this doesn't matter for the log-log stuff
 ;;show tempFreqList ;;for testing
 set totalNumberVariants length(tempFreqList)
 ;;show totalNumberVariants ;;for testing

 ;;;;;;;;;;;;;;;;;;;;;;;;;;  ;;extract the data needed to run the exact test, the homozygosity test, and calculate tE on a 5% sample of the *assemblage* not the population of social learners
   file-open "exactTestData_assemblage.txt"
   file-print ticks
   file-print "s=0.05"
   foreach tempFreqList [ ?1 -> file-write ?1 file-write "," ] file-print " "

   set variantsNeededforETD 1
   while [variantsNeededforETD <= length (tempFreqList)]
   [
   file-write variantsNeededforETD
   set variantsNeededforETD (variantsNeededforETD + 1)
   ]
   file-print" "
   file-close
 ;;;;;;;;;;;;;;;;;;;;;;;;;;



 set loggedList05 lput ((occurrences 1 tempFreqList) / totalNumberVariants) loggedList05
 set loggedList05 lput ((occurrences 2 tempFreqList) / totalNumberVariants) loggedList05

 set i 3
 set k 1
 set l floor(log max(tempFreqList) 2)

 while [l > 0]
 [
 set k (k * 2)
 let j k
 let sumPos 0
   while [j > 0]
   [
   set sumPos sumPos + ((occurrences i tempFreqList) / totalNumberVariants)
   set i i + 1
   set j j - 1
   ]
 set loggedList05 lput (sumPos / k) loggedList05
 set l l - 1
 ]

;;print out sampled data
   file-open "sampledLoggedData.txt"
   file-print "5% sample"
   foreach loggedList05 [ ?1 -> file-write ?1 ] file-print " "

   set variantsNeeded length(loggedList05)
   set variant 1

   while [variantsNeeded > 0]
   [
   file-write variant
   set variant (variant * 2)
   set variantsNeeded variantsNeeded - 1
   ]
   file-print" "


   ;;
   set variantsNeeded length(loggedList05)

   file-write 0.5
   set variantsNeeded variantsNeeded - 1

   set topBin 2
   set bottomBin 1

   while [variantsNeeded > 0]
   [
   file-write bottomBin + ((topBin - bottomBin) / 2)

   set bottomBin topBin  ;;do this first
   set topBin (topBin * 2) ;;do this second
   set variantsNeeded variantsNeeded - 1
   ]

   file-print" "
   file-close



;;now use tempFreqList to calculate tF
set sumOfSquares 0

foreach tempFreqList
 [ ?1 ->
 set sumOfSquares sumOfSquares + ((?1 / (sum tempFreqList)) ^ 2)
 ]

set F_assemblage_05 sumOfSquares
;;write "F_assemblage_05:"   ;;for testing
;;print F_assemblage_05  ;;for testing

set tF_assemblage_05 ((1 / sumOfSquares) - 1)
;;write "tF_assemblage_05:"   ;;for testing
;;print tF_assemblage_05  ;;for testing

file-open "sampledLoggedData.txt"
file-print "theta"
file-print theta
file-print "tF_assemblage_05"
file-print tF_assemblage_05
file-print "EF"
file-print EF
file-print "F_assemblage_05"
file-print F_assemblage_05
file-print" "
file-print" "
file-close


;;reset lists
set tempList (list)
set tempVariantsList (list)
set tempFreqList (list)

;;start over with a sample size of 10%
set tempList n-of round((length allTimeListOfCulturalVariants) * 0.1) allTimeListOfCulturalVariants

;create tempVariantsList and tempFreqList
while [length(tempList) > 0]
[
set tempVariant first tempList

ifelse member? tempVariant tempVariantsList = false
  [  ;;this variant is not already on the list
  set tempVariantsList lput tempVariant tempVariantsList  ;;place it at the end
  set tempFreqList lput 1 tempFreqList  ;;place a 1 at the end of the tempFreqList
  ]
  [  ;;else, this variant is already on the list, so just increment the count at the correct position in tempFreqList
  set oldFrequency item (position tempVariant tempVariantsList) tempFreqList
  set tempFreqList replace-item (position tempVariant tempVariantsList) tempFreqList (oldFrequency + 1)
  ]

set tempList remove-item 0 tempList
]

 set tempFreqList sort-by [ [?1 ?2] -> ?1 > ?2 ] tempFreqList  ;;sort in descending order...this doesn't matter for the log-log stuff
 ;;show tempFreqList ;;for testing
 set totalNumberVariants length(tempFreqList)
 ;;show totalNumberVariants ;;for testing

 ;;;;;;;;;;;;;;;;;;;;;;;;;;  ;;extract the data needed to run the exact test, the homozygosity test, and calculate tE on a 10% sample of the *assemblage* not the population of social learners
   file-open "exactTestData_assemblage.txt"
   file-print ticks
   file-print "s=0.1"
   foreach tempFreqList [ ?1 -> file-write ?1 file-write "," ] file-print " "

   set variantsNeededforETD 1
   while [variantsNeededforETD <= length (tempFreqList)]
   [
   file-write variantsNeededforETD
   set variantsNeededforETD (variantsNeededforETD + 1)
   ]
   file-print" "
   file-close
 ;;;;;;;;;;;;;;;;;;;;;;;;;;



 set loggedList10 lput ((occurrences 1 tempFreqList) / totalNumberVariants) loggedList10
 set loggedList10 lput ((occurrences 2 tempFreqList) / totalNumberVariants) loggedList10

 set i 3
 set k 1
 set l floor(log max(tempFreqList) 2)

 while [l > 0]
 [
 set k (k * 2)
 let j k
 let sumPos 0
   while [j > 0]
   [
   set sumPos sumPos + ((occurrences i tempFreqList) / totalNumberVariants)
   set i i + 1
   set j j - 1
   ]
 set loggedList10 lput (sumPos / k) loggedList10
 set l l - 1
 ]

;;print out sampled data
   file-open "sampledLoggedData.txt"
   file-print "10% sample"
   foreach loggedList10 [ ?1 -> file-write ?1 ] file-print " "

   set variantsNeeded length(loggedList10)
   set variant 1

   while [variantsNeeded > 0]
   [
   file-write variant
   set variant (variant * 2)
   set variantsNeeded variantsNeeded - 1
   ]
   file-print" "


   ;;
   set variantsNeeded length(loggedList10)

   file-write 0.5
   set variantsNeeded variantsNeeded - 1

   set topBin 2
   set bottomBin 1

   while [variantsNeeded > 0]
   [
   file-write bottomBin + ((topBin - bottomBin) / 2)

   set bottomBin topBin  ;;do this first
   set topBin (topBin * 2) ;;do this second
   set variantsNeeded variantsNeeded - 1
   ]

   file-print" "
   file-close

;;now use tempFreqList to calculate tF
set sumOfSquares 0

foreach tempFreqList
 [ ?1 ->
 set sumOfSquares sumOfSquares + ((?1 / (sum tempFreqList)) ^ 2)
 ]

set F_assemblage_10 sumOfSquares
;;write "F_assemblage_10:"   ;;for testing
;;print F_assemblage_10 ;;for testing

set tF_assemblage_10 ((1 / sumOfSquares) - 1)
;;write "tF_assemblage_10:"   ;;for testing
;;print tF_assemblage_10  ;;for testing


file-open "sampledLoggedData.txt"
file-print "theta"
file-print theta
file-print "tF_assemblage_10"
file-print tF_assemblage_10
file-print "EF"
file-print EF
file-print "F_assemblage_10"
file-print F_assemblage_10
file-print" "
file-print" "
file-close



;;reset lists
set tempList (list)
set tempVariantsList (list)
set tempFreqList (list)

;;now start over with a sample size of 25%
set tempList n-of round((length allTimeListOfCulturalVariants) * 0.25) allTimeListOfCulturalVariants

;create tempVariantsList and tempFreqList
while [length(tempList) > 0]
[
set tempVariant first tempList

ifelse member? tempVariant tempVariantsList = false
  [  ;;this variant is not already on the list
  set tempVariantsList lput tempVariant tempVariantsList  ;;place it at the end
  set tempFreqList lput 1 tempFreqList  ;;place a 1 at the end of the tempFreqList
  ]
  [  ;;else, this variant is already on the list, so just increment the count at the correct position in tempFreqList
  set oldFrequency item (position tempVariant tempVariantsList) tempFreqList
  set tempFreqList replace-item (position tempVariant tempVariantsList) tempFreqList (oldFrequency + 1)
  ]

set tempList remove-item 0 tempList
]

 set tempFreqList sort-by [ [?1 ?2] -> ?1 > ?2 ] tempFreqList  ;;sort in descending order...this doesn't matter for the log-log stuff
 ;;show tempFreqList ;;for testing
 set totalNumberVariants length(tempFreqList)
 ;;show totalNumberVariants ;;for testing
 set loggedList25 lput ((occurrences 1 tempFreqList) / totalNumberVariants) loggedList25
 set loggedList25 lput ((occurrences 2 tempFreqList) / totalNumberVariants) loggedList25

 set i 3
 set k 1
 set l floor(log max(tempFreqList) 2)

 while [l > 0]
 [
 set k (k * 2)
 let j k
 let sumPos 0
   while [j > 0]
   [
   set sumPos sumPos + ((occurrences i tempFreqList) / totalNumberVariants)
   set i i + 1
   set j j - 1
   ]
 set loggedList25 lput (sumPos / k) loggedList25
 set l l - 1
 ]

;;print out sampled data
   file-open "sampledLoggedData.txt"
   file-print "25% sample"
   foreach loggedList25 [ ?1 -> file-write ?1 ] file-print " "

   set variantsNeeded length(loggedList25)
   set variant 1

   while [variantsNeeded > 0]
   [
   file-write variant
   set variant (variant * 2)
   set variantsNeeded variantsNeeded - 1
   ]
   file-print" "


   ;;
   set variantsNeeded length(loggedList25)

   file-write 0.5
   set variantsNeeded variantsNeeded - 1

   set topBin 2
   set bottomBin 1

   while [variantsNeeded > 0]
   [
   file-write bottomBin + ((topBin - bottomBin) / 2)

   set bottomBin topBin  ;;do this first
   set topBin (topBin * 2) ;;do this second
   set variantsNeeded variantsNeeded - 1
   ]

   file-print" "
   file-close

;;now use tempFreqList to calculate tF
set sumOfSquares 0

foreach tempFreqList
 [ ?1 ->
 set sumOfSquares sumOfSquares + ((?1 / (sum tempFreqList)) ^ 2)
 ]

set F_assemblage_25 sumOfSquares
;;write "F_assemblage_25:"   ;;for testing
;;print F_assemblage_25  ;;for testing

set tF_assemblage_25 ((1 / sumOfSquares) - 1)
;;write "tF_assemblage_25:"   ;;for testing
;;print tF_assemblage_25  ;;for testing

file-open "sampledLoggedData.txt"
file-print "theta"
file-print theta
file-print "tF_assemblage_25"
file-print tF_assemblage_25
file-print "EF"
file-print EF
file-print "F_assemblage_25"
file-print F_assemblage_25
file-print" "
file-print" "
file-close



;;reset lists
set tempList (list)
set tempVariantsList (list)
set tempFreqList (list)

;;now start over with a sample of 50%
set tempList n-of round((length allTimeListOfCulturalVariants) * 0.5) allTimeListOfCulturalVariants

;create tempVariantsList and tempFreqList
while [length(tempList) > 0]
[
set tempVariant first tempList

ifelse member? tempVariant tempVariantsList = false
  [  ;;this variant is not already on the list
  set tempVariantsList lput tempVariant tempVariantsList  ;;place it at the end
  set tempFreqList lput 1 tempFreqList  ;;place a 1 at the end of the tempFreqList
  ]
  [  ;;else, this variant is already on the list, so just increment the count at the correct position in tempFreqList
  set oldFrequency item (position tempVariant tempVariantsList) tempFreqList
  set tempFreqList replace-item (position tempVariant tempVariantsList) tempFreqList (oldFrequency + 1)
  ]

set tempList remove-item 0 tempList
]

 set tempFreqList sort-by [ [?1 ?2] -> ?1 > ?2 ] tempFreqList  ;;sort in descending order...this doesn't matter for the log-log stuff
 ;;show tempFreqList ;;for testing
 set totalNumberVariants length(tempFreqList)
 ;;show totalNumberVariants ;;for testing

 ;;;;;;;;;;;;;;;;;;;;;;;;;;  ;;extract the data needed to run the exact test, the homozygosity test, and calculate tE on a 50% sample of the *assemblage* not the population of social learners
   file-open "exactTestData_assemblage.txt"
   file-print ticks
   file-print "s=0.5"
   foreach tempFreqList [ ?1 -> file-write ?1 file-write "," ] file-print " "

   set variantsNeededforETD 1
   while [variantsNeededforETD <= length (tempFreqList)]
   [
   file-write variantsNeededforETD
   set variantsNeededforETD (variantsNeededforETD + 1)
   ]
   file-print" "
   file-close
 ;;;;;;;;;;;;;;;;;;;;;;;;;;

 set loggedList50 lput ((occurrences 1 tempFreqList) / totalNumberVariants) loggedList50
 set loggedList50 lput ((occurrences 2 tempFreqList) / totalNumberVariants) loggedList50

 set i 3
 set k 1
 set l floor(log max(tempFreqList) 2)

 while [l > 0]
 [
 set k (k * 2)
 let j k
 let sumPos 0
   while [j > 0]
   [
   set sumPos sumPos + ((occurrences i tempFreqList) / totalNumberVariants)
   set i i + 1
   set j j - 1
   ]
 set loggedList50 lput (sumPos / k) loggedList50
 set l l - 1
 ]

;;print out sampled data
   file-open "sampledLoggedData.txt"
   file-print "50% sample"
   foreach loggedList50 [ ?1 -> file-write ?1 ] file-print " "

   set variantsNeeded length(loggedList50)
   set variant 1

   while [variantsNeeded > 0]
   [
   file-write variant
   set variant (variant * 2)
   set variantsNeeded variantsNeeded - 1
   ]
   file-print" "


   ;;
   set variantsNeeded length(loggedList50)

   file-write 0.5
   set variantsNeeded variantsNeeded - 1

   set topBin 2
   set bottomBin 1

   while [variantsNeeded > 0]
   [
   file-write bottomBin + ((topBin - bottomBin) / 2)

   set bottomBin topBin  ;;do this first
   set topBin (topBin * 2) ;;do this second
   set variantsNeeded variantsNeeded - 1
   ]

   file-print" "
   file-close

;;now use tempFreqList to calculate tF
set sumOfSquares 0

foreach tempFreqList
 [ ?1 ->
 set sumOfSquares sumOfSquares + ((?1 / (sum tempFreqList)) ^ 2)
 ]

set F_assemblage_50 sumOfSquares
;;write "F_assemblage_50:"   ;;for testing
;;print F_assemblage_50  ;;for testing

set tF_assemblage_50 ((1 / sumOfSquares) - 1)
;;write "tF_assemblage_50:"   ;;for testing
;;print tF_assemblage_50  ;;for testing

file-open "sampledLoggedData.txt"
file-print "theta"
file-print theta
file-print "tF_assemblage_50"
file-print tF_assemblage_50
file-print "EF"
file-print EF
file-print "F_assemblage_50"
file-print F_assemblage_50
file-print" "
file-print" "
file-close



;;reset lists
set tempList (list)
set tempVariantsList (list)
set tempFreqList (list)


;;now start over with a sample of 75%
set tempList n-of round((length allTimeListOfCulturalVariants) * 0.75) allTimeListOfCulturalVariants

;create tempVariantsList and tempFreqList
while [length(tempList) > 0]
[
set tempVariant first tempList

ifelse member? tempVariant tempVariantsList = false
  [  ;;this variant is not already on the list
  set tempVariantsList lput tempVariant tempVariantsList  ;;place it at the end
  set tempFreqList lput 1 tempFreqList  ;;place a 1 at the end of the tempFreqList
  ]
  [  ;;else, this variant is already on the list, so just increment the count at the correct position in tempFreqList
  set oldFrequency item (position tempVariant tempVariantsList) tempFreqList
  set tempFreqList replace-item (position tempVariant tempVariantsList) tempFreqList (oldFrequency + 1)
  ]

set tempList remove-item 0 tempList
]

 set tempFreqList sort-by [ [?1 ?2] -> ?1 > ?2 ] tempFreqList  ;;sort in descending order...this doesn't matter for the log-log stuff
 ;;show tempFreqList ;;for testing
 set totalNumberVariants length(tempFreqList)
 ;;show totalNumberVariants ;;for testing
 set loggedList75 lput ((occurrences 1 tempFreqList) / totalNumberVariants) loggedList75
 set loggedList75 lput ((occurrences 2 tempFreqList) / totalNumberVariants) loggedList75

 set i 3
 set k 1
 set l floor(log max(tempFreqList) 2)

 while [l > 0]
 [
 set k (k * 2)
 let j k
 let sumPos 0
   while [j > 0]
   [
   set sumPos sumPos + ((occurrences i tempFreqList) / totalNumberVariants)
   set i i + 1
   set j j - 1
   ]
 set loggedList75 lput (sumPos / k) loggedList75
 set l l - 1
 ]

;;print out sampled data
   file-open "sampledLoggedData.txt"
   file-print "75% sample"
   foreach loggedList75 [ ?1 -> file-write ?1 ] file-print " "

   set variantsNeeded length(loggedList75)
   set variant 1

   while [variantsNeeded > 0]
   [
   file-write variant
   set variant (variant * 2)
   set variantsNeeded variantsNeeded - 1
   ]
   file-print" "


   ;;
   set variantsNeeded length(loggedList75)

   file-write 0.5
   set variantsNeeded variantsNeeded - 1

   set topBin 2
   set bottomBin 1

   while [variantsNeeded > 0]
   [
   file-write bottomBin + ((topBin - bottomBin) / 2)

   set bottomBin topBin  ;;do this first
   set topBin (topBin * 2) ;;do this second
   set variantsNeeded variantsNeeded - 1
   ]

   file-print" "
   file-close

;;now use tempFreqList to calculate tF
set sumOfSquares 0

foreach tempFreqList
 [ ?1 ->
 set sumOfSquares sumOfSquares + ((?1 / (sum tempFreqList)) ^ 2)
 ]

set F_assemblage_75 sumOfSquares
;;write "F_assemblage_75:"   ;;for testing
;;print F_assemblage_75  ;;for testing

set tF_assemblage_75 ((1 / sumOfSquares) - 1)
;;write "tF_assemblage_75:"   ;;for testing
;;print tF_assemblage_75  ;;for testing

file-open "sampledLoggedData.txt"
file-print "theta"
file-print theta
file-print "tF_assemblage_75"
file-print tF_assemblage_75
file-print "EF"
file-print EF
file-print "F_assemblage_75"
file-print F_assemblage_75
file-print" "
file-print" "
file-close



;;reset lists
set tempList (list)
set tempVariantsList (list)
set tempFreqList (list)

;;now start over with a sample of 90%
set tempList n-of round((length allTimeListOfCulturalVariants) * 0.9) allTimeListOfCulturalVariants

;create tempVariantsList and tempFreqList
while [length(tempList) > 0]
[
set tempVariant first tempList

ifelse member? tempVariant tempVariantsList = false
  [  ;;this variant is not already on the list
  set tempVariantsList lput tempVariant tempVariantsList  ;;place it at the end
  set tempFreqList lput 1 tempFreqList  ;;place a 1 at the end of the tempFreqList
  ]
  [  ;;else, this variant is already on the list, so just increment the count at the correct position in tempFreqList
  set oldFrequency item (position tempVariant tempVariantsList) tempFreqList
  set tempFreqList replace-item (position tempVariant tempVariantsList) tempFreqList (oldFrequency + 1)
  ]

set tempList remove-item 0 tempList
]

 set tempFreqList sort-by [ [?1 ?2] -> ?1 > ?2 ] tempFreqList  ;;sort in descending order...this doesn't matter for the log-log stuff
 ;;show tempFreqList ;;for testing
 set totalNumberVariants length(tempFreqList)
 ;;show totalNumberVariants ;;for testing
 set loggedList90 lput ((occurrences 1 tempFreqList) / totalNumberVariants) loggedList90
 set loggedList90 lput ((occurrences 2 tempFreqList) / totalNumberVariants) loggedList90

 set i 3
 set k 1
 set l floor(log max(tempFreqList) 2)

 while [l > 0]
 [
 set k (k * 2)
 let j k
 let sumPos 0
   while [j > 0]
   [
   set sumPos sumPos + ((occurrences i tempFreqList) / totalNumberVariants)
   set i i + 1
   set j j - 1
   ]
 set loggedList90 lput (sumPos / k) loggedList90
 set l l - 1
 ]

;;print out sampled data
   file-open "sampledLoggedData.txt"
   file-print "90% sample"
   foreach loggedList90 [ ?1 -> file-write ?1 ] file-print " "

   set variantsNeeded length(loggedList90)
   set variant 1

   while [variantsNeeded > 0]
   [
   file-write variant
   set variant (variant * 2)
   set variantsNeeded variantsNeeded - 1
   ]
   file-print" "

   ;;
   set variantsNeeded length(loggedList90)

   file-write 0.5
   set variantsNeeded variantsNeeded - 1

   set topBin 2
   set bottomBin 1

   while [variantsNeeded > 0]
   [
   file-write bottomBin + ((topBin - bottomBin) / 2)

   set bottomBin topBin  ;;do this first
   set topBin (topBin * 2) ;;do this second
   set variantsNeeded variantsNeeded - 1
   ]

   file-print" "
   file-close


;;now use tempFreqList to calculate tF
set sumOfSquares 0

foreach tempFreqList
 [ ?1 ->
 set sumOfSquares sumOfSquares + ((?1 / (sum tempFreqList)) ^ 2)
 ]

set F_assemblage_90 sumOfSquares
;;write "F_assemblage_90:"   ;;for testing
;;print F_assemblage_90  ;;for testing

set tF_assemblage_90 ((1 / sumOfSquares) - 1)
;;write "tF_assemblage_90:"   ;;for testing
;;print tF_assemblage_90  ;;for testing

file-open "sampledLoggedData.txt"
file-print "theta"
file-print theta
file-print "tF_assemblage_90"
file-print tF_assemblage_90
file-print "EF"
file-print EF
file-print "F_assemblage_90"
file-print F_assemblage_90
file-print" "
file-print" "
file-close



;;reset lists
set tempList (list)
set tempVariantsList (list)
set tempFreqList (list)

;;now start over with the population (i.e., the entire archaeological assemblage)
set tempList allTimeListOfCulturalVariants

;create tempVariantsList and tempFreqList
while [length(tempList) > 0]
[
set tempVariant first tempList

ifelse member? tempVariant tempVariantsList = false
  [  ;;this variant is not already on the list
  set tempVariantsList lput tempVariant tempVariantsList  ;;place it at the end
  set tempFreqList lput 1 tempFreqList  ;;place a 1 at the end of the tempFreqList
  ]
  [  ;;else, this variant is already on the list, so just increment the count at the correct position in tempFreqList
  set oldFrequency item (position tempVariant tempVariantsList) tempFreqList
  set tempFreqList replace-item (position tempVariant tempVariantsList) tempFreqList (oldFrequency + 1)
  ]

set tempList remove-item 0 tempList
]

 set tempFreqList sort-by [ [?1 ?2] -> ?1 > ?2 ] tempFreqList  ;;sort in descending order...this doesn't matter for the log-log stuff
 ;;show tempFreqList ;;for testing
 set totalNumberVariants length(tempFreqList)
 ;;show totalNumberVariants ;;for testing
 set loggedList100 lput ((occurrences 1 tempFreqList) / totalNumberVariants) loggedList100
 set loggedList100 lput ((occurrences 2 tempFreqList) / totalNumberVariants) loggedList100

 set i 3
 set k 1
 set l floor(log max(tempFreqList) 2)

 while [l > 0]
 [
 set k (k * 2)
 let j k
 let sumPos 0
   while [j > 0]
   [
   set sumPos sumPos + ((occurrences i tempFreqList) / totalNumberVariants)
   set i i + 1
   set j j - 1
   ]
 set loggedList100 lput (sumPos / k) loggedList100
 set l l - 1
 ]

;;print out sampled data
   file-open "sampledLoggedData.txt"
   file-print "population"
   foreach loggedList100 [ ?1 -> file-write ?1 ] file-print " "

   set variantsNeeded length(loggedList100)
   set variant 1

   while [variantsNeeded > 0]
   [
   file-write variant
   set variant (variant * 2)
   set variantsNeeded variantsNeeded - 1
   ]
   file-print" "


   ;;
   set variantsNeeded length(loggedList100)

   file-write 0.5
   set variantsNeeded variantsNeeded - 1

   set topBin 2
   set bottomBin 1

   while [variantsNeeded > 0]
   [
   file-write bottomBin + ((topBin - bottomBin) / 2)

   set bottomBin topBin  ;;do this first
   set topBin (topBin * 2) ;;do this second
   set variantsNeeded variantsNeeded - 1
   ]

   file-print" "
   file-close

;;now use this to caluclate tF
set sumOfSquares 0

foreach tempFreqList
 [ ?1 ->
 set sumOfSquares sumOfSquares + ((?1 / (sum tempFreqList)) ^ 2)
 ]

set F_assemblage_100 sumOfSquares
;;write "F_assemblage_100:"   ;;for testing
;;print F_assemblage_100  ;;for testing

set tF_assemblage_100 ((1 / sumOfSquares) - 1)
;;write "tF_assemblage_100:"   ;;for testing
;;print tF_assemblage_100  ;;for testing

file-open "sampledLoggedData.txt"
file-print "theta"
file-print theta
file-print "tF_assemblage_100"
file-print tF_assemblage_100
file-print "EF"
file-print EF
file-print "F_assemblage_100"
file-print F_assemblage_100
file-print" "
file-print" "
file-close
end ;;ends collectSamplesFromAssemblage

;;___________________________________________________
;;___________________________________________________


to durationOfAssemblageFormation
   ;;First, collect data on whether the population is below or above equilibrium.
   if (F < (EF - 0.005) )     ;;below, more diverse
   [
   set numberTimesBelowEquilibrium (numberTimesBelowEquilibrium + 1)
   ]

   if (F > (EF + 0.005) )     ;;above, less diverse
   [
   set numberTimesAboveEquilibrium (numberTimesAboveEquilibrium + 1)
   ]

   if (tF < theta )     ;;below
   [
   set numberTimesBelowEquilibriumtF (numberTimesBelowEquilibriumtF + 1)
   ]

   if (tF > theta )     ;;above
   [
   set numberTimesAboveEquilibriumtF (numberTimesAboveEquilibriumtF + 1)
   ]

   if (tF_1%Sample < theta )     ;;below
   [
   set numberTimesBelowEquilibriumtF_1%Sample (numberTimesBelowEquilibriumtF_1%Sample + 1)
   ]

   if (tF_1%Sample > theta )     ;;above
   [
   set numberTimesAboveEquilibriumtF_1%Sample (numberTimesAboveEquilibriumtF_1%Sample + 1)
   ]

  ;;Next, address various measures of diversity.
  set meanF (meanF + (F / d))  ;;mean F calculated from the entire population over the duration of assemblage formation
  set meantF (meantF + (tF / d))  ;;mean t_F calculated from the entire population over the duration of assemblage formation
  set meantF_1%Sample (meantF_1%Sample + (tF_1%Sample / d))   ;;mean t_F calculated from a 1% sample of the population over the duration of assemblage formation
  set meanKbar (meanKbar + (kbar / d))
  set meanVk (meanVk + (Vk / d))
  if F > maxF [set maxF F]  ;;keep track of the maximum value of F as calculated for the entire population recorded over the duration of assemblage formation
  if F < minF [set minF F]  ;;keep track of the minimum value of F as calculated for the entire population recorded over the duration of assemblage formation
  if tF > maxtF [set maxtF tF]  ;;keep track of the maximum value of t_F as calculated for the entire population recorded over the duration of assemblage formation
  if tF < mintF [set mintF tF]  ;;keep track of the minimum value of t_F as calculated for the entire population recorded over the duration of assemblage formation
  if tF_1%Sample > maxtF_1%Sample [set maxtF_1%Sample tF_1%Sample]  ;;keep track of the maximum value of t_F as calculated for 1% of the population recorded over the duration of assemblage formation
  if tF_1%Sample < mintF_1%Sample [set mintF_1%Sample tF_1%Sample]  ;;keep track of the maximum value of t_F as calculated for 1% of the population recorded over the duration of assemblage formation


 ;;Now allow for individuals to add variants to the archaeological assemblage
 ;;ask n-of round (N * 0.1) turtles  ;;this line can be used *in place of the line below* to model the condition in which a random subset of the population (here set at 10%) rather than the entire population deposit their cultural variant to the assemblage
 ask turtles  ;;each turtle contributes its variant to the assemblage
 [
 set allTimeListOfCulturalVariants lput t1 allTimeListOfCulturalVariants
 ]

 ;;Finally, collect some data from the population every time step after equilibrium was met for the first time, and print the results out to files.
 collectEquilibriumPopulationData

end  ;;ends durationOfAssemblageFormation

;;___________________________________________________
;;___________________________________________________



to learn    ;;turtle method, called within "go"
;;This procedure operationalizes unbiased cultural transmission from the "experienced" generation (age=1) to the naive generation (age=0).

 let teacher one-of turtles with [age = 1]   ;;ego randomly chooses one of the agents from the "experienced" generation to serve as its teacher (note that teacher is a local variable)
 ;;show teacher  ;;for testing
 ;;show [t1] of teacher  ;;for testing
 set t1 [t1] of teacher  ;;ego learns from teacher
 ;;show t1  ;;for testing
 ask teacher [set taughtThisGeneration (taughtThisGeneration + 1)]  ;;ask teacher to update the number of times that it served as a teacher during this time step

 ;;after social learning, allow for an "copying error" to modify the neutral variant according to the inifinite alleles model (each innovation yields a novel variant that has never before been seen in the population)
 if random-float 1 < mu   ;;if a random uniform float is less than mu, then there was a mistake in social learning
  [
  set t1 nextNovelVariant   ;;ego adopts a novel cultural variant rather than the one it was trying to copy from teacher
  set nextNovelVariant nextNovelVariant + 1   ;;increment this so the next time it is used it provides a variant that has never before been seen
  ]

  set color t1 ;;this resets the color of ego to reflect its new variant
  ;;show t1  ;;for testing
end  ;;ends learn

;;___________________________________________________
;;___________________________________________________


to printExactTestOutput  ;;observer method, called within "go".  this prints out data concerning the population, not the assemblage

   ;;print totalFrequencyList to a text file in order to apply Slatkin's exact test code
   file-open "exactTestData.txt"
   file-print ticks
   foreach totalFrequencyList [ ?1 -> file-write ?1 ] file-print " "

   let variantsNeeded 1
   while [variantsNeeded <= length totalFrequencyList]
   [
   file-write variantsNeeded
   set variantsNeeded (variantsNeeded + 1)
   ]
   file-print" "
   file-close

   if (sampleFrequencyList1 != 0)
   [
   ;;we need to print sampleFrequencyList to a text file in order to use Slatkin's exact test code
   file-open "exactTestData.txt"
   file-print ticks
   foreach sampleFrequencyList1 [ ?1 -> file-write ?1 ] file-print " "

   set variantsNeeded 1
   while [variantsNeeded <= length sampleFrequencyList1]
   [
   file-write variantsNeeded
   set variantsNeeded (variantsNeeded + 1)
   ]
   file-print" "
   file-close
   ]

end  ;;ends printExactTestOutput

;;___________________________________________________
;;___________________________________________________


to printHeaders   ;;called within "setup"
;;this creates new files they do not already exist and it prints out "heading" information pertaining to the current run of the simulation

 file-open "sampledLoggedData.txt"
 file-print " "
 file-write "seed N d mu" file-print " "
 file-write seed file-write N file-write d file-write mu file-print " "
 file-write "Time Data" file-print " "
 file-close

 file-open "exactTestData.txt"
 file-print " "
 file-write "seed N d mu" file-print " "
 file-write seed file-write N file-write d file-write mu file-print " "
 file-write "Time Data" file-print " "
 file-close

 file-open "exactTestData_assemblage.txt"
 file-print " "
 file-write "seed N d mu" file-print " "
 file-write seed file-write N file-write d file-write mu file-print " "
 file-write "Time Data" file-print " "
 file-close

 file-open "numberVariantsData.txt"
 file-print " "
 file-write "seed N d mu" file-print " "
 file-write seed file-write N file-write d file-write mu file-print " "
 file-write "Time N NumVariants F tF F_1% tF_1% EF theta minF meanF maxF mintF meantF maxtF mintF_1%Sample meantF_1%Sample maxtF_1%Sample atEquilibriumF belowEquilibriumF aboveEquilibriumF belowEquilibriumtF aboveEquilibriumtF belowEquilibriumtF_1%Sample aboveEquilibriumtF_1%Sample Ne meanKbar meanVk" file-print " "

end ;;ends printHeaders

;;___________________________________________________
;;___________________________________________________



to updatePlots  ;;observer method, called within "go"

;;None of these plots is absolutely necessary, they are just to provide an idea of what is going on during a run of the model.  See textfiles for data used in the analyses.
 set-current-plot "# of Unique Variants"
 auto-plot-on
 plot totalDiversity

 set-current-plot "Homogeneity"
 auto-plot-on
 set-current-plot-pen "F"
 plot F
 set-current-plot-pen "EF"
 plot EF

 set-current-plot "Diversity"
 auto-plot-on
 set-current-plot-pen "tF"
 plot tF
 set-current-plot-pen "tF_1%"
 plot tF_1%Sample
 set-current-plot-pen "theta"
 plot theta
end  ;;ends updatePlots

;;___________________________________________________
;;___________________________________________________



;;__________
;;REPORTERS
;;__________

;; this is a reporter used to count and report the number of occurrences of an item (x) in a given list (the-list)
to-report occurrences [x the-list]
  report reduce
    [ [?1 ?2] -> ifelse-value (?2 = x) [?1 + 1] [?1] ] (fput 0 the-list)
end
@#$#@#$#@
GRAPHICS-WINDOW
276
10
534
269
-1
-1
5.0
1
2
1
1
1
0
1
1
1
0
49
0
49
1
1
1
ticks
30.0

BUTTON
11
161
77
194
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

BUTTON
80
161
143
194
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
145
161
208
194
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
11
220
103
253
mu
mu
0
0.3
0.01
0.001
1
NIL
HORIZONTAL

SLIDER
10
126
102
159
seed
seed
0
1000000
20.0
1
1
NIL
HORIZONTAL

SLIDER
12
255
104
288
N
N
0
1000
100.0
25
1
NIL
HORIZONTAL

PLOT
546
329
746
479
# of Unique Variants
Time
#
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" ""

PLOT
546
27
746
177
Homogeneity
Time
F
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"F" 1.0 0 -16777216 true "" ""
"EF" 1.0 0 -2674135 true "" ""

TEXTBOX
10
110
160
128
Control center
11
0.0
1

TEXTBOX
11
203
161
221
Experimental parameters
11
0.0
1

TEXTBOX
9
18
271
101
Directions: \n1. Use the sliders and switches to set the parameter values as you like.\n2. Hit \"setup\".\n3. Hit \"go\" to start and again to stop the simulation.\n4. \"step\" executes a single time step.
10
0.0
1

TEXTBOX
11
393
459
464
Notes:\n1. Data are collected in .txt files, which will appear in the same location as this .nlogo file.\n2. Please see the \"Code\" tab for the commented source code.\n3. You will find a full model description and other tips under the \"Info\" tab.\n4. You can run many of the same experiments reported in the paper from \"BehaviorSpace.\"
10
0.0
1

PLOT
546
178
746
328
Diversity
Time
Theta
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"tF" 1.0 0 -16777216 true "" ""
"theta" 1.0 0 -2674135 true "" ""
"tF_1%" 1.0 0 -13345367 true "" ""

MONITOR
460
318
538
363
# teachers
meanTeachersPerGeneration
3
1
11

MONITOR
397
319
454
364
kbar
kbar
2
1
11

MONITOR
336
319
393
364
Vk
Vk
2
1
11

SLIDER
12
290
104
323
d
d
1
1000
10.0
1
1
NIL
HORIZONTAL

TEXTBOX
276
294
426
312
This is not a spatial model.
11
0.0
1

TEXTBOX
592
10
716
28
Data from populations
11
0.0
1

@#$#@#$#@
## WHAT IS IT?

premo_CA_2014.nlogo Version 1.0 (2010-2013): This model requires Netlogo version 5.0.2. Please keep in mind that the source code may require minor modifications to run on later versions of NetLogo.

This model can be used to study how time-averaging affects cultural diversity in assemblage data. The simulation employs unbiased cultural transmission between non-overlapping "generations" of social learners and allows individuals to deposit cultural variants ("artifacts") to an assemblage. The assemblage forms over d time steps following the first time step that a population reaches drift-copying error equilibrium. Numerous diversity estimates are then calculated for both the population and for random samples of varying size collected from the time-averaged assemblage of artifacts. Data are collected in textfiles to be analyzed outside of NetLogo (I used R, for example). The results show that some of the methods developed in population genetics systematically mistake unbiased cultural transmission for biased cultural transmission when they are applied to samples collected from a sufficiently time-averaged assemblage. The frequency with which these methods mistake unbiased transmission for a form of biased transmission increases with the duration of assemblage formation (*d*). 


## HOW TO USE IT

1. set the parameter values as you like  
2. click "setup" to initialize the model  
3. click "go" to start the simulation  
4. click "go" again to stop the simulation  

To run a new simulation under the same constellation of parameter values, simply change the value of "seed" before hitting the "setup" button.

The simulation stops itself *d* time steps after the first instance in which a population reached drift-copying error equilibrium.


## FULL MODEL DESCRIPTION

This model description accompanies Premo (2014) and follows the ODD protocol for individual-based models (Grimm *et al*. 2006).


*Purpose*   
 
The purpose of this model is to investigate the way(s) in which time-averaging affects cultural diversity in assemblage data. The assumptions of the Wright-Fisher model of reproduction are made here, but in the context of cultural transmission. The model represents the unbiased transmission of selectively neutral cultural variants between non-overlapping generations within a constant-sized, finite population of social learners. The model generates (and then samples) simulated assemblages that form as the result of individuals depositing material manifestations of their cultural variants through time. These data are analyzed using methods that, although originally designed to identify departures from neutrality in genes sampled from a population, have been applied to time-transgressive cultural data in attempts to identify departures from unbiased cultural transmission in samples collected from the archaeological record. 

The general question the model addresses is: How does time-averaging affect the ability (or utility) of methods that were originally designed to detect departures from the expectations of neutrality in genes sampled from a population to correctly identify unbiased cultural transmission in assemblage data? Or, in other words, are the analytical tools developed for investigating neutrality in populations appropriate and useful for identifying modes of cultural transmission in the types of time-averaged cultural datasets that, although commonplace for archaeologists and other anthropologists, are encountered rarely--if ever--by population geneticists? 



*State variables and scales* 
   
The model includes just one class of agents: social learners. Each social learner (also referred to as an "individual" throughout the remainder of the model description) acquires its cultural variant by learning (i.e., copying) it from an "experienced" individual through a process of cultural transmission that includes "noise." Noise takes the form of occasional copying errors. Social learners deposit a single copy of their cultural variant in the simulated assemblage once per time step. Social learners have 3 state variables: *t1*, *age*, and *taughtThisGeneration*. 

*t1* is short for "trait 1." *t1* represents a cultural trait that can exhibit any of an infinite number of variants, where each possible variant is represented by an integer. The cultural trait is non-adaptive (i.e., selectively neutral). Different variants (integers) have no inherent fitness effect that makes them intrinsically more or less likely to be copied. An agent’s *t1* value is reflected by its color in the visual display on the "Interface" tab. 

*age* is used to distinguish naive individuals (*age*=0) from "experienced" ones (*age*=1) for the purposes of operationalizing unbiased cultural transmission. Following cultural transmission but before artifact deposition, the experienced generation (all individuals with *age*=1) is removed from the simulation. 

*taughtThisGeneration* can be assigned an integer value that represents the number of times that individual serves as a "teacher" during the one and only time step in which it is a member of the experienced generation. This integer value can range from 0 to *N*. Under neutral conditions (like those modeled here), *taughtThisGeneration* should approximate a Poisson distribution with a mean (and variance) of 1 (Crow and Kimura 1970:346) in a population of experienced individuals following the round of social learning in which they serve as potential teachers. Note that the mean (and variance) number of times each experienced agent serves as a teacher equals 1 rather than 2 as described in Crow and Kimura (1970) because here we are modeling "haploid" cultural traits rather than diploid genes. The expectation that the mean (*kbar* on the interface) and variance (*Vk* on the interface) of *taughtThisGeneration* both approximate unity was used as an independent check to verify that the mode of cultural transmission in this model is, in fact, unbiased (answer: the expectation that mean~variance~1 was met, the mode of cultural transmission is unbiased, as intended). 

There are also 3 important global variables: *N*, *µ*, and *d*. *N* represents (census) population size. Population size remains constant during each simulation run. Near the beginning of each time step, *N* individuals are created in the naive generation (i.e., *age*=0), and near the end of each time step, the *N* members of the experienced generation (i.e., *age*=1) are removed, leaving a population of size *N* to start the next time step. To accommodate for the fact that demographic factors can affect cultural evolutionary dynamics, population size is varied across simulations: *N*=25, 50, 100, or 200. The copying error "rate" is given by *µ*, which provides the probability that an error will occur during transmission. The parameter *d* represents the duration of assemblage formation. Put simply, the extent to which an assemblage is time-averaged increases with *d*. 

The model is not spatially explicit. The "world" is provided on the "Interface," but it was used only for visual debugging. None of the code makes use of the spatial coordinates of the agents displayed on the "world." 



*Process overview and scheduling* 
  
At the start of each time step, one unit of simulated time passes (*ticks* are incremented by 1) and all individuals "age" (that is to say that *age*=0 is set to *age*=1 in all *N* social learners) to reflect that they will now serve as members of the "experienced" (or "parental") generation in the coming time step. Following the updating of time, each time step includes four important stages that occur in the following order: 1) a new (or “offspring”) generation of *N* naïve individuals (*age*=0, *t1*=0) is created, 2) cultural variants are passed from members of the experienced generation (*age*=1, *t1*>0) to members of the naive generation (*age*=0, *t1*=0) via unbiased cultural transmission (see *Submodels* below), 3) all members of the experienced generation (*age*=1, *t1*>0) are removed from the simulation, and 4) each of the *N* individuals that remain (*age*=0, but now *t1*>0) adds a copy of its newly adopted cultural variant to the time-transgressive assemblage of cultural material. 

Simulated assemblages grow at a rate of *N* items per time step for *d* time steps following the first time step in which cultural diversity reaches equilibrium in the population. Although time steps are synonymous with generations in the model, this is not meant to imply that individuals in the real world can learn a cultural variant only once in a lifetime. One can just as easily think of each "generation" in the simulation as a population-wide cultural transmission "event," in which each individual in the population adopts either a variant displayed by someone (including itself) during the previous time step as a result of social learning or a variant that is entirely new as the result of a copying error. As mentioned above, the model is not spatially explicit, so there is no spatial scale to speak of. 


*Design concepts* 

Evolution: 
In each run of this model, the cultural variant frequencies of a population change through time. However, here, changes in variant frequencies are due to drift and copying error, only. There is no selection (biological or cultural) in this model, just as there is no cultural borrowing (roughly analogous to gene flow) from another population.

Sensing: 
A naive individual (*age* = 0) can sense the *t1* value of the individual it chooses randomly from among the members of the experienced generation to serve as its "teacher." 

Stochasticity: 
Here are some examples of stochasticity in the model. With unbiased cultural transmission each naive individual randomly selects a member of the experienced generation (with replacement) to serve as its "teacher." Copying errors are also stochastic, occurring with probability *µ*. Diachronic changes in the relative frequencies of cultural variants are explained solely by the stochastic forces of drift and copying error (and, even then, predominantly by the former). Stochasticity is even involved in data collection: random samples are drawn from the time-transgressive assemblage. 

Observation: 
Data collection occurs only after cultural diversity has reached equilibrium for the first time during a simulation. Cultural diversity is at equilibrium when the observed homogeneity, *F* (*F* is the sum of the squared relative frequencies of cultural variants in a population of social learners [not in an assemblage]), is equal to the probability of obtaining the same cultural variant from two individuals drawn randomly from the population. Frasier Neiman (1995) shows that in the case of unbiased cultural transmission, the expected value of *F* at equilibrium is given by: *F* = 1 / ((2 * *Ne* * *µ*) + 1), where *Ne* is the effective size of a population (note that while the census size and the effective size of the same population can differ drastically, under neutral model conditions, like those modeled here, *Ne*=*N*) and *µ* is the copying error rate. To allow for the fact that observed *F* might never be exactly equivalent to the expected value of *F* for a given *N*, for the purposes of the model a population is deemed to be at equilibrium when the observed homogeneity (*F*) is within ±0.005 of (1 / ((2 * *N* * *µ*) + 1)). 

Data are collected from the population of social learners during each of *d* time steps following the first time step in which the population reaches equilibrium. More importantly, at the end of each simulation run, data are collected from the assemblage that formed over *d* time steps. Random samples of various sizes are collected from each simulated assemblage. The various approaches used to test for departures from the expectations of neutrality in each simulation are applied to the same set of samples. 

The following measures/estimators of diversity in the population of social learners are calculated during the course of each simulation (please see paper for equations): *tF*, *F*, *H*, and Shannon’s Index. At the end of each run, *tF* and *F* are calculated from samples drawn from the simulated time-averaged assemblage. In addition, I use Montgomery Slatkin’s freely available software (see Slatkin 1996) to calculate *tE* and to obtain *PE* values from Slatkin’s Exact test and *PH* values from the Ewens-Watterson homozygosity test for samples collected from the assemblage. An R script (programmed by Premo) is used to apply the variants frequency approach to the same samples collected from the assemblage. 

Initialization: 
Each simulation run is initialized with a population in which every individual displays a unique cultural variant at *t1* (represented as an integer). At initialization, the number of unique variants (*k*) in the population is equal to *N*. Individuals are randomly assigned to a patch at the start of each run. This model is not spatially explicit, so the *x* and *y* coordinates of the individuals play no role. Population size (*N*) remains constant throughout each simulation run, but can vary among runs. The copying error rate (*µ*) is the same for all individuals for the duration of each simulation run, but can vary among runs. Each simulation is initialized with a value of *d*. I vary *d* across simulations to investigate the effect of time-averaging on cultural diversity in assemblages. Table 1 provides the parameter values used to initialize the model. Each experimental condition, or constellation of parameter values, was replicated 20 times. 


Table 1. Parameter values used to initialize the simulations reported in the text.  
__________________________________________________________________________  	

Copying error rate, *µ* ........................................... 0.01, 0.001*
Population size, *N* ............................................... 25, 50, 100, or 200
Duration of assemblage formation, *d* ...................... 10, 100, or 1000  
__________________________________________________________________________
* Although data collected under *µ*=0.001 are briefly summarized in Premo (2014), they are not shown in full simply because the effects of *d* are qualitatively similar to those under *µ*=0.01, which are shown in full and discussed at length.


*Submodels*    

Unbiased cultural transmission (see the method, "learn"):
The transmission of cultural variants from the experienced generation to the naïve generation is unbiased. With unbiased transmission, no cultural variant is intrinsically more attractive than any other variant. Those variants displayed at a higher frequency in the experienced generation are more likely to be passed on to the naive generation, but only because they are less likely than those displayed at lower frequencies to be lost due to the sampling variance present in any finite population. Each member of the naïve generation adopts the cultural variant displayed by a "teacher," an individual chosen randomly (and with replacement) from among all of the members of the experienced generation (i.e., all individuals with *age*=1), with probability 1-*µ*, where *µ* represents the probability of making an error while copying the variant during cultural transmission (see more on copying error below). It is important to note that in this model we assume that naïve individuals cannot learn from a member of their own generation (i.e., there is no horizontal transmission), that they cannot learn from an individual who lived more than one generation prior to their own, and that they cannot learn directly from a cultural variant recovered from the time-transgressive assemblage. Although a valid argument can be made that some or all of these assumptions should be relaxed when modeling cultural transmission and cultural evolution in real populations, they are not relaxed here precisely because they are fundamental to the population genetics models (which, remember, deal with the transmission of genes, not cultural traits) upon which the analytical tools and tests that are the focus of this study are based.

The probability of making a copying error per instance of cultural transmission (of which there are *N* per time step) is given by *µ*. A copying error results in the naive individual adopting a novel cultural variant rather than the one it was attempting to copy from its "teacher." A novel cultural variant is one that has not yet appeared during the course of the simulation. For example, as a result of a copying error, a naive individual trying to copy a value of 32 might instead adopt 211 (assuming the previous value adopted as the result of a copying error was 210). The next copying error will result in some other naive individual adopting 212 instead of the value displayed by its teacher, and so on. There is no limit to the integer value that a novel cultural variant can take. Thus, this model employs an "infinite variants" model of copying error, not because I find it to be a particularly realistic way to model culture (although this still needs to be investigated empirically), but because it is an assumption made by the population genetic models upon which the quantitative methods routinely employed by anthropologists who study cultural transmission are based. 



*References Cited*  

Crow, James F., and Motoo Kimura. 1970. *An Introduction to Population Genetics Theory*. Caldwell, New Jersey: Blackburn Press.

Grimm, Volker, *et al*. 2006. A standard protocol for describing individual-based and agent-based models. *Ecological Modelling* 198:115-126. 

Neiman, Frasier. 1995. Stylistic variation in evolutionary perspective: Inferences from decorative diversity and interassemblage distance in Illinois Woodland ceramic assemblages. *American Antiquity* 60:7-36. 

Premo, L. S. 2014. Cultural transmission and diversity in time-averaged assemblages. *Current Anthropology* 55:#-#. 

Slatkin, Montgomery. 1996. A correction to the exact test based on the Ewens sampling distribution. *Genetical Research* 68:259-260. 

Wilensky, Uri. 1999. *NetLogo*. http://ccl.northwestern.edu/netlogo/. Center for Connected Learning and Computer-Based Modeling, Northwestern University. Evanston, Illinois.



*Notes*

One can find some experiments saved in "BehaviorSpace." If you plan to analyze the data collected in the textfiles and you are using a computer with more than one processor to run the source code, you may wish to make sure that only 1 simulation is run at a time (to do so, when prompted by BehaviorSpace, simply set "Simulations run in parallel" to 1). 

In advance of publication, I have streamlined the source code to make it easier to read and understand. Version 1.0 contains all of the methods that were used in the experiments that yielded the results reported in the paper. However, it does not include a number of methods and variables that, although present in an earlier working version of the code, were not used in generating or analyzing any of the data presented in the paper. I removed all blocks of unused code to increase the clarity and accessibility of the source code. Nevertheless, please know that if you would like to see the earlier, longer version, which differs from the source code provided here only in that it contains a number of additional methods and variables that were not used during the generation or collection of the data presented in the *CA* paper, I am more than happy to provide it upon request (luke.premo at wsu dot edu).

One of the best things about computer simulation programs is that they can often be improved with the help of other researchers. The more sets of eyes that pass over the code, the better. So, please, have a look at the source code attached to the article. Any comments, questions, or corrections are always welcome. 



## CURRENT CONTACT INFORMATION

This model was programmed by Luke Premo of the Department of Anthropology, Washington State University and the Department of Human Evolution, Max Planck Institute for Evolutionary Anthropology.

Luke Premo  
Department of Anthropology
Washington State University
Pullman, WA 99164-4910 

luke.premo at wsu dot edu
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
NetLogo 6.1.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="exp_d100" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="20000"/>
    <enumeratedValueSet variable="d">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mu">
      <value value="0.01"/>
      <value value="0.001"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="N">
      <value value="25"/>
      <value value="50"/>
      <value value="100"/>
      <value value="200"/>
    </enumeratedValueSet>
    <steppedValueSet variable="seed" first="1" step="1" last="20"/>
  </experiment>
  <experiment name="exp_d10" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="20000"/>
    <enumeratedValueSet variable="d">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mu">
      <value value="0.01"/>
      <value value="0.001"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="N">
      <value value="25"/>
      <value value="50"/>
      <value value="100"/>
      <value value="200"/>
    </enumeratedValueSet>
    <steppedValueSet variable="seed" first="1" step="1" last="20"/>
  </experiment>
  <experiment name="exp_d1000" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="20000"/>
    <enumeratedValueSet variable="d">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mu">
      <value value="0.01"/>
      <value value="0.001"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="N">
      <value value="25"/>
      <value value="50"/>
      <value value="100"/>
      <value value="200"/>
    </enumeratedValueSet>
    <steppedValueSet variable="seed" first="1" step="1" last="20"/>
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
