#!/bin/sh
#
# Simple "Hello World" submit script for Slurm.
#
# Replace ACCOUNT with your account name before submitting.
#
#SBATCH --account=zi        # Replace ACCOUNT with your group account name
#SBATCH --job-name=HelloWorld    # The job name
#SBATCH -N 1                     # The number of nodes to request
#SBATCH -c 24                     # The number of cpu cores to use (up to 32 cores per server)
#SBATCH --time=400:00           # The time the job will take to run in D-HH:MM
#SBATCH --mem-per-cpu=3G         # The memory the job will use per cpu core

module load matlab
echo "Launching a MATLAB run"
date


#Command to execute Matlab code
matlab -nosplash -nodisplay -nodesktop -r "run_do_fit(2)" # > matoutfile

# End of script
