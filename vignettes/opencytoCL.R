## ----eval=FALSE,echo=TRUE------------------------------------------------
#  library(devtools)
#  install_github("RGLab/opencytoCL")

## ---- eval=FALSE,results="asis"------------------------------------------
#  install_openCytoCL()

## ------------------------------------------------------------------------
if(!library(flowWorkspaceData,logical.return = TRUE)){
		source("https://bioconductor.org/biocLite.R")
		biocLite("flowWorkspaceData")
}

## ----echo=FALSE----------------------------------------------------------
fcs_path = system.file(package="flowWorkspaceData","extdata")
tmp = tempdir()
file.copy(list.files(path=fcs_path,pattern="CytoTrol.*",full=TRUE),to = tmp)

system(paste0("opencyto process ",tmp,"  /tmp/cytotrol --compensate --transform --annotate='$FIL'"))

