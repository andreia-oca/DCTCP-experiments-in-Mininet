#!/usr/bin/python3

from pandas import read_csv

from pandas import read_csv
from matplotlib import pyplot as plt 


tcp_file="output/tcp_q120/q.txt"
dctcp_reno_file="output/dctcp_reno_q120/q.txt"

tcp_series = read_csv(tcp_file, header=0, parse_dates=[0], index_col=0, squeeze=True)
dctcp_reno_series = read_csv(dctcp_reno_file, header=0, parse_dates=[0], index_col=0, squeeze=True)

plt.plot(dctcp_reno_series)
plt.plot(tcp_series)
plt.show()
