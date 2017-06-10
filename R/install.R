#' Install opencyto command line tools
#' @export
install_openCytoCL = function(to="/usr/local/bin"){
   path = system.file(package = "openCytoCL","extdata")
   files = list.files(path,full=TRUE)
   ind = grep("opencyto\\.R",files)
   if(length(ind)!=1){
   	stop("Something is wrong with the installation.")
   }else{
   	files = files[ind]
	cat(paste0("Installing to /usr/local/bin:\n"))
	cat(paste0("ln -s ",files," /usr/local/bin/opencyto\n"))
	command = paste0("ln -s ",files," /usr/local/bin/opencyto\n")
	system(command,)
   }
}
