#####################################################################
#                                                                   #
#                   Failover Withouth Scripts                       #
#                                                                   #
#####################################################################
#                      Global Vars                                  #
# Gateway ISP 1 and 2
:global Gateway1 "192.168.0.1"
:global Gateway2 "11.11.11.1"
# Host 1 (Any IP, Used OpenDNS)
:global Host1 "208.67.222.222"
# Host 1 (Any IP, Used OpenDNS)
:global Host2 "208.67.220.220"
## Show Message
:global Msg "Ok"
#####################################################################
/ip route
add dst-address=0.0.0.0/0 gateway=$Gateway1 distance=1 \
check-gateway=ping
add dst-address=0.0.0.0/0 gateway=$Gateway2 distance=2

/ip route
add dst-address=$Host1 gateway=$Gateway1 scope=10
add dst-address=$Host2 gateway=$Gateway2 scope=10

/ip route
add distance=1 gateway=$Host1 routing-mark=ISP1 check-gateway=ping
add distance=2 gateway=$Host2 routing-mark=ISP1 check-gateway=ping

/ip route
add distance=1 gateway=$Host1 routing-mark=ISP2 check-gateway=ping
add distance=2 gateway=$Host2 routing-mark=ISP2 check-gateway=ping

/ip route
add dst-address=$Host1 type=blackhole distance=20
add dst-address=$Host2 type=blackhole distance=20
