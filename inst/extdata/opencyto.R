#!/usr/local/bin/Rscript

suppressPackageStartupMessages({opt_loaded = require(docopt)})
if(!opt_loaded)
	stop("You must install docopt.")

parsing_done=FALSE

.load_opencyto = function(){
message("Loading opencyto.")
suppressWarnings({
  suppressPackageStartupMessages({
	opcyto_loaded = require(openCyto)
	if(!opcyto_loaded){
	  message("You must install opencyto.")
		q(save="no",status=0)
	}
})})
}

.parseKeywordsArg = function(kw){
	kwlist = strsplit(gsub(":"," ",gsub("\"","",kw)),split = ",")[[1]]
	return(kwlist)
}

.extractKeywordsFromGS = function(G,kwlist){
	toann = do.call(cbind,lapply(kwlist,function(x)keyword(G,x)))
	toann$name=sampleNames(G)
	rownames(toann)=sampleNames(G)
	return(toann)
}

usage = 'Usage:
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
'

opt = docopt(usage,help = TRUE, version="0.1.0",quoted_args=TRUE)


#PARSE SECTION
if(opt[["parse"]]){
	#check validity of arguments
	if(!file.exists(opt[["workspace"]])){
		stop("Workspace \"",basename(opt[["workspace"]]),"\" doesn't exist at \"",dirname(opt[["workspace"]]),"\"")
	}
	dontparse=TRUE
	#Does the output exist?
	if (!is.null(opt[["save_to"]])) {
		if (dir.exists(opt[["save_to"]])) {
			stop("Gating Set named ", opt[["save_to"]], " already exists!")
		} else if (!dir.exists(dirname(opt[["save_to"]]))) {
			stop("Directory ", dirname(opt[["save_to"]]), " does not exist!")
		}else{
			dontparse=FALSE
		}
	}

	if (!is.null(opt[["fcs_read_from"]])) {
		if (!dir.exists(opt[["fcs_read_from"]])) {
			stop("Directory ", dirname(opt[["fcs_read_from"]]), " does not exist!")
		}else{
			dontparse = FALSE
		}
	}

.load_opencyto()

if(!is.null(opt[["workspace"]])){
	#open the workspace and read the sample groups
	ws = openWorkspace(opt[["workspace"]]);
	groups = unique(getSampleGroups(ws)$groupName)

	cat("\nFound sample groups\n");
	for(i in seq_along(groups)){
		cat("\t",paste0(i,"."),as.character(groups[i]),"\n")
	}

	#did we provide a groupname?
	if(is.null(opt[["--group"]])){
		message("Parse using:\nopencyto parse ",opt[["workspace"]]," <read_from> <save_to> --group=<groupnumber>")
		message("Workspace not parsed.")
		q(save="no",status=0)
	}else{
		#if we did go ahead and parse, provided the rest of the arguments are valid. We should have checked those already.
		if(!dontparse){
			message("Parsing group ",basename(opt[["--group"]])," from\n",opt[["fcs_read_from"]])
			suppressWarnings({
				if(is.null(opt[["--annotate"]])){
					gs = parseWorkspace(ws,name=as.numeric(opt[["--group"]]),path=opt[["fcs_read_from"]])
				}else{
					kwlist = .parseKeywordsArg(opt[["--annotate"]])
					#parse and annotate with keywords from xml
					gs = parseWorkspace(ws,name=as.numeric(opt[["--group"]]),path=opt[["fcs_read_from"]],keywords.source = "XML",keywords = kwlist)
				}
			})
			save_gs(gs,path=opt[["save_to"]])
			parsing_done = TRUE
			message("Done!")
		}else{
			message("You must enter a valid source path to <read_from> for the FCS file\nand a valid path to <save_to> for the parsed gating set.")
		}
	}
}
}

#load command
if((opt[["load"]])){
	if(dir.exists(opt[["--gs"]])){
		.load_opencyto()
		gs = load_gs(opt[["--gs"]])
		parsing_done=TRUE
	}else{
		stop("gating set does not exist: ",opt[["--gs"]])
	}
}

