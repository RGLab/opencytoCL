#Copyright (c) 2017, Greg Finak
#
#Permission is hereby granted, free of charge, to any person obtaining
#a copy of this software and associated documentation files (the
#"Software"), to deal in the Software without restriction, including
#without limitation the rights to use, copy, modify, merge, publish,
#distribute, sublicense, and/or sell copies of the Software, and to
#permit persons to whom the Software is furnished to do so, subject to
#the following conditions:
#
#The above copyright notice and this permission notice shall be
#included in all copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
#EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
#MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
#NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
#LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
#OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
#WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
# From hadley rappdirs
get_os <- function() {
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
	os = get_os()
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
