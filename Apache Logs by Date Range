#!/bin/bash

# Function to convert input date format from DD/MM/YYYY:HH:MM to "YYYY-MM-DD HH:MM:SS"
convert_date() {
    input_date="$1"
    formatted_date=$(echo "$input_date" | awk -F'[:/]' '{printf "%04d-%02d-%02d %02d:%02d:00\n", $3, $2, $1, $4, $5}')
    date -d "$formatted_date" +"%s" 2>/dev/null
}

# Prompt user for the start date and time
read -p "Enter the start date and time (DD/MM/YYYY:HH:MM): " start_time
read -p "Enter the end date and time (DD/MM/YYYY:HH:MM): " end_time

# Convert dates to Unix timestamps
start_epoch=$(convert_date "$start_time")
end_epoch=$(convert_date "$end_time")

# Check if conversion was successful
if [[ -z "$start_epoch" || -z "$end_epoch" ]]; then
    echo "Error: Invalid date format. Use DD/MM/YYYY:HH:MM"
    exit 1
fi

# Define log files
log_files=$(ls ../logs/apache_*access.log ../logs/apache_*access.log.* 2>/dev/null)

# Process logs
zcat -f $log_files | awk -v start="$start_epoch" -v end="$end_epoch" '
{
    match($0, /\[([0-9]{2})\/([A-Za-z]{3})\/([0-9]{4}):([0-9]{2}):([0-9]{2}):([0-9]{2})/, time)
    if (time[0] != "") {
        # Convert log time to Unix timestamp
        months="Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec"
        split(months, month_arr, " ")
        for (i in month_arr) { if (month_arr[i] == time[2]) month_num = i }
        log_epoch = mktime(time[3] " " month_num " " time[1] " " time[4] " " time[5] " " time[6])
        
        # Filter based on user input time range
        if (log_epoch >= start && log_epoch <= end) {
            print $1  # Print IP address
        }
    }
}' | sort | uniq -c | sort -nr | head -20
