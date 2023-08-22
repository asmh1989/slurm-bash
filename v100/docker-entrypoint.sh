#!/bin/bash

sudo service munge start
sudo slurmd -N $SLURM_NODENAME -f /public/slurm/v100/slurm.conf

tail -f /dev/null
