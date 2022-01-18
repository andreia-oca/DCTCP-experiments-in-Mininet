#!/usr/bin/python3

from mininet.net import Mininet
from mininet.node import CPULimitedHost
from mininet.link import TCLink, TCIntf, Link
from mininet.topo import Topo
from mininet.util import dumpNodeConnections
 
from time import sleep, time
from subprocess import Popen, PIPE
from multiprocessing import Process
from argparse import ArgumentParser

from mininetutil.monitor import monitor_qlen
import os

parser = ArgumentParser(description="DCTCP experiment")

parser.add_argument('--hosts', '-n',
                    help="Number of hosts",
                    type=int,
                    default=3)

parser.add_argument('--bw-sender', '-B',
                    type=float,
                    help="Bandwidth of sender link (Mb/s)",
                    default=1000)

parser.add_argument('--bw-receiver', '-b',
                    type=float,
                    help="Bandwidth of receiver link (Mb/s)",
                    default=1000)

parser.add_argument('--delay',
                    type=float,
                    help="Link propagation delay (ms)",
                    default=1)

parser.add_argument('--dir', '-d',
                    help="Directory to store outputs",
                    default="output")

parser.add_argument('--maxq',
                    type=int,
                    help="Max buffer size of network interface in packets",
                    default=100)

parser.add_argument('--time', '-t',
                    help="Duration (sec) to run the experiment",
                    type=int,
                    default=10)

parser.add_argument('--red',
                    help="Enable RED, by default is disabled",
                    type=bool,
                    default=False)

parser.add_argument('--ecn',
                    type=bool,
                    help="Enable ECN, by default is disabled",
                    default=False)

parser.add_argument('--dctcp',
                    type=bool,
                    help="Enable DCTCP, by default is disabled",
                    default=False)

parser.add_argument('--cca',
                    help="Congestion control algorithm to use (e.g. reno, cubic)",
                    default="reno")

# RED (random early drop) Parameters 
# Parameters to config the behaviour of the switch 
parser.add_argument('--red_limit',
                    help="RED buffer max limit",
                    default="1000000")

parser.add_argument('--red_min',
                    help="RED min marking threshold",
                    default="20000")

parser.add_argument('--red_max',
                    help="RED max marking threshold",
                    default="25000")

parser.add_argument('--red_avpkt',
                    help="RED average packet size",
                    default="1000")

parser.add_argument('--red_burst',
                    help="RED burst size",
                    default="20")

parser.add_argument('--red_prob',
                    help="RED marking probability",
                    default="1")

args = parser.parse_args()

# The topology is a start topology:
# 1 switch, host 0 is the receiver and the rest (n-1) hosts are the senders
#             h0
#             |
#             sw
# ------------|--------
# |   |               |
# h1  h2              h_n-1
class DCTopo(Topo):
    "Simple topology for DCTCP experiment."

    def __init__(self, n=3):
        # Initialiaze topology
        super(DCTopo, self).__init__()
        self.red_params = { 'min':args.red_min,
                            'max':args.red_max,
                            'avpkt':args.red_avpkt,
                            'burst':args.red_burst,
                            'prob':args.red_prob,
                            'limit':args.red_limit,
                           }

        # Configuration of sender, receiver and switch
        sender_config   = { 'bw':args.bw_sender,
                            'delay':args.delay,
                            'max_queue_size':args.maxq}

        receiver_config = { 'bw':args.bw_receiver,
                            'delay':args.delay,
                            'max_queue_size':args.maxq}

        switch_config   = { 'enable_ecn': args.ecn,
                            'enable_red': args.red,
                            'red_params': self.red_params if args.ecn is 1 else None,
                            'bw':args.bw_receiver,
                            'delay':0,
                            'max_queue_size':args.maxq}

        # Adding senders
        for i in range(n):
            self.addHost('h%d' % i)
        # Adding switch
        switch = self.addSwitch('s0')

        # Adding link from switch to receiver
        self.addLink('h0', switch, cls=Link, cls1=TCIntf, cls2=TCIntf, params1=receiver_config, params2=switch_config)

        # Adding links from the switch to the senders (hosts)
        for i in range(1,n):
            self.addLink('h%d' % i, switch, params=sender_config)

        return

def dctcp():
    # Configure CCA (RENO or CUBIC)
    os.system("sudo sysctl -w net.ipv4.tcp_congestion_control=%s" % args.cca)

    if (args.dctcp):
        enableDCTCP()
    else:
        disableDCTCP()

    topology = DCTopo(n=args.hosts)
    network = Mininet(topo=topology, host=CPULimitedHost, link=TCLink)
    network.start()

    print("Print host connections:")
    dumpNodeConnections(network.hosts)

    print("Test all connections in the network:")
    network.pingAll()

    # TODO Add Experiments
    start_iperf(network)
    sleep(30)
    
    # Start the monitoring processes
    
    # Monitor the congestion window (it should resize according to 
    # the CCA used RENO or CUBIC)
    start_tcpprobe()

    # Start monitoring the queue size.
    # The interface that I am monitoring is the one between the switch and the receiver 
    qmon = start_qmon(iface='s0-eth1', outfile='%s/q.txt' % (args.dir))

    start_time = time()
    while True:
        now = time()
        delta = now - start_time
        if delta > args.time:
            break

    stop_tcpprobe()
    qmon.terminate()
    network.stop()

# tcp_probe is a kernel module which records the congestion window (cwnd)) over time. 
# In linux OS >= 4.16 it has been replaced by the tcp:tcp_probe kernel tracepoint.
def start_tcpprobe(outfile="cwnd.txt"):
    os.system("echo -n 1 | sudo tee /sys/kernel/debug/tracing/events/tcp/tcp_probe/enable")
    Popen("sudo cat /sys/kernel/debug/tracing/events/tcp/tcp_probe/trace > %s/%s" % (args.dir, outfile),shell=True)

def stop_tcpprobe():
    os.system("echo -n 0 | sudo tee /sys/kernel/debug/tracing/events/tcp/tcp_probe/enable")
    Popen("killall -9 cat", shell=True).wait()

def start_iperf(net):
    receiver = net.get('h0')
    print("Starting iperf server")

    # Starting iperf in server mode with a window size of 16Mb
    server = receiver.popen("iperf -s -w 16m")

    for i in range(1,args.hosts):
        h = net.get('h%s' % i)
        print("Starting iperf sender h%d"%i)
        # long lived TCP flow from clients to server at h0.
        client = h.popen("iperf -c %s -p 5001 -t 3600" % (receiver.IP()), shell=True)
    return


def start_qmon(iface, interval_sec=0.001, outfile="q.txt"):
    monitor = Process(target=monitor_qlen, args=(iface, interval_sec, outfile))
    monitor.start()
    return monitor

# Enable DCTCP and ECN
def enableDCTCP():
    os.system("sudo sysctl -w net.ipv4.tcp_ecn=1")
    # os.system("sudo sysctl -w net.ipv4.tcp_dctcp_enable=1")

# Disacble DCTCP and ECN
def disableDCTCP():
    os.system("sudo sysctl -w net.ipv4.tcp_ecn=0")
    # os.system("sudo sysctl -w net.ipv4.tcp_dctcp_enable=0")

if __name__ == "__main__":
    if not os.path.exists(args.dir):
        os.makedirs(args.dir)

    dctcp()
