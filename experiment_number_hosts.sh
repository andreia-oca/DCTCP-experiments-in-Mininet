#!/bin/bash

# MB/s
bw_sender=100
bw_receiver=100

# ms
delay=0.25

qsize=150

dir=output_$(basename $0 ".sh")

# WARNING
if [ "$UID" != "0" ]; then
    echo "Please run as root"
    exit 0
fi

for hosts in 3 5 10 20 50 100
do
    #Make directories for TCP, DCTCP
    dir_dctcp_reno=dctcp_$hosts
    dir_tcp_reno=tcp_reno_$hosts
    dir_tcp_cubic=tcp_cubic_$hosts

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
                    --red_prob 1

    # Measure queue occupancy, throughput, cwnd with TCP - Reno
    python3 dctcp.py --hosts $hosts \
                    --bw-sender $bw_sender \
                    --bw-receiver $bw_receiver \
                    --delay $delay \
                    --dir $dir/$dir_tcp_reno \
                    --maxq $qsize \
                    --cca reno

    # Measure queue occupancy, throughput, cwnd with TCP - CUBIC
    python3 dctcp.py --hosts $hosts \
                    --bw-sender $bw_sender \
                    --bw-receiver $bw_receiver \
                    --delay $delay \
                    --dir $dir/$dir_tcp_cubic \
                    --maxq $qsize \
                    --cca cubic
    
    python mininetutil/plot_queue.py -f $dir/$dir_dctcp_reno/q.txt $dir/$dir_tcp_reno/q.txt $dir/$dir_tcp_cubic/q.txt --legend DCTCP TCP-RENO TCP-CUBIC -o $dir/q_$hosts.png
done
