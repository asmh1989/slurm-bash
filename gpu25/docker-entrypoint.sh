#!/bin/bash

sudo service munge start
sudo slurmd -N $SLURM_NODENAME -f /public/slurm/gpu25/slurm.conf

tail -f /dev/null
