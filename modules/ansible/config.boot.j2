interfaces {
    ethernet eth0 {
        address 10.0.17.200/24
        description 480-WAN
        hw-id 00:50:56:b1:62:63
    }
    ethernet eth1 {
        address 10.0.5.2/24
        description BLUE-LAN
        hw-id 00:50:56:b1:eb:f1
    }
    loopback lo {
    }
}
nat {
    source {
        rule 10 {
            outbound-interface eth0
            source {
                address 10.0.5.0/24
            }
            translation {
                address masquerade
            }
        }
    }
}
protocols {
    static {
        route 0.0.0.0/0 {
            next-hop 10.0.17.2 {
            }
            next-hop 192.168.7.250 {
            }
        }
    }
}
service {
    dns {
        forwarding {
            allow-from 10.0.17.0/24
            allow-from 10.0.5.0/24
            listen-address 10.0.17.2
            listen-address 10.0.5.2
            system
        }
    }
    ssh {
        listen-address 0.0.0.0
    }
}
system {
    config-management {
        commit-revisions 100
    }
    conntrack {
        modules {
            ftp
            h323
            nfs
            pptp
            sip
            sqlnet
            tftp
        }
    }
    console {
        device ttyS0 {
            speed 115200
        }
    }
    host-name fw-blue1
    login {
        user vyos {
            authentication {
                encrypted-password $6$rexBgmH1CAaLQd2P$i/Tjakj1idX.LR3ZRPTWsw6hPF4IbjpYRyXXtZ9Tvaz0JudmP6u0bYL.uTAJlIiPDmz9Ph2/kaLkw2dIQoK4v0
                plaintext-password ""
            }
        }
    }
    name-server 192.168.4.4
    name-server 192.168.4.5
    name-server 10.0.17.4
    ntp {
        server time1.vyos.net {
        }
        server time2.vyos.net {
        }
        server time3.vyos.net {
        }
    }
    syslog {
        global {
            facility all {
                level info
            }
            facility protocols {
                level debug
            }
        }
    }
}


// Warning: Do not remove the following line.
// vyos-config-version: "bgp@3:broadcast-relay@1:cluster@1:config-management@1:conntrack@3:conntrack-sync@2:container@1:dhcp-relay@2:dhcp-server@6:dhcpv6-server@1:dns-forwarding@3:firewall@9:flow-accounting@1:https@4:ids@1:interfaces@26:ipoe-server@1:ipsec@10:isis@2:l2tp@4:lldp@1:mdns@1:monitoring@1:nat@5:nat66@1:ntp@1:openconnect@2:ospf@1:policy@5:pppoe-server@6:pptp@2:qos@1:quagga@10:rpki@1:salt@1:snmp@2:ssh@2:sstp@4:system@25:vrf@3:vrrp@3:vyos-accel-ppp@2:wanloadbalance@3:webproxy@2"
// Release version: 1.4-rolling-202301010411
