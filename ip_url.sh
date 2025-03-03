#!/bin/bash

# Get the server's public IP
server_ip=$(curl -s ipinfo.io/ip)

# Ask the user which report they want
echo -e "\nChoose an option:"
echo "1) Unique IPs with Count"
echo "2) Unique URLs with IP Count"
read -p "Enter your choice (1 or 2): " choice

# Validate input
if ! [[ "$choice" =~ ^[12]$ ]]; then
    echo "Invalid choice. Please enter 1 or 2."
    exit 1
fi

# Ask the user for the time range (e.g., "2" for logs from 2 hours ago)
read -p "Enter the number of hours ago to filter logs from: " hours_ago

# Validate input (ensure it's a positive integer)
if ! [[ "$hours_ago" =~ ^[0-9]+$ ]]; then
    echo "Invalid input. Please enter a valid number of hours."
    exit 1
fi

# Define the time filter based on user input
end_time=$(date --date="$hours_ago hours ago" '+%d/%b/%Y:%H')

# Generate report based on user choice
if [[ "$choice" == "1" ]]; then
    echo -e "\n\e[1;36m════════════════════════════════════════════════════════════════════════════════════════\e[0m"
    echo -e "\e[1;35m          Unique IPs Accessed in the Last $hours_ago Hour(s)          \e[0m"
    echo -e "\e[1;36m════════════════════════════════════════════════════════════════════════════════════════\e[0m"
    echo -e "\e[1;34m──────────────────────────────────────────────────────────────────────────────────────────\e[0m"
    printf "\e[1;33m| %-10s | %-18s | %-15s | %-35s |\e[0m\n" "IP Count" "IP Address" "Country" "IP Resolves to Domain"
    echo -e "\e[1;34m──────────────────────────────────────────────────────────────────────────────────────────\e[0m"

    # Process logs
    cat ../logs/apache_*access.log | awk -v end_time="$end_time" '$4 >= "["end_time' | awk '{print $1}' | sort | uniq -c | sort -nr | head -n 20 | while read count ip; do
        country=$(curl -s "http://ip-api.com/line/$ip?fields=country")
        domain=$(dig +short -x "$ip" | head -n 1)
        
        ip_info=""
        [[ "$ip" == "$server_ip" ]] && ip_info="        -->  IT IS YOUR SERVER IP"

        printf "\e[1;32m| %-10s | %-18s | %-15s | %-35s %s|\e[0m\n" "$count" "$ip" "${country:-Unknown}" "${domain:-N/A}" "$ip_info"
    done
    echo -e "\e[1;34m──────────────────────────────────────────────────────────────────────────────────────────\e[0m"

elif [[ "$choice" == "2" ]]; then
    echo -e "\n\e[1;36m════════════════════════════════════════════════════════════════════════════════════════\e[0m"
    echo -e "\e[1;35m          Unique URLs Accessed in the Last $hours_ago Hour(s)          \e[0m"
    echo -e "\e[1;36m════════════════════════════════════════════════════════════════════════════════════════\e[0m"
    echo -e "\e[1;34m──────────────────────────────────────────────────────────────────────────────────────────────────────────\e[0m"
    printf "\e[1;33m| %-10s | %-18s | %-15s | %-35s | %-30s |\e[0m\n" "IP Count" "IP Address" "Country" "IP Resolves to Domain" "URL"
    echo -e "\e[1;34m──────────────────────────────────────────────────────────────────────────────────────────────────────────\e[0m"

    # Process logs
    cat ../logs/apache_*access.log | awk -v end_time="$end_time" '$4 >= "["end_time' | awk '{print $1, $7}' | sort | uniq -c | sort -nr | head -n 20 | while read count ip url; do
        country=$(curl -s "http://ip-api.com/line/$ip?fields=country")
        domain=$(dig +short -x "$ip" | head -n 1)
        
        ip_info=""
        [[ "$ip" == "$server_ip" ]] && ip_info="        -->  IT IS YOUR SERVER IP"

        printf "\e[1;32m| %-10s | %-18s | %-15s | %-35s | %-30s %s|\e[0m\n" "$count" "$ip" "${country:-Unknown}" "${domain:-N/A}" "$url" "$ip_info"
    done
    echo -e "\e[1;34m──────────────────────────────────────────────────────────────────────────────────────────────────────────\e[0m"
fi