if(opt[["gate"]]){
	if(dir.exists(opt[["--gs"]])){
		.load_opencyto()
		gs = load_gs(opt[["--gs"]])
		parsing_done=TRUE
	}else{
		stop("gating set does not exist: ",opt[["--gs"]])
	}
	if(file.exists(opt[["--template"]])){
		gt = gatingTemplate(opt[["--template"]])
	}else{
		stop("gating template does not exist: ", opt[["--template"]])
	}
	message("Gating using template")
	suppressWarnings(gating(gt,gs))
	save_gs(G = gs,path=opt[["--gs"]],overwrite = TRUE)
	parsing_done=TRUE
}


#summarizing stats
if(parsing_done){
 if((opt[["--stats"]])){
 	if(inherits(gs,"GatingSet")){
	  stats = getPopStats(gs)
	  write.csv(stats,file=file.path(getwd(),paste0(basename(dirname(gs@data@file)),"_stats.csv")),row.names=FALSE)
	  message("statistics written to ",file.path(getwd(),paste0(basename(dirname(gs@data@file)),"_stats.csv")))
 	}else{
 		message("Specify a gating set to load with\n opencyto load --gs=<gatingset> --stats")
 	}
  }
}


if(opt[["process"]]) {
	if (is.null(opt[["--gs"]])) {
		if (!dir.exists(opt[["fcs_read_from"]])) {
			stop("Directory ", opt[["fcs_read_from"]], " does not exist.")
		}
		if (dir.exists(opt[["save_to"]])) {
			stop("Directory ", opt[["save_to"]], " already exists.")
		}
		if(!is.null(opt[["--rscript"]])){
			if (!file.exists(opt[["--rscript"]])) {
				stop("rscript ", opt[["--rscript"]], " not found.")
			}
		}
		.load_opencyto()
		files = list.files(path = opt[["fcs_read_from"]],
								 pattern = "*\\.fcs$",
								 full = TRUE)
		nc = read.ncdfFlowSet(files)
		if (opt[["--compensate"]]) {
			#figure out where the spillover matrix is located
			spill = spillover(nc[[1]])
			chosen = NA
			for (i in 1:length(spill)) {
				if (!is.null(spill[[i]])) {
					chosen = i
					break
				}
			}
			gs = GatingSet(ncfsApply(nc, function(x)
				compensate(x, spillover(x)[[i]])))
		} else {
			gs = GatingSet(nc)
		}
		if (opt[["--transform"]]) {
			if(!is.null(opt[["parameters"]])){
				pars = opt[["parameters"]]
				pars = gsub("\"","",pars)
				pars = strsplit(pars,split = ",")[[1]]
				fromList = colnames(gs)[which(colnames(gs)%in%pars)]
			}else{
				fromList = colnames(gs)[which(grepl("FL",colnames(gs)))]
				if(length(fromList)==0){
					stop("Must specify parameters via --parameters option. \n The following parameters are found: ",paste(colnames(gs),collapse="\n"))
				}
			}
			message("Transforming ", paste(fromList, collapse = " "))
			trns = transformerList(from = fromList, trans = flowJo_biexp_trans())
			gs = transform(gs, trns)
		}
	}else{
		if(!dir.exists(opt[["--gs"]])){
			stop("GatingSet ",opt[["--gs"]]," does not exist.")
		}
		.load_opencyto()
		gs = load_gs(opt[["--gs"]])
	}
	if(!is.null(opt[["--rscript"]]))
		source(opt[["--rscript"]])

	if(!is.null(opt[["--annotate"]])){
		#Annotate with keywords from gating set
		kwlist = .parseKeywordsArg(opt[["--annotate"]])
		toann = .extractKeywordsFromGS(G=gs,kwlist=kwlist)
		toann = merge(pData(gs),toann,by="name")
		rownames(toann)=rownames(pData(gs))
		pData(gs)=toann
	}
	if(is.null(opt[["save_to"]])){
		save_gs(gs, path = basename(dirname(gs@data@file)),overwrite=TRUE)
	}else{
		save_gs(gs, path = opt[["save_to"]])
	}
}

message("Exiting.")
q(save="no",status=0)

