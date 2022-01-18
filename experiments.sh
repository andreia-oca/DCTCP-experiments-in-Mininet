#!/bin/bash

# MB/s
bw_sender=100
bw_receiver=100

# ms
delay=0.25

hosts=3
qsize=120

dir=output

# WARNING
if [ "$UID" != "0" ]; then
    warn "Please run as root"
    exit 0
fi

# Experiment 1
# Queue occupancy over time - comparing DCTCP & TCP

#Make directories for TCP, DCTCP and the comparison graph
dir_dctcp_reno=dctcp_reno_q$qsize
dir_dctcp_cubic=dctcp_cubic_q$qsize
dir_tcp=tcp_q$qsize

mkdir -p $dir/$dir_dctcp_cubic
mkdir -p $dir/$dir_dctcp_reno
mkdir -p $dir/$dir_tcp 

# Measure queue occupancy with DCTCP - RENO
# RED parameters are default see dctcp.py for details
python3 dctcp.py --hosts $hosts \
                --bw-sender $bw_sender \
                --bw-receiver $bw_receiver \
                --delay $delay \
                --dir $dir/$dir_dctcp_reno \
                --maxq $qsize \
                --red True \
                --ecn True \
                --dctcp True \
                --cca reno

python3 dctcp.py --hosts $hosts \
                --bw-sender $bw_sender \
                --bw-receiver $bw_receiver \
                --delay $delay \
                --dir $dir/$dir_dctcp_cubic \
                --maxq $qsize \
                --red True \
                --ecn True \
                --dctcp True \
                --cca cubic

# Measure queue occupancy with TCP
python3 dctcp.py --hosts $hosts \
                --bw-sender $bw_sender \
                --bw-receiver $bw_receiver \
                --delay $delay \
                --dir $dir/$dir_tcp \
                --maxq $qsize \
                --cca reno
