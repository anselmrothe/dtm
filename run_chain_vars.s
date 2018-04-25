#!/bin/bash

#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --time=36:00:00
#SBATCH --mem=2GB
#SBATCH --job-name=myTest
#SBATCH --mail-type=END
#SBATCH --mail-user=asr443@nyu.edu
#SBATCH --output=slurm_%j.out
#SBATCH --array=0,1,2,3,4

module load gsl/intel/2.3

RUNDIR=$SCRATCH/dtmproject/run-${SLURM_JOB_ID/.*}
mkdir $RUNDIR

cd $RUNDIR

mkdir dtm_out
mkdir dtm_input_data


vars=(0.0001 0.0003 0.001 0.003 0.01)

v=${vars[$SLURM_ARRAY_TASK_ID]}


cp -r /home/asr443/groupproject/lda_upto_17 dtm_out/
cp /home/asr443/groupproject/dtm_input_data/dtm_input_incl_17-mult.dat dtm_input_data/
cp /home/asr443/groupproject/dtm_input_data/dtm_input_incl_17-seq.dat dtm_input_data/

/home/asr443/dtm/dtm/main \
    --ntopics=20 \
    --mode=fit \
    --initialize_lda=false \
    --lda_SS_folder=dtm_out/lda_upto_17 \
    --corpus_prefix=dtm_input_data/dtm_input_incl_17 \
    --outname=dtm_out/dtm_var$v \
    --top_chain_var=$v \
    --alpha=0.05 \
    --top_obs_var=.05 \
    --lda_sequence_min_iter=6 \
    --lda_sequence_max_iter=150 \
    --min_time=0 \
    --heldout_time=17

