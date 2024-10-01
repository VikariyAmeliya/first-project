#!/bin/bash


# Help function
function show_help {
        echo "Simple resource monitoring script "
        echo "Usage: $0 [OPTIONS]"
        echo "Allowed commands:"
        echo "  -h, --help | Show Help"
        echo "  -c, --cpu | Show CPU status"    
        echo "  -m, --memory | Show Memory status"
        echo "  -d, --disks | Show Disk information"
        echo "  -n, --network | Show Network status"
        echo "  -la, --loadaverage | Show Load average"
	echo "  -p, --proc | Show "
	echo "  -k, --kill | "
        echo "  -o, --output | "	

}

# CPU function
function show_cpu {
        echo "CPU information:"
        grep "model name" /proc/cpuinfo 
}
# Memory function
function show_memory {
        echo "Memory information:"
        free -h
}
# Disk function
function show_disk {
        echo "Disk information:"
        df -h
}
# Network function
function show_network {
        echo "Network status:"
        ip -s link
}
# LA function
function show_la {
        uptime | grep -o "load average:.*"
}
# Proc function]
function show_proc {
       
}
# kill function
function kill_process{



}
# output function
function save_output {


}

# Input args check
if [ $# -eq 0 ]; then
show_help
   exit 0
fi

#
while [ "$1" != "" ]; do
        case $1 in
                -h | --help)
                        show_help
                        ;;
                -c | --cpu)
                        show_cpu
                        ;;
                -m | --memory)
                        show_memory
                        ;;
                -n | --network)
                        show_network
                        ;;
                -d | --disks)
                        show_disk
                        ;;
                -la | --loadaverage)
                        show_la
                        ;;
                *)
                        echo "Unknown command: $1"
                        show_help
                        ;;
        esac
        shift
done
