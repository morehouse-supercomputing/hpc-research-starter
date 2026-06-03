#!/bin/bash
#SBATCH -J JOBNAME             # job name
#SBATCH -o logs/JOBNAME.%j.out # stdout (%j = job ID; mkdir -p logs first)
#SBATCH -e logs/JOBNAME.%j.err # stderr
#SBATCH -p gg                  # CPU queue (Grace-Grace, 144 cores/node)
#SBATCH -N 2                   # nodes
#SBATCH -n 288                 # total MPI tasks (here 144 per node x 2 nodes)
#SBATCH -t 01:00:00            # wall time hh:mm:ss (max 48:00:00 on gg)
#SBATCH -A <YOUR_ALLOCATION>   # TACC allocation (facilitator gives you this; or run `taccinfo`)
##SBATCH --mail-user=YOUR_EMAIL
##SBATCH --mail-type=END,FAIL

set -euo pipefail

module reset
module load gcc                # add your MPI stack, e.g. `module load openmpi` if needed

echo "Host: $(hostname)   Started: $(date)"

# --- choose ONE launch style ---------------------------------------------

# (a) Pure MPI: launch with ibrun (NOT mpirun/srun). ibrun reads -N/-n above.
ibrun ./myprogram

# (b) Pure OpenMP on a single node (set -N 1, -n 1 above): uncomment these,
#     comment out the ibrun line, and keep threads <= 144.
# export OMP_NUM_THREADS=144
# ./myprogram

# (c) Hybrid MPI + OpenMP: set threads, then ibrun. Keep
#     OMP_NUM_THREADS x (tasks per node) <= 144.
# export OMP_NUM_THREADS=8
# ibrun ./myprogram

echo "Finished: $(date)"
