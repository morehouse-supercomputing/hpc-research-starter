# Vista queues, nodes, filesystems, and charging

Authoritative values from the TACC Vista User Guide (docs.tacc.utexas.edu/hpc/vista). Queue limits change without notice; the live source of truth on the system is the `qlimits` command. If a number here ever conflicts with `qlimits`, trust `qlimits` and update this file.

## Production queues (Table 4)

| Queue    | Node type   | Max nodes / job        | Max wall time | Max nodes / user | Max jobs / user | Max submit | Charge (SU / node-hr) |
|----------|-------------|------------------------|---------------|------------------|-----------------|------------|-----------------------|
| `gg`     | Grace-Grace | 32 (4608 cores)        | 48:00:00      | 128              | 20              | 40         | 0.33                  |
| `gh`     | Grace-Hopper| 64 (4608 cores/64 GPU) | 48:00:00      | 192              | 20              | 40         | 1.0                   |
| `gh-dev` | Grace-Hopper| 8 (576 cores)          | 02:00:00      | 8                | 1               | 3          | 1.0                   |

- `gh-dev` is for short tests and interactive development: only **one running job at a time**, **2-hour cap**. Use it to debug before scaling up on `gh`.
- The absolute max wall time for any single job is 48 hours. For longer work, checkpoint and chain jobs with a dependency (`#SBATCH -d afterok:<jobid>`).

## Node specifications

### Grace-Hopper (GH) node — the GPU node (`gh`, `gh-dev`)
- **1 × NVIDIA H200 GPU**, 96 GB HBM3
- 1 × NVIDIA Grace CPU, **72 cores**, one socket, 3.1 GHz, 1 thread/core
- 116 GB LPDDR5 CPU memory
- 286 GB local `/tmp`
- 600 of these nodes on Vista
- **One GPU per node.** Multi-GPU work is inherently multi-node here.

### Grace-Grace (GG) node — the CPU node (`gg`)
- CPU only: 2 × Grace = **144 cores** (2 sockets × 72), 3.4 GHz, 1 thread/core
- 237 GB LPDDR5 memory
- 286 GB local `/tmp`
- 256 of these nodes; login nodes are also GG (144 cores)

### Core-count budgeting
`OMP_NUM_THREADS` × (MPI ranks per node) should not exceed cores per node: **144 on `gg`, 72 on `gh`**. Default `OMP_NUM_THREADS` is 1, so set it explicitly for threaded code.

## Filesystems (Table 3)

| Path       | Type   | Quota                | Backup | Purge            | Use for                                   |
|------------|--------|----------------------|--------|------------------|-------------------------------------------|
| `$HOME`    | VAST   | 23 GB, 500k files    | Yes    | Never            | Code, scripts, small configs              |
| `$WORK`    | Lustre | 1 TB, 3M files*      | No     | Never            | Datasets, shared inputs, installed envs   |
| `$SCRATCH` | VAST   | none (~10 PB shared) | No     | **10 days idle** | Job outputs, large intermediates, models  |

*`$WORK` quota is shared across all TACC systems (Stockyard). `$WORK` is the only Lustre filesystem (so `lfs` commands apply there); `$HOME` and `$SCRATCH` are VAST and do **not** support stripe settings.

Purge rule: a file in `$SCRATCH` is eligible for purge if its access time is older than 10 days. Reading/executing it on a compute node updates access time; doing so on a login node does not. Deliberately touching files to dodge purge is prohibited.

## SU charging

```
SUs = (number of nodes) x (wall-clock hours) x (charge rate)
```

- Charge rates: `gg` 0.33, `gh` 1.0, `gh-dev` 1.0 SU per node-hour.
- **Minimum 15-minute charge** per running job, regardless of actual runtime.
- Charged on whole nodes (no node sharing) and only for time actually used: a job that exits early stops accruing.
- Check balances and quotas anytime on a login node: `/usr/local/etc/taccinfo` (more current than the portal).

## SSH / connecting

```bash
ssh <taccusername>@vista.tacc.utexas.edu        # round-robins across login nodes
ssh <taccusername>@login2.vista.tacc.utexas.edu # a specific login node
ssh -X <taccusername>@vista.tacc.utexas.edu     # with X11 for GUIs
```
Do **not** run `ssh-keygen` on Vista; it breaks batch execution. (Recovery: `mv .ssh dot.ssh.old`, log out, log back in.)
