#!/bin/bash
# based on a script by Christopher JF Cameron


# SETUP

mkdir -p ~/jupyter/logs  # create log directory

# Jupyter environment via virtualenv
# virtualenv ~/jupyter_env --python=python3
# activate=~/venv_default/bin/activate

# Jupyter environment via conda
conda create -yn jupyter_env python=3.8
activate=`which activate`


# SLURM

# create SLURM job sumission to run Jupyter server
# https://docs.ycrc.yale.edu/clusters-at-yale/guides/jupyter/
home_dir=`readlink -f ~`

# contents of jupyter_server.sh
echo "#!/bin/sh
#SBATCH --partition pi_gerstein
#SBATCH --nodes 1
#SBATCH --ntasks-per-node 1
#SBATCH --mem-per-cpu 12G
#SBATCH --time 12:00:00
#SBATCH --job-name jupyter-notebook
#SBATCH --output ${home_dir}/jupyter/logs/jupyter-notebook-%J.log

# get tunneling info
XDG_RUNTIME_DIR=\"\"
port=\$(shuf -i8000-9999 -n1)
node=\$(hostname -s)
user=\$(whoami)
cluster=\$(hostname -f | awk -F'.' '{print \$2}')

# print tunneling instructions jupyter-log
echo -e \"
For more info and how to connect from Windows, 
    see https://docs.ycrc.yale.edu/clusters-at-yale/guides/jupyter/
On macOS or Linux, create ssh tunnel with
    ssh -N -L \${port}:\${node}:\${port} \${user}@\${cluster}.hpc.yale.edu
Use a Browser on your local machine to go to:
    localhost:\${port}  (prefix w/ https:// if using password)
\"

source $activate jupyter_env
jupyter-notebook --no-browser --port=\${port} --ip=\${node}
" > ~/jupyter/jupyter_server.sh

# submit SLURM job
rm -f ~/jupyter/logs/*.log
sbatch ~/jupyter/jupyter_server.sh

# get tunnel commands
echo "Submitted job. To check logs, run:
    ls -d ~/jupyter/logs/*.log | tail -n 1 | xargs -n 1 -I {} cat {}
"