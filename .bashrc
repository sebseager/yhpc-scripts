#######################
### Setup & options ###
#######################

# source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# no core dumps
ulimit -S -c 0

###########################
### Aliases & Variables ###
###########################

# interactive node requests (partition names may differ)
alias srun-cpu="srun --x11 -p interactive --pty bash"
alias srun-cpu8="srun --x11 -p interactive --mem=8G --pty bash"
alias srun-cpu16="srun --x11 -p interactive --mem=16G --pty bash"
alias srun-gpu="srun --x11 -p gpu --gres=gpu:1 --pty bash"
alias srun-gpu8="srun --x11 -p gpu --mem=8G --gres=gpu:1 --pty bash"
alias srun-gpu16="srun --x11 -p gpu --mem=16G --gres=gpu:1 --pty bash"

# grab user entries from slurm queue
alias slq="squeue | grep <USER_ID>"

# more helpful sacct output
alias sla="sacct --format jobid,jobname,partition,allocnodes,elapsed,timelimit,usercpu,reqmem,state,priority,exitcode"

# blank slurm batch header (useful for echoing out to a file to start a new sbatch script)
read -d '' blank_sbatch << EOF
#!/bin/bash
#SBATCH --job-name=
#SBATCH --ntasks=
#SBATCH --nodes=
#SBATCH --partition=
#SBATCH --mem=
#SBATCH --time=
#SBATCH --gres=gpu:
#SBATCH --output=slurm-%j.out
#SBATCH --mail-type=NONE
EOF

#################
### Functions ###
#################

# give disk usage (in MB) for the given folder
usage() {
    if [ "$#" -eq 0 ]; then
        du -hm | sort -nr | less
    else
        du -hm $1 | sort -nr | less
    fi
}

# 'up 3' can be used instead of cd ../../../
up() {
    cd $(eval printf '../'%.0s {1..$1}) && pwd -P
}

# get SLurm Output by Job number (assuming slurm-%j.out naming)
# e.g. sloj ####### tail -n 20
sloj() {
    if [ "$#" -eq 1 ]; then
        find ~ -name slurm-$1.out -type f
    else
        find ~ -name slurm-$1.out -type f -exec "${@:2}" {} \;
    fi
}

# get SLurm Output by most recent job matching Name (assuming slurm-%j.out naming)
# e.g. sloj YOUR_JOB_NAME cat
slon() {
    job_list=$(sacct --name=bash --format=jobname,jobid --parsable2 --noheader)
    job_num=$(echo "$job_list" | grep -o "$1.*" | tail -n 1 | cut -d "|" -f 2 | cut -d "." -f 1)
    sloj $job_num "${@:2}"
}

# update modification date on any scratch directory files that will be deleted
touch-todelete() {
    echo "Files in scratch60/todelete/${UID}: $(cat /gpfs/ysm/scratch60/todelete/${UID} | wc -l)"
    echo "Working..."
    cat /gpfs/ysm/scratch60/todelete/${UID} | xargs -n 1 -I {} touch {}
    echo "Done."
}

# replace the extensions of files in the args 2-n with the extension in arg 1
replace-ext() {
    # we need at least two args
    if [ $# -lt 2 ]; then
        echo "usage: replace-ext .new_ext files..."
        exit 1
    fi

    new_ext="$1"
    shift  # $2 is now first argument, and first is gone

    # do replace
    for f in "$@"; do
        mv $f ${f%.*}"$new_ext"
    done
}

###########################
### Personal preference ###
###########################

# colors
alias ls="ls --color=auto"
alias grep="grep --color=auto"

### conda initialization script goes here, if applicable ###
