#!/bin/bash
#SBATCH -J JOBNAME             # job name
#SBATCH -o logs/JOBNAME.%j.out # stdout (%j = job ID; mkdir -p logs first)
#SBATCH -e logs/JOBNAME.%j.err # stderr
#SBATCH -p gh                  # GPU queue
#SBATCH -N 4                   # nodes -> 4 nodes = 4 H200 GPUs (1 GPU per node on Vista)
#SBATCH -n 4                   # one task per node; torchrun spawns the per-GPU procs
#SBATCH -t 04:00:00            # wall time hh:mm:ss (max 48:00:00)
#SBATCH -A <YOUR_ALLOCATION>   # TACC allocation (facilitator gives you this; or run `taccinfo`)
##SBATCH --mail-user=YOUR_EMAIL
##SBATCH --mail-type=END,FAIL

# Multi-GPU on Vista = multi-node (each gh node has exactly one H200).
# This follows the Vista ML docs: torchrun per node, launched across nodes
# with mpirun --map-by ppr:1:node (the documented exception to "always ibrun").

set -euo pipefail

module reset
module load gcc cuda python3
source $SCRATCH/envs/YOUR_ENV/bin/activate

echo "Host: $(hostname)   Started: $(date)   Nodes: $SLURM_NNODES"

# Master node = first node in the allocation; pick a free port.
MASTER_ADDR=$(scontrol show hostnames "$SLURM_JOB_NODELIST" | head -n1)
MASTER_PORT=29500
NPROC_PER_NODE=1                       # 1 GPU per node

# run.sh wraps torchrun so each node gets the right node_rank via OMPI rank.
cat > run.sh <<'EOF'
#!/bin/bash
NODE_RANK=${OMPI_COMM_WORLD_RANK}
torchrun \
  --nproc_per_node=1 \
  --nnodes=${SLURM_NNODES} \
  --node_rank=${NODE_RANK} \
  --master_addr=${MASTER_ADDR} \
  --master_port=${MASTER_PORT} \
  scripts/train_ddp.py
EOF
chmod +x run.sh
export MASTER_ADDR MASTER_PORT SLURM_NNODES

# One launcher process per node.
mpirun -np "$SLURM_NNODES" --map-by ppr:1:node ./run.sh

echo "Finished: $(date)"
