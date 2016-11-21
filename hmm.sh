echo "Running HMMs from engine $1..."
date
#R --no-save << EOF > hmm_logs/$1.log 2>&1
rm -fr hmm_logs/*
R --no-save << EOF 
ls()

library(HMM)


hmm_file=as.list(read.table("hmm_list_$1.lst"))
hmm_list=as.character(hmm_file[[1]])
for (i in 1:length(hmm_list)) {

try( {

tProbs = as.matrix(read.table(paste("matrix_files/t", hmm_list[[i]], ".lst", sep="")))
eProbs = as.matrix(read.table(paste("matrix_files_$1/e", hmm_list[[i]], ".lst", sep="")))
sProbs = as.matrix(read.table(paste("matrix_files/s", hmm_list[[i]], ".lst", sep="")))
HMM = initHMM(c("D", "N", "U"), c("N", "Y"), transProbs=tProbs, emissionProbs=eProbs, startProbs=sProbs)
HMM

t=as.list(read.table(paste("obsmatrix_files_$1/o", hmm_list[[i]], ".lst", sep="")))
obs5=as.character(t[[1]])
obs5


#bwObs=as.character(read.table(paste("matrix_files_$1/o", hmm_list[[i]], ".lst", sep=""))[[1]])

#bwHMM=baumWelch(HMM, bwObs, maxIterations=20)

e=exp(forward(HMM, obs5))
p=posterior(HMM, obs5)

#e=exp(forward(bwHMM\$hmm, obs5))
#p=posterior(bwHMM\$hmm, obs5)

write(e, file=paste("hmm_logs_$1/", hmm_list[[i]], ".log", sep=""), ncolumns=3, append=TRUE)
write(p, file=paste("hmm_logs_$1/", hmm_list[[i]], ".log", sep=""), ncolumns=3, append=TRUE)
 
})

}

quit()
EOF
echo "Finished HMMs from engine $1"
date
