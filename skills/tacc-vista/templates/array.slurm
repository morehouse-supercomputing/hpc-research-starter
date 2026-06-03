#!/bin/bash
#SBATCH -J JOBNAME                    # job name
#SBATCH -o logs/JOBNAME.%A_%a.out     # %A = array job ID, %a = task index
#SBATCH -e logs/JOBNAME.%A_%a.err
#SBATCH -p gh                         # queue (gh GPU here; use gg for CPU sweeps)
#SBATCH -N 1                          # nodes PER array task
#SBATCH -n 1                          # tasks
#SBATCH -t 02:00:00                   # wall time PER array task
#SBATCH -A <YOUR_ALLOCATION>          # TACC allocation (facilitator gives you this; or `taccinfo`)
#SBATCH --array=0-9                   # 10 tasks (indices 0..9); add %4 to cap concurrency
##SBATCH --mail-user=YOUR_EMAIL
##SBATCH --mail-type=END,FAIL

# Parameter sweep: each array task runs the same script with a different input.
# Watch the queue limits: on gh/gg max 20 jobs and 40 in submit; an array counts
# its tasks toward those. Throttle with --array=0-99%10 if needed.

set -euo pipefail

module reset
module load gcc cuda python3
source $SCRATCH/envs/YOUR_ENV/bin/activate

# Map the array index to a parameter. Two common patterns:

# (a) index straight into the script
python3 scripts/run.py --task-id "$SLURM_ARRAY_TASK_ID"

# (b) pull the Nth line from a params file (uncomment to use instead)
# PARAM=$(sed -n "$((SLURM_ARRAY_TASK_ID + 1))p" params.txt)
# python3 scripts/run.py --config "$PARAM"

echo "Task $SLURM_ARRAY_TASK_ID finished: $(date)"
