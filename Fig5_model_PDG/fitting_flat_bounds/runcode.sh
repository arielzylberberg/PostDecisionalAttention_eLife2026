#!/bin/sh
#
# Simple Matlab submit script for Slurm.
#
#
#SBATCH -A zims                # The account name for the job.
#SBATCH -J ATT_DTB_VBD           # The job name.
#SBATCH -t 1800:00                  # The time the job will take to run.
#SBATCH --mem-per-cpu=4gb        # The memory the job will use per cpu core.
#SBATCH -c 24 # number of cores

module load matlab

echo "Launching an Matlab run"
date


#Command to execute Matlab code
matlab -nosplash -nodisplay -nodesktop -r "main()" # > matoutfile

# End of script
