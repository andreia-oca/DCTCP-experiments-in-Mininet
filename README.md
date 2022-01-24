# DCTCP-experiments-in-Mininet

## Experiments description
Comparison between:
 
 - TCP-Reno
 - DCTCP-Renp
 - DCTCP-Cubic

Aspects that are interesting to analyze:

 - Queue Occupancy
 - Throughput 
 - Congestion window length (to compare Reno and Cubic)

Parameters interesting to vary:
 
 - the link bandwidth (100 Mbps, 1Gbps, 10 Gpbs)
 - queries length (2 Kb, 20 Kb, 100Kb, 1 Mb, 10 Mb, 100Mb)
 - K - ECN threshold (5 20 65 80 100) (packets)
 - the number of hosts (3, 5, 10, 20, 100) 

***Note***: The queue length will be constant 150 packets.

***Note***: Mininet supports bandwidth up to 1000 Mbps.

***Note***: TCP - CUBIC and TCp - Reno are not stable using a bandwidth greater than 100 Mbps.

## Demo commands

```
sudo ./demo.py

sudo python mininetutil/plot_queue.py -f output_demo/dctcp/q.txt output_demo/tcp_reno/q.txt output_demo/tcp_cubic/q.txt --legend DCTCP TCP-RENO TCP-CUBIC -o output_demo/q.png

sudo python mininetutil/plot_queue.py -f output_demo/dctcp/q.txt output_demo/tcp_reno/q.txt output_demo/tcp_cubic/q.txt --legend DCTCP TCP-RENO TCP-CUBIC -o output_demo/q_cdf.png --cdf
```

## Plot the data
Use the scripts from `./mininetutil/`. For now, their are designed to use with `python2`.

Examples:
```
sudo python mininetutil/plot_queue.py -f output_experiment_baseline/dctcp/q.txt output_experiment_baseline/tcp_reno/q.txt output_experiment_baseline/tcp_cubic/q.txt --legend DCTCP TCP-RENO TCP-CUBIC -o output_experiment_baseline/q.png

sudo python mininetutil/plot_queue.py -f output_experiment_baseline/dctcp/q.txt output_experiment_baseline/tcp_reno/q.txt output_experiment_baseline/tcp_cubic/q.txt --legend DCTCP TCP-RENO TCP-CUBIC -o output_experiment_baseline/q_cdf.png --cdf
```

## References
Papers and articles:
 - [Mininet documentation](https://github.com/mininet/mininet/wiki/Documentation);
 - [DCTCP paper](https://people.csail.mit.edu/alizadeh/papers/dctcp-sigcomm10.pdf);
 - [DCTCP RFC](https://datatracker.ietf.org/doc/html/rfc8257);
 - [Cubic paper](https://www.cs.princeton.edu/courses/archive/fall16/cos561/papers/Cubic08.pdf);
 - [RED explained](https://en.wikipedia.org/wiki/Random_early_detection);
 - [CCA explained](https://en.wikipedia.org/wiki/TCP_congestion_control);
 - [On the Fairness of DCTCP and CUBIC in Cloud Data Center Networks](https://ieeexplore.ieee.org/document/9493352);
 - [Stanford CS244 course](https://web.stanford.edu/class/cs244/);
 - [Stanford CS244 projects](https://reproducingnetworkresearch.wordpress.com/);

Code mainly inspired from the following sources:
 - [CS244 project](https://github.com/karimmd/dctcp-mininet);
 - [Mininet/tests](https://github.com/mininet/mininet-tests);
 - [Mininet/util](https://github.com/mininet/mininet-tests);
