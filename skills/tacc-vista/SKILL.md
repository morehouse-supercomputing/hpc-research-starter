---
name: tacc-vista
description: Write, debug, and optimize Slurm batch scripts for TACC's Vista supercomputer (NVIDIA Grace-Hopper GPU nodes and Grace-Grace CPU nodes). Use when the user mentions Vista, TACC, sbatch, an idev session, the gh / gh-dev / gg queues, ibrun, or asks to write, fix, or review a Slurm job script that runs on Vista. Also use when porting a job script from another cluster (Frontera, Stampede3, Lonestar6) to Vista.
---

# Writing Slurm scripts for TACC Vista

Vista is TACC's Arm-based, AI-centric system. Its scheduler is Slurm, its MPI launcher is `ibrun`, and several Slurm options that work on other clusters are rejected here. Your job is to produce job scripts that run correctly the first time on Vista specifically, not generic Slurm.

This file is the router. It covers the decision (which queue, which template) and the rules that must always hold. Pull the detailed files only when the task needs them:

- **`reference/queues.md`** — authoritative queue limits, node specs, filesystems, and SU charging. Read it whenever you need a number (max nodes, wall-clock cap, cores per node, charge rate) or have to choose a queue.
- **`reference/gotchas.md`** — Vista-specific traps that silently break scripts. Read it before finalizing any script, and always when debugging one that failed.
- **`templates/`** — starting points, one per job archetype. Copy the closest one and adapt.

## The hardware in one breath

A `gh` (Grace-Hopper) node has **exactly one H200 GPU** and a 72-core Grace CPU. A `gg` (Grace-Grace) node is CPU-only with 144 cores. There is **no node sharing** on Vista: every job gets whole nodes and is charged for all cores whether or not it uses them. The practical consequence that trips people up: **more than one GPU means more than one node.** There is no single-node multi-GPU job on Vista.

## Decision tree: pick the queue and template

1. **Does the work need a GPU?**
   - No, CPU only (OpenMP, MPI, serial) → queue `gg`, template `templates/cpu-mpi.slurm`.
   - Yes → continue.
2. **Is this a short test or interactive dev (< 2 hr, <= 8 nodes)?**
   - Yes → queue `gh-dev`. For interactive work prefer `idev` over a batch script (see `reference/gotchas.md`). For a quick batch test, use `templates/single-gpu.slurm` and change `-p gh` to `-p gh-dev`.
   - No → continue.
3. **One GPU or many?**
   - One GPU → queue `gh`, 1 node, template `templates/single-gpu.slurm`. This is the most common case (PyTorch training/inference on one H200).
   - Many GPUs → queue `gh`, N nodes (1 GPU each), template `templates/multi-gpu.slurm` (torchrun / distributed).
4. **Running the same script many times over a parameter set?**
   - Add `#SBATCH --array=...` → template `templates/array.slurm`. Works on top of any queue choice above.

When in doubt about a limit, open `reference/queues.md`. Never invent a queue name or a limit.

## Core SBATCH directives (the ones every Vista script needs)

```bash
#!/bin/bash
#SBATCH -J jobname            # job name
#SBATCH -o logs/job.%j.out    # stdout  (%j = job ID; literal, not an env var)
#SBATCH -e logs/job.%j.err    # stderr
#SBATCH -p gh                 # queue: gh | gh-dev | gg
#SBATCH -N 1                  # nodes        (REQUIRED)
#SBATCH -n 1                  # total tasks
#SBATCH -t 02:00:00           # wall time hh:mm:ss   (REQUIRED)
#SBATCH -A <YOUR_ALLOCATION>  # your TACC allocation (see note below)
```

- `-N` (nodes) and `-t` (wall time) are **required**; the job is rejected without them.
- **`<YOUR_ALLOCATION>`** is the TACC project/allocation that gets charged. Use the one your workshop facilitator gives you. To see the allocations available to you on Vista, run `/usr/local/etc/taccinfo` on a login node.
- `logs/` must exist before submission (`mkdir -p logs`), or stdout/stderr writes fail silently.

## Hard rules (these are what make it Vista, not generic Slurm)

1. **First line is a bare `#!/bin/bash`.** No comment, no blank, no trailing text on that line. Avoid `#!/bin/sh` (its startup behavior breaks on Vista).
2. **MPI launches through `ibrun`,** never `mpirun`, `mpiexec`, or a raw `srun`. `ibrun` reads your `#SBATCH` `-N`/`-n` to place ranks. (Multi-node ML launchers like `torchrun` are the documented exception; see the multi-gpu template.)
3. **These options are rejected or harmful on Vista:** `--mem` (rejected outright), `--gres`, `--gpus-per-task` (unsupported), and `--export` (interferes with environment propagation; avoid it). Do not use them.
4. **In `#SBATCH` directives, use `%j` for the job ID,** not `$SLURM_JOB_ID`. Slurm replacement symbols work in directives; shell variables do not. Likewise you cannot use `$WORK` / `$SCRATCH` inside a `#SBATCH` line. Use those env vars only in the shell body.
5. **Reset modules to a known state, then load explicitly.** Start the body with `module reset`, then `module load ...`. Load the same modules used to build the code.
6. **Heavy data and outputs go to `$SCRATCH`,** not `$HOME` (23 GB, backed up, for code only). Remember `$SCRATCH` is purged after 10 days of no access; `$WORK` (Lustre, 1 TB) is the non-purged middle ground but is not backed up.
7. **GPU count = node count on `gh`.** To request 4 GPUs, request `-N 4`. Never try `--gpus=4` on one node.

## Workflow when asked to write or fix a script

1. Identify the archetype via the decision tree; copy the matching template.
2. Fill in the real command, modules, and environment activation. Replace `<YOUR_ALLOCATION>` and the `YOUR_ENV` / `JOBNAME` placeholders with the user's actual values.
3. Check it against the Hard rules above and skim `reference/gotchas.md`.
4. Sanity-check every limit (nodes, wall time, queue) against `reference/queues.md`.
5. If porting from another cluster, explicitly flag and fix non-Vista artifacts (e.g. `-p rtx`/`-p normal` queues, `mpirun`, `--gres`, `srun` launches).
