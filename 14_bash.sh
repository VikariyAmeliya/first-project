#!/bin/bash

# Packages check
for package in sysstat ifstat; do
    if ! dpkg -l | grep -q "$package"; then
        echo "Package '$package' is not installed."
        echo "The required packages for the correct operation of the script are 'sysstat' and 'ifstat'."
        exit 1
    fi
done

# Help function
function show_help {
    echo "        Simple resource monitoring script"
    echo "            Usage: $0 [OPTIONS]"
    echo "             Allowed commands:"
    echo "                                              "
    echo "    -h, --help           | Show Help"
    echo "    -c, --cpu            | Show CPU status" 
    echo "    -m, --memory         | Show Memory status"
    echo "             Parameters -m"
    echo "           Show Total memory"
    echo "                'total'"
    echo "          Show available memory"
    echo "                'available'"
    echo "            Show free memory"
    echo "                'free'"
    echo "  -d, --disks           | Show Disk information"
    echo "             Parameters -d"
    echo "            IOPS monitoring"
    echo "                'iostat'"
    echo "  -n, --network         | Show Network status"
    echo "             Parameters -n"
    echo "         Show active connections"
    echo "                'netstat'"
    echo "         Show interface activity"
    echo "                'ifstat'"
    echo "  -la, --loadaverage    | Show Load average"
    echo "  -p, --proc            | Work with /proc directory"
    echo "             Parameters -p"
    echo "         Show all processes"
    echo "                'procs'"
    echo "  -k, --kill            | Kill [PID]"
    echo "  -o, --output          | Save output in file"
    echo "                                              "    
    echo "Usage: -o <output_file> <command_to_execute>"
    echo "                                              "
}

# CPU function
function show_cpu {
    echo "CPU Information:"
    grep 'cpu MHz' /proc/cpuinfo | head -n 1
    grep 'cpu cores' /proc/cpuinfo | uniq
    echo "CPU Usage:"
    top -bn1 | grep "Cpu(s)"  # shows current CPU usage
}

# Memory function
function show_memory {
    if [ -z "$1" ]; then
        free -h 
    else
        case $1 in
            total)
                grep MemTotal /proc/meminfo
                ;;
            available)
                grep MemAvailable /proc/meminfo
                ;;
            free)
                grep MemFree /proc/meminfo 
                ;;
            *)
                echo "Unknown memory parameter: $1"
                ;;
        esac
    fi
}

# Disk function
function show_disk {
    if [ -z "$1" ]; then
        echo "Disks usage:"
        df -h
    else
        case $1 in
            iostat)
                echo "IOPS monitoring"
                iostat -m -x
                ;;
            *)
                echo "Unknown disk parameter"
                ;;
        esac
    fi
}

# Network function
function show_network {
    echo "Show all network interfaces"
    ip -s link
    case $1 in
        netstat)
            echo "Show active connections"
            ss -tuln
            ;;
        ifstat)
            echo "Show interface activity"
            ifstat 1 5
            ;;
        *)
            echo "Unknown network parameter"
            ;;
    esac
}

# Load Average function
function show_la {
    uptime | grep -o "load average:.*"
}

# Proc function
function show_proc {
    if [ -z "$1" ]; then
        grep "model name" /proc/cpuinfo | uniq 
    else
        case $1 in
            procs) 
                echo "Show all processes"
                cat /proc/stat | awk '/^processes|^procs_running|^procs_blocked/ {print}'
                ;;
            *)
                echo "Unknown process parameter"
                ;;
        esac
    fi
}    

function kill_process {
    local signal=$1
    local pid=$2

    # Check both arg exists
    if [ -z "$signal" ] || [ -z "$pid" ]; then
        echo "Usage: -k <signal> <PID>"
        return 1
    fi

    kill "$signal" "$pid" 2>/dev/null

    # Kill status check
    if [ $? -eq 0 ]; then
        echo "Process $pid has been terminated successfully."
    else
        echo "Process $pid could not be terminated."
    fi
}


# Output function
function save {
    if [ $# -lt 2 ]; then
        echo "Usage: save <output_file> <command_to_execute>"
        return 1
    fi

    local output_file=$1
    shift  # Clear first arg (filename)

    # File exist check
    if [ -e "$output_file" ]; then
        echo "$output_file exists. Overwrite? (y/n)"
        read -r answer
        if [[ ! "$answer" =~ ^[Yy]$ ]]; then
            echo "Output not saved."
            return 1
        fi
    fi

    # Execute function inside a script
    command_output=$(bash "$0" "$@" 2>&1)  # run script with passed parameters
    echo "Executing command: $@"

    # Checking the command execution status
    if [ $? -eq 0 ]; then
        echo "$command_output" > "$output_file"  # Saving the output to a file
        echo "Output saved to $output_file"
    else
        echo "Failed to save output to $output_file"
    fi
}

# Input args check
if [ $# -eq 0 ]; then
show_help
   exit 0
fi

# Parsing input args
while [ "$1" != "" ]; do
    case $1 in
        -h | --help)
            show_help
            ;;
        -p | --proc)
            shift 
            show_proc "$1"
            ;;
        -c | --cpu)
            show_cpu
            ;;
        -m | --memory)
            shift
            show_memory "$1"
            ;;
        -n | --network)
            shift
            show_network "$1"
            ;;
        -d | --disks)
            shift
            show_disk "$1"
            ;;
        -la | --loadaverage)
            show_la
            ;;
        -k  | --kill)
            shift
            signal="$1" # First arg after -k is a signal
            shift
            pid="$1"
            kill_process "$signal" "$pid" 
            ;;
        -o  | --output)
            shift
            if [ "$#" -lt 2 ]; then
                echo "Usage: save <output_file> <command_to_execute>"
                exit 1
            fi
            output_file=$1
            shift
            save "$output_file" "$@"
            break
            ;;
        *)
            echo "Unknown command: $1"
            show_help
            ;;
    esac
    shift
done

