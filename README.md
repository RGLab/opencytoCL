---
title: "Using OpenCyto Command Line Tools"
author: "Greg Finak"
date: "2017-06-09"
output: rmarkdown::html_vignette
vignette: >
  %\VignetteIndexEntry{Using OpenCytoCLI}
  %\VignetteEngine{knitr::rmarkdown}
  %\VignetteEncoding{UTF-8}
---
## Notes

Currently openCyto command line tools work with Linux and Mac OS X

## Install OpenCyto Command Line Tools

To install the package run the following in R:



```r
library(devtools)
install_github("RGLab/opencytoCL")
```

You will need all the dependencies:

- openCyto
- optparse
- littler

## Linux and MacOS X

Then, in R:


```r
install_openCytoCL()
```

## Usage
For help, at the command prompt, type:


```bash
opencyto -h
```

```
Usage: 
	opencyto parse <workspace> <fcs_read_from> <save_to> [--stats] --group=<group_number>  [--annotate=<keywords>]
	opencyto parse <workspace>
	opencyto load --gs=<gatingset> [--stats]
	opencyto gate --gs=<gatingset> --template=<template> [--stats]
	opencyto process <fcs_read_from> <save_to> [--compensate] [--transform [<parameters>]] [--rscript=<rscript>]  [--annotate=<keywords>]
	opencyto process --gs=<gatingset> --rscript=rscript
Commands:
	parse     Import a workspace and create a GatingSet.
	load      Load a workspace and print sample groups found therein. Optionally extract population statistics.
	gate      Gate a workspace using a template, saving the results. Optionally extract population statistics. Existing gates are removed. 
	process   Process FCS files in to a GatingSet with optional compensation, transformation and custom processing.
Arguments:
	<workspace>     The name of the workspace (wsp or xml format)
	<fcs_read_from> The directory of FCS files (must exist).
	<save_to>       The directory to save the gating set (must not exist).
	<parameters>    The parameters to transform. Pass a comma separated list, e.g. --transform FL1-A,FL2-A,FL3-A
Options:
  --group=<group_number>     The number of the sample group to import from the workspace.
  --stats                    Save a csv of cell population statistics.
  --gs=<gatingset>           The name of the gating set.
  --template=<template>      The name of an openCyto csv gating template.
  --compensate               Compensate using the spillover matrix from the FCS files. 
  --transform                Transform using a default logicle / biexponential transform. By default it transforms all channels containing "FL".
  --rscript=<rscript>        A custom R script to process a gating set (variable name `gs`). Run after compensate and transform.
  --annotate=<keywords>      Annotate a gating set with information extracted from keywords.
                             Keywords should be passed in as a comma separated list.
                             If parsing FCS files, the keywords are taken from the FCS files. 
                             If parsing a workspace, the keywords are taken from the workspace 
```

### parse
Import a FlowJo workspace and related FCS files and create a GatingSet.

#### options

`<workspace>` the location of the workspace

`<fcs_read_from>` the location of the fcs files

`<save_to>` the name of the gating set to save

`--group=<group_number>` option to specify the group number to import. Print all group names using `load` (see below).

`--annotate=<keywords>` optionally annotate by importing keywords. Keywords should be passed in as a quoted, comma separated list. If parsing FCS files, the keywords are taken from the FCS files.  If parsing a workspace, the keywords are taken from the workspace. Spaces in keywords should be replaced with `:`.

`--stats` Extract population statistics and write them to a file.

### load
Load a FlowJo workspace and print the sample groups in therein.

#### options

`--gs=<gatingset>` the name of the gating set to load. Created using `parse` (see above) or `process` (see below) 

### gate
Gate a GatingSet using a template, saving the results. Optionally extract population statistics. Any existing gates in the GatingSet are removed. 

#### options

`--gs=<gatingset>`  A GatingSet on which to perform automated gating.

`--template=<template>`  The name of an openCyto template csv file.

`--stats`  Extract population statistics and write them to a file.

### process

`<fcs_read_from>` location of files to process

`<save_to>` name of gating set to save to

`--compensate` perform compensation using the matrix in the FCS files.

`--transform [<parameters>]` Transform parameters using the default biexponential transformation. Parameters are passed in as a comma separated list, e.g. `--transform FL1-A,FL2-A,FL3-A`

`--rscript=<rscript>` if additional processing needs to be done, pass in an R script. The script can work with the GatingSet variable `gs`. It is run after `compensate` and `transform`.

`--gs=<gatingset>` optionally read from a GatingSet rather than FCS files. Can be combined with `--rscript`. GatingSet data are already compensated and transformed.




