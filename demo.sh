#!/bin/bash

# MB/s
bw_sender=100
bw_receiver=100

# ms
delay=0.25

hosts=3
qsize=100

dir=output_$(basename $0 ".sh")

# WARNING
if [ "$UID" != "0" ]; then
    echo "Please run as root"
    exit 0
fi

#Make directories for TCP, DCTCP
dir_dctcp_reno=dctcp
dir_tcp_reno=tcp_reno
dir_tcp_cubic=tcp_cubic

mkdir -p $dir/$dir_dctcp_reno
mkdir -p $dir/$dir_tcp_reno 
mkdir -p $dir/$dir_tcp_cubic

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
                --cca reno \
                --red_limit 1000000 \
                --red_min 30000 \
                --red_max 30001 \
                --red_avpkt 1500 \
                --red_burst 20 \
                --red_prob 1 \
                --time 15

# Measure queue occupancy, throughput, cwnd with TCP - RENO
python3 dctcp.py --hosts $hosts \
                --bw-sender $bw_sender \
                --bw-receiver $bw_receiver \
                --delay $delay \
                --dir $dir/$dir_tcp_reno \
                --maxq $qsize \
                --cca reno \
                --time 15

# Measure queue occupancy, throughput, cwnd with TCP - CUBIC
python3 dctcp.py --hosts $hosts \
                --bw-sender $bw_sender \
                --bw-receiver $bw_receiver \
                --delay $delay \
                --dir $dir/$dir_tcp_cubic \
                --maxq $qsize \
                --cca cubic \
                --time 15


python mininetutil/plot_queue.py -f $dir/$dir_dctcp_reno/q.txt $dir/$dir_tcp_reno/q.txt $dir/$dir_tcp_cubic/q.txt --legend DCTCP TCP-RENO TCP-CUBIC -o $dir/q_$hosts.png
python mininetutil/plot_queue.py -f $dir/$dir_dctcp_reno/q.txt $dir/$dir_tcp_reno/q.txt $dir/$dir_tcp_cubic/q.txt --legend DCTCP TCP-RENO TCP-CUBIC -o $dir/q_cdf_$hosts.png --cdf
