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
#SBATCH --array=2-17

module load gsl/intel/2.3

RUNDIR=$SCRATCH/dtmproject/run-${SLURM_JOB_ID/.*}
mkdir $RUNDIR

cd $RUNDIR

mkdir dtm_out
mkdir dtm_input_data

y=$SLURM_ARRAY_TASK_ID


cp /home/asr443/groupproject/dtm_input_data/dtm_input_prev_$y-mult.dat dtm_input_data/
cp /home/asr443/groupproject/dtm_input_data/dtm_input_previncl_$y-mult.dat dtm_input_data/
cp /home/asr443/groupproject/dtm_input_data/dtm_input_previncl_$y-seq.dat dtm_input_data/


/home/asr443/dtm/dtm/main \
    --ntopics=20  \
    --mode=fit   \
    --initialize_lda=true   \
    --corpus_prefix=dtm_input_data/dtm_input_previncl_$y   \
    --initialize_lda_data=dtm_input_data/dtm_input_prev_$y \
    --skip_dtm=true \
    --outname=dtm_out/lda_prev_$y   \
    --top_chain_var=0.001   \
    --alpha=0.05   \
    --lda_sequence_min_iter=6   \
    --lda_sequence_max_iter=150   \
    --lda_max_em_iter=150 \
    --min_time=0 \
    --heldout_time=1

