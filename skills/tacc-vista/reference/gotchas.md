# Vista gotchas: what silently breaks a job script

Read this before finalizing any script, and first when debugging one that failed or behaved oddly. These are Vista-specific; most are not problems on other clusters, which is exactly why ported scripts break.

## Directives and the shebang

- **Bare `#!/bin/bash` on line 1.** Nothing else on that line, no comment after it, and do not use `#!/bin/sh` (its startup behavior causes subtle failures on Vista). `#!/bin/bash` or `#!/bin/csh` only.
- **`%j`, not `$SLURM_JOB_ID`, inside `#SBATCH`.** Slurm replacement symbols (`%j` = job ID) are valid in directives; shell/env variables are not. `#SBATCH -o myjob.o${SLURM_JOB_ID}` does **not** work; `#SBATCH -o myjob.o%j` does.
- **No `$WORK` / `$SCRATCH` in `#SBATCH` lines.** Environment variables are not expanded in directives. Put filesystem paths in the shell body instead.
- **`-N` and `-t` are required.** A job with no node count or no wall time is rejected.
- **`logs/` directory must already exist.** If `-o logs/x.%j.out` points at a missing directory, output is lost. `mkdir -p logs` before submitting.

## Options that are rejected or harmful

| Option | What happens | Do instead |
|--------|--------------|------------|
| `--mem` | Job is rejected outright | Remove it; you get the whole node's memory (no node sharing) |
| `--gres=gpu:...` | Unsupported | Request GPUs by requesting `gh` nodes (`-N`); 1 GPU per node |
| `--gpus-per-task` | Unsupported | Same: scale with `-N` on `gh` |
| `--export` | Interferes with environment propagation | Omit it; load modules and export vars in the body |

## Launching

- **MPI uses `ibrun`,** the TACC launcher, not `mpirun` / `mpiexec` / raw `srun`. `ibrun` reads your `#SBATCH -N`/`-n` to place ranks; usually you call it with no extra placement args: `ibrun ./myprogram`.
- **OpenMP default thread count is 1.** Set `export OMP_NUM_THREADS=N` explicitly. Keep `OMP_NUM_THREADS x (ranks per node) <= cores/node` (144 on `gg`, 72 on `gh`).
- **Multiple concurrent OpenMP apps on one node** need pinning: `numactl -C <core-range> ./app &` per app, then `wait`.
- **Do not launch compute on login nodes.** Use a batch job or an `idev` session.

## GPU realities

- **One H200 per `gh` node.** Multi-GPU = multi-node. There is no `--gpus=4` single-node job.
- **Multi-node ML** (PyTorch DDP, Accelerate) is the one place a non-`ibrun` launcher is expected: `torchrun` driven across nodes via `mpirun --map-by ppr:1:node ...` per the Vista ML docs. See `templates/multi-gpu.slurm`.
- **MPS (Multi-Process Service)** lets several processes share one GPU when a single process cannot saturate it. Set `CUDA_MPS_PIPE_DIRECTORY`/`CUDA_MPS_LOG_DIRECTORY` (under `/tmp` or a real filesystem), start the daemon once per node with `ibrun -np $SLURM_NNODES nvidia-cuda-mps-control -d` (force `TACC_TASKS_PER_NODE=1` around it), then run the CUDA app. Only worth it for fine-grained or underutilizing GPU workloads.

## Environment and modules

- **`module reset` first**, then `module load`. `module reset` returns you to the system baseline (equivalent to `module purge; module load TACC`), which is safer than `purge`.
- **Build and run with the same modules.** Load in the job script what you loaded to compile/install.
- **PyTorch install** (when you need your own, not the system one): inside an `idev` session on `gh-dev`, `module load gcc cuda python3`, create a venv on `$SCRATCH` or `$WORK`, then `pip3 install torch torchvision --index-url https://download.pytorch.org/whl/cu129` (CUDA 12.9 wheels). Build envs on a compute node, not a login node.
- **`module save`** after loading a working set to make it your default collection (`module restore` to reload).

## Filesystem behavior

- **`$HOME` is only 23 GB and is for code.** Never write large outputs there.
- **`$SCRATCH` purges after 10 days of no access** and is not backed up. Stage long-lived data to `$WORK` (1 TB, Lustre, not purged, also not backed up).
- **`$HOME` and `$SCRATCH` are VAST, not Lustre** — `lfs setstripe` and stripe counts only apply to `$WORK`.

## Porting checklist (from Frontera / Stampede3 / Lonestar6)

When adapting a script from another TACC cluster, fix these before it will run on Vista:
- Queue names: `rtx`, `normal`, `gpu-a100`, `skx`, `nvdimm`, etc. are **not** Vista queues. Map to `gg` / `gh` / `gh-dev`.
- Replace `mpirun`/`mpiexec`/`srun` launches with `ibrun`.
- Strip `--mem`, `--gres`, `--gpus-per-task`, `--export`.
- Re-check node core counts (Vista `gh` = 72, `gg` = 144) in any `-n` / `--ntasks-per-node` math.
- Swap module versions for Vista's Arm stack (`gcc`, `cuda`, `python3` resolve on Vista; verify with `module spider`).
