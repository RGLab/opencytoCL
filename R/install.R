#Copyright (c) 2017, Greg Finak

ostype <- function() {
	if (.Platform$OS.type == "windows") {
		"win"
	} else if (Sys.info()["sysname"] == "Darwin") {
		"mac"
	} else if (.Platform$OS.type == "unix") {
		"unix"
	} else {
		stop("Unknown OS")
	}
}

#'fastfindFCS
#'
#' @param path
#'
#'@export
fastfindFCS = function(path){
	system2(command="find",args = paste(path,"-name","'*.fcs'"),stdout=TRUE)
}

#' Find fcs files paths from a list matching a gating set
#'
#' Matches based on file name and event number. Assumes the gating set has event number appended to
#' file name in the sampleName slot.
#'
#' @param gs a gating set
#' @param files a list of FCS files with full paths
#'
#' @return a vector of full paths to files matching the FCS files in the gating set.
#' @export
findFCSFiles = function(gs,files){
	fgs = sampleNames(gs)
	files = files[basename(files)%in%gsub("_.*","",fgs)]
	fs  = map(files,function(x){
		h = read.FCSheader(x)[[1]]
		f = gsub(" ","",paste0(h["$FIL"],"_",h["$TOT"]))
		f
	})
	files[fs%in%fgs]
}

#' Install opencyto command line tools
#' Supports linux and mac os X
#' @export
install_openCytoCL = function(to="/usr/local/bin"){
	os = ostype()
	if(os=="Win"){
		stop(os, " not currently supported")
	}
	if(os == "Unknown OS"){
		stop(os, " not supported")
	}else{
		message("Detected ", os, ". Installing opencyto to /usr/local/bin")
	}
   path = system.file(package = "openCytoCL","extdata")
   files = list.files(path,full=TRUE)
   ind = grep("opencyto\\.R",files)
   if(length(ind)!=1){
   	stop("Something is wrong. Can't find opencyto.R.")
   }else{
   	files = files[ind]
	command = paste0("ln -s ",files," /usr/local/bin/opencyto\n")
	system(command,)
   }
}



#' KS Distance between files in FSC/SSC space.
#'
#' Computes the ks distance betwen files in a flowset.
#' @param myflowset a \code{flowSet}
#' @param cl a \code{cluster} object. Default NULL.
#'
#' @return A \code{distance} matrix object.
#' @export
#'
distanceMatrixBetweenFiles = function(myflowset,cl=NULL){
	if(!inherits(myflowset,"flowSet")){
		stop("myflowset must be a flowSet")
	}
	if(inherits(myflowset,"ncdfFlowSet")){
		myflowset=as.flowSet(myflowset)
	}

	m = matrix(0,nrow = length(myflowset),ncol = length(myflowset))
	colnames(m) = sampleNames(myflowset)
	rownames(m) = sampleNames(myflowset)

	pairs = list()
	for(i in 1:(nrow(m)-1)){
		for(j in (i+1):ncol(m)){
			pairs = c(pairs,list(c(rownames(m)[i],colnames(m)[j])))
		}
	}
	if(is.null(cl)){
		clnull=TRUE
	}
	if(clnull){
		require(parallel)
		ncores = max(1,detectCores()-1)
		message("Building cluster of ",ncores,ifelse(ncores>1," cores."," core."))
		cl = makeCluster(ncores)
	}else if(!inherits(cl,"cluster")){
		stop("cl must be of type 'cluster' created by makeCluster()")
	}

	message("Setting up cluster environment")
	.setupClusterEnv = function(cl=NULL){
		clusterEvalQ(cl=cl,library(flowCore))
		clusterEvalQ(cl=cl,library(flowIncubator))
	}
	.setupClusterEnv(cl=cl)
	message("Computing distance matrix")
	D = parLapply(cl = cl,pairs,fun = function(x){
		e1 = exprs(myflowset[[x[1]]])
		e2 = exprs(myflowset[[x[2]]])
		d = ksstat(e1[,1],e2[,1])
		d = d + ksstat(e1[,2],e2[,2])
		return(d)
	})
	message("Done. Cleaning up.")
	if(clnull){
		stopCluster(cl)
	}
	D = do.call(c,D)

	for(i in seq_along(pairs)){
		m[pairs[[i]][1],pairs[[i]][2]] = D[i]
	}
	return(as.dist(t(m)))
}
