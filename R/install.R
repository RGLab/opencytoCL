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
