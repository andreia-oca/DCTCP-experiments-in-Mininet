#!/bin/bash

# Experiment 01 - Queue occupancy
sudo python mininetutil/plot_queue.py -f output_experiment_baseline/dctcp/q.txt output_experiment_baseline/tcp_reno/q.txt output_experiment_baseline/tcp_cubic/q.txt --legend DCTCP TCP-RENO TCP-CUBIC -o output_experiment_baseline/q.png
sudo python mininetutil/plot_queue.py -f output_experiment_baseline/dctcp/q.txt output_experiment_baseline/tcp_reno/q.txt output_experiment_baseline/tcp_cubic/q.txt --legend DCTCP TCP-RENO TCP-CUBIC -o output_experiment_baseline/q_cdf.png --cdf

# Experiment 02 - Queue occupancy (bandwidth variation)
sudo python mininetutil/plot_queue.py -f output_experiment_link_bandwidth/dctcp_100/q.txt output_experiment_link_bandwidth/tcp_reno_100/q.txt output_experiment_link_bandwidth/tcp_cubic_100/q.txt --legend DCTCP TCP-RENO TCP-CUBIC -o output_experiment_link_bandwidth/q_100.png
sudo python mininetutil/plot_queue.py -f output_experiment_link_bandwidth/dctcp_100/q.txt output_experiment_link_bandwidth/tcp_reno_100/q.txt output_experiment_link_bandwidth/tcp_cubic_100/q.txt --legend DCTCP TCP-RENO TCP-CUBIC -o output_experiment_link_bandwidth/q_100_cdf.png --cdf

sudo python mininetutil/plot_queue.py -f output_experiment_link_bandwidth/dctcp_200/q.txt output_experiment_link_bandwidth/tcp_reno_200/q.txt output_experiment_link_bandwidth/tcp_cubic_200/q.txt --legend DCTCP TCP-RENO TCP-CUBIC -o output_experiment_link_bandwidth/q_200.png
sudo python mininetutil/plot_queue.py -f output_experiment_link_bandwidth/dctcp_200/q.txt output_experiment_link_bandwidth/tcp_reno_200/q.txt output_experiment_link_bandwidth/tcp_cubic_200/q.txt --legend DCTCP TCP-RENO TCP-CUBIC -o output_experiment_link_bandwidth/q_200_cdf.png --cdf

sudo python mininetutil/plot_queue.py -f output_experiment_link_bandwidth/dctcp_500/q.txt output_experiment_link_bandwidth/tcp_reno_500/q.txt output_experiment_link_bandwidth/tcp_cubic_500/q.txt --legend DCTCP TCP-RENO TCP-CUBIC -o output_experiment_link_bandwidth/q_500.png
sudo python mininetutil/plot_queue.py -f output_experiment_link_bandwidth/dctcp_500/q.txt output_experiment_link_bandwidth/tcp_reno_500/q.txt output_experiment_link_bandwidth/tcp_cubic_500/q.txt --legend DCTCP TCP-RENO TCP-CUBIC -o output_experiment_link_bandwidth/q_500_cdf.png --cdf

sudo python mininetutil/plot_queue.py -f output_experiment_link_bandwidth/dctcp_1000/q.txt output_experiment_link_bandwidth/tcp_reno_1000/q.txt output_experiment_link_bandwidth/tcp_cubic_1000/q.txt --legend DCTCP TCP-RENO TCP-CUBIC -o output_experiment_link_bandwidth/q_1000.png
sudo python mininetutil/plot_queue.py -f output_experiment_link_bandwidth/dctcp_1000/q.txt output_experiment_link_bandwidth/tcp_reno_1000/q.txt output_experiment_link_bandwidth/tcp_cubic_1000/q.txt --legend DCTCP TCP-RENO TCP-CUBIC -o output_experiment_link_bandwidth/q_1000_cdf.png --cdf

# Experiment 03 - Queue occupancy (hosts variation)
