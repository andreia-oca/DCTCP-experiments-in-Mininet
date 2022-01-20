#!/bin/bash

# MB/s
bw_sender=100
bw_receiver=100

# ms
delay=0.25

hosts=3
qsize=150

dir=output_$(basename $0 ".sh")

# WARNING
if [ "$UID" != "0" ]; then
    echo "Please run as root"
    exit 0
fi

#Make directories for TCP, DCTCP
dir_dctcp_reno=dctcp_reno
dir_dctcp_cubic=dctcp_cubic
dir_tcp=tcp

mkdir -p $dir/$dir_dctcp_cubic
mkdir -p $dir/$dir_dctcp_reno
mkdir -p $dir/$dir_tcp 

# Measure queue occupancy, throughput, cwnd with DCTCP - RENO
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

# Measure queue occupancy, throughput, cwnd with DCTCP - Cubic
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

# Measure queue occupancy, throughput, cwnd with TCP
python3 dctcp.py --hosts $hosts \
                --bw-sender $bw_sender \
                --bw-receiver $bw_receiver \
                --delay $delay \
                --dir $dir/$dir_tcp \
                --maxq $qsize \
                --cca reno
