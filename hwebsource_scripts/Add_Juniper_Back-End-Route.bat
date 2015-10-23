route delete 10.0.2.0
route add 10.0.2.0 mask 255.255.255.0 10.0.1.235 -p
route add 10.12.0.0 mask 255.255.0.0 10.0.1.235 -p