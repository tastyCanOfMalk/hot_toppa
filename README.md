Hot topping analysis
=========

This R script interprets imported .log data received from a data logger, logging time & temperature on an exothermic sample.

Use
-----
Use of this script requires the statistical program [R] [1] and preferably the IDE [RStudio] [2]. The script also makes use of the R packages: grid, gridRxtra, & ggplot2.

There are three variables that need defined before using the program

- working directory
- filename prefix
- number of runs

####*Working directory* 
is the folder where the .log logfiles are stored & read from. For example, if your working directory is found in "C:/Ignition/logfiles", you would enter the following in R: 

```
setwd("C://Ignition//logfiles")
```

Note the use of double forward slashes.

####*Filename prefix* 
is the common prefix that all .log filenames have in common, and assumes that all names are incrementally increased by +1. You must appropriately name your files so the script can detect & create them. For example, my three filenames are as follows: "6000-001.log", "6000-002.log", "6000-003.log". I would set the filename prefix as "6000-00" by entering the following code in R: 

```
prefix <- "6000-00"
```

####*Number of runs*
is the number of .csv file to be read for interpretation. In general tests are done in triplicate, so the value is left at "3". In some cases, however, there may be a broad range of testing that requires only 2 runs to determine a general pattern. Or alternatively 9 runs or more to determine a baseline. In this case, the number of runs would be adjusted to 2 by entering the following in R:

```
numruns <- 2
```
####*Export to png or pdf (optional)*
enables or disables exporting the graphical plots to .png or pdf format. To enable, simply uncomment the appropriate function AFTER the R script has run at least once (otherwise it exports data before data is computed). Export functions are commented out by default.

```
#export_png(filenames, 1400, 1800)
#export_pdf(filenames, 15.5, 18)
```
Uncomment the desired format (adjust dimensions of export if necessary), and then execute the line of script (Ctrl + Enter in RStudio). 

Theory
--------
There are three valuable variables to be interpreted from this data:
- Max temperature
- Duration of exotherm

To determine the above values we need to define certain variables used to compute them:

```
Max temperature
= maximum temperature value
```

```
Duration of exotherm
= time between [max temp] & [max temp - 250°C]
```

Future changes
----
Features that may or may not be added in the future:

- Rewriting this readme

[1]:http://cran.us.r-project.org/
[2]:https://www.rstudio.com/
