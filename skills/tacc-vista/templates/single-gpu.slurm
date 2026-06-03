#!/bin/bash
#SBATCH -J JOBNAME             # job name
#SBATCH -o logs/JOBNAME.%j.out # stdout (%j = job ID; mkdir -p logs first)
#SBATCH -e logs/JOBNAME.%j.err # stderr
#SBATCH -p gh                  # GPU queue (1 H200 per node). Use gh-dev for a <2hr test.
#SBATCH -N 1                   # nodes  -> 1 node = 1 GPU on Vista
#SBATCH -n 1                   # tasks
#SBATCH -t 02:00:00            # wall time hh:mm:ss (max 48:00:00 on gh)
#SBATCH -A <YOUR_ALLOCATION>   # TACC allocation (facilitator gives you this; or run `taccinfo`)
##SBATCH --mail-user=YOUR_EMAIL   # uncomment + set to get notified
##SBATCH --mail-type=END,FAIL     # when to notify

set -euo pipefail

# --- environment ---------------------------------------------------------
module reset
module load gcc cuda python3           # match what you built/installed with
source $SCRATCH/envs/YOUR_ENV/bin/activate   # your venv (build it on $SCRATCH or $WORK)

# --- sanity check --------------------------------------------------------
echo "Host: $(hostname)   Started: $(date)"
nvidia-smi || true
python3 -c "import torch; print('CUDA available:', torch.cuda.is_available())"

# --- run -----------------------------------------------------------------
# Reads inputs from $SCRATCH, writes results back to $SCRATCH (not $HOME).
python3 scripts/train.py

echo "Finished: $(date)"
