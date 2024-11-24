#!/bin/bash                       

# Define the report file path where all output will be saved
REPORT_FILE="analysis_report.txt"  # Name of the file where the script will save results

# Start the report file with a title and the current date
echo "System File Analyzer Report" > "$REPORT_FILE"         # Add a title to the report file
echo "Generated on: $(date)" >> "$REPORT_FILE"              # Add the current date to the report
echo "==========================================" >> "$REPORT_FILE"  # Add a separator line for readability

# Function to log messages to both the screen and the report file
log() {
    echo "$1" | tee -a "$REPORT_FILE"    # Print message to both screen and report file
    echo                                 # Print an empty line for readability
}

# Function to analyze metadata of a specific file
file_metadata() {
    log "File Metadata Analysis"             # Announce metadata analysis
    echo "Enter the file path:"              # Ask the user for a file path
    read file_path                           # Get the file path input from the user

    if [ -f "$file_path" ]; then             # Check if the provided path points to a file
        log "File Path: $file_path"          # Log the provided file path
        log "-----------------------------------------------------------------------------------------"
        stat "$file_path" | tee -a "$REPORT_FILE"  # Show and log file details (size, permissions, etc.)
        echo                                 # Print an empty line
        log "Detailed File Type:"            # Announce the file type analysis
        file "$file_path" | tee -a "$REPORT_FILE"  # Show and log the file type
        echo                                 # Print an empty line
    else
        log "Invalid file path."             # Notify if the input is not a valid file
    fi
    log "-------------------------------------------------------------------------------------------"
    echo                                     # Print an empty line
}

# Function to analyze the word and character count of a text file
text_content() {
    log "Text Content Analysis"              # Announce text file analysis
    echo "Enter the text file path:"         # Ask the user for a text file path
    read file_path                           # Get the file path input from the user

    if [ -f "$file_path" ]; then             # Check if the provided path points to a file
        log "File Path: $file_path"          # Log the file path
        log "----------------------------------------------------------------------------------------"
        log "Word Count:"                    # Announce word count analysis
        wc -w "$file_path" | tee -a "$REPORT_FILE"  # Show and log the word count
        echo                                 # Print an empty line
        log "Character Count:"               # Announce character count analysis
        wc -m "$file_path" | tee -a "$REPORT_FILE"  # Show and log the character count
        echo                                 # Print an empty line
    else
        log "Invalid text file path."        # Notify if the input is not a valid file
    fi
    log "------------------------------------------------------------------------------------------"
    echo                                     # Print an empty line
}

# Function to analyze disk usage
disk_usage() {
    log "Disk Usage Analysis"                # Announce disk usage analysis
    echo "1. Check disk usage of the entire system"  # Present option 1 for overall system disk usage
    echo "2. Check disk usage of a specific file"    # Present option 2 for file-specific disk usage
    read -p "Choose an option (1-2): " option  # Ask the user to pick an option

    if [[ "$option" == "1" ]]; then           # If the user chooses option 1
        log "System-wide Disk Usage:"         # Announce system-wide disk usage analysis
        log "-----------------------------------------------------------------------------------------"
        df -h / | awk 'NR==1 {print "Filesystem", "Size", "Used", "Avail", "Use%", "Mounted on"; print "-------------------------";} NR>1 {print $1, $2, $3, $4, $5, $6}' | column -t | tee -a "$REPORT_FILE"  # Show and log disk usage in human-readable format
        echo                                 # Print an empty line
    elif [[ "$option" == "2" ]]; then         # If the user chooses option 2
        echo "Enter the file path:"           # Ask the user for a file path
        read file_path                        # Get the file path input
        if [ -f "$file_path" ]; then          # Check if the path is a valid file
            log "Disk Usage of File: $file_path"  # Announce file-specific disk usage
            log "-------------------------------------------------------------------------------------"
            du -h "$file_path" | tee -a "$REPORT_FILE"  # Show and log the file's disk usage
            echo                             # Print an empty line
        else
            log "Invalid file path."         # Notify if the input is not a valid file
        fi
    else
        log "Invalid choice. Please select 1 or 2."  # Notify if the user makes an invalid choice
    fi
    log "-------------------------------------------------------------------------------------------"
    echo                                     # Print an empty line
}

# Function to perform security analysis and get file hash
security_info() {
    log "Security Analysis"                  # Announce security analysis
    echo "Enter the file path:"              # Ask the user for a file path
    read file_path                           # Get the file path input

    if [ -f "$file_path" ]; then             # Check if the path is a valid file
        log "File Path: $file_path"          # Log the file path
        log "----------------------------------------------------------------------------------------"
        ls -lh "$file_path" | awk '{print "Permissions:", $1, "\nLinks:", $2, "\nOwner:", $3, "\nGroup:", $4, "\nSize:", $5, "\nDate:", $6, $7, $8, "\nName:", $9}' | tee -a "$REPORT_FILE"  # Show and log file permissions and details
        echo                                 # Print an empty line
        log "File Hash (MD5):"               # Announce MD5 hash analysis
        md5sum "$file_path" | awk '{print $1}' | tee -a "$REPORT_FILE"  # Show and log the file's MD5 hash
        echo                                 # Print an empty line
    else
        log "Invalid file path."             # Notify if the input is not a valid file
    fi
    log "-------------------------------------------------------------------------------------------"
    echo                                     # Print an empty line
}

# Function to check if a file is compressed
compression_analysis() {
    log "Compression Analysis"               # Announce compression analysis
    echo "Enter the file path:"              # Ask the user for a file path
    read file_path                           # Get the file path input

    if [ -f "$file_path" ]; then             # Check if the path is a valid file
        file_type=$(file "$file_path")       # Get the file type using the `file` command
        log "File Path: $file_path"          # Log the file path
        if [[ "$file_type" == *"compressed"* || "$file_type" == *"archive"* || "$file_type" == *"gzip"* || "$file_type" == *"zip"* || "$file_type" == *"bzip2"* ]]; then  # Check if the file is compressed
            log "This file is compressed."   # Log if the file is compressed
            log "Compression Type: ${file_type#*: }"  # Log the compression type
            echo                             # Print an empty line
        else
            log "This file is not compressed."  # Log if the file is not compressed
        fi
    else
        log "Invalid file path."             # Notify if the input is not a valid file
    fi
    log "-------------------------------------------------------------------------------------------"
    echo                                     # Print an empty line
}

# Function to find duplicate files based on content (MD5 hash)
find_duplicates() {
    log "Duplicate Detection"                # Announce duplicate file detection
    echo "Enter the directory path:"         # Ask the user for a directory path
    read directory                           # Get the directory path input

    if [ -d "$directory" ]; then             # Check if the path is a valid directory
        log "Directory Path: $directory"     # Log the directory path
        log "----------------------------------------------------------------------------------------"
        find "$directory" -type f -exec md5sum {} + | sort | uniq -D -w 32 | tee -a "$REPORT_FILE"  # Find and log duplicate files based on their MD5 hash
        echo                                 # Print an empty line
    else
        log "Invalid directory path."        # Notify if the input is not a valid directory
    fi
    log "--------------------------------------------------------------------------------------------"
    echo                                     # Print an empty line
}

# Function to monitor CPU, memory, and specific file resource usage
resource_monitoring() {
    log "Resource Monitoring"                # Announce resource monitoring
    echo "1. Monitor system-wide CPU and Memory"  # Option to monitor system resources
    echo "2. Monitor specific file"               # Option to monitor file-specific resources
    read -p "Choose an option (1-2): " option  # Ask the user to choose an option

    if [[ "$option" == "1" ]]; then           # If the user chooses system-wide monitoring
        log "System-wide CPU and Memory Usage:"  # Announce system-wide resource usage
        log "----------------------------------------------------------------------------------------"
        top -b -n1 | awk 'NR==1 {print $0}; NR>1 && NR<=5 {print $0}' | tee -a "$REPORT_FILE"  # Show and log system resource usage
        echo                                 # Print an empty line
    elif [[ "$option" == "2" ]]; then         # If the user chooses file-specific monitoring
        echo "Enter the file path:"           # Ask the user for a file path
        read file_path                        # Get the file path input
        if [ -f "$file_path" ]; then          # Check if the path is a valid file
            log "Monitoring file: $file_path"  # Announce file-specific monitoring
            log "--------------------------------------------------------------------------------------"
            lsof "$file_path" | tee -a "$REPORT_FILE"  # Show and log file-specific resource usage
            echo                             # Print an empty line
        else
            log "Invalid file path."         # Notify if the input is not a valid file
        fi
    else
        log "Invalid choice. Please select 1 or 2."  # Notify if the user makes an invalid choice
    fi
    log "--------------------------------------------------------------------------------------------"
    echo                                     # Print an empty line
}

# Main loop to display options and run selected analyses
while true; do
    echo "=========================================="          # Display a menu separator
    echo "File Analyzer Script - Menu"                      # Display the menu title
    echo "1. Analyze File Metadata"                         # Option 1 for metadata analysis
    echo "2. Analyze Text File Content"                     # Option 2 for text file content analysis
    echo "3. Analyze Disk Usage"                            # Option 3 for disk usage analysis
    echo "4. Perform Security Analysis"                     # Option 4 for security analysis
    echo "5. Analyze File Compression"                      # Option 5 for compression analysis
    echo "6. Find Duplicate Files"                          # Option 6 for duplicate detection
    echo "7. Monitor Resources"                             # Option 7 for resource monitoring
    echo "8. Exit"                                          # Option 8 to exit the script
    echo "=========================================="          # Display a menu separator
    read -p "Choose an option (1-8): " choice               # Ask the user to choose an option

    case "$choice" in
        1) file_metadata ;;                                 # Run file metadata analysis
        2) text_content ;;                                  # Run text file content analysis
        3) disk_usage ;;                                    # Run disk usage analysis
        4) security_info ;;                                 # Run security analysis
        5) compression_analysis ;;                         # Run compression analysis
        6) find_duplicates ;;                              # Run duplicate detection
        7) resource_monitoring ;;                          # Run resource monitoring
        8) log "Exiting script. Goodbye!"; exit 0 ;;       # Exit the script
        *) log "Invalid choice. Please select 1-8." ;;     # Notify for invalid menu choice
    esac
done
#!/bin/bash                       

# Define the report file path where all output will be saved
REPORT_FILE="analysis_report.txt"  # Name of the file where the script will save results

# Start the report file with a title and the current date
echo "System File Analyzer Report" > "$REPORT_FILE"         # Add a title to the report file
echo "Generated on: $(date)" >> "$REPORT_FILE"              # Add the current date to the report
echo "==========================================" >> "$REPORT_FILE"  # Add a separator line for readability

# Function to log messages to both the screen and the report file
log() {
    echo "$1" | tee -a "$REPORT_FILE"    # Print message to both screen and report file
    echo                                 # Print an empty line for readability
}

# Function to analyze metadata of a specific file
file_metadata() {
    log "File Metadata Analysis"             # Announce metadata analysis
    echo "Enter the file path:"              # Ask the user for a file path
    read file_path                           # Get the file path input from the user

    if [ -f "$file_path" ]; then             # Check if the provided path points to a file
        log "File Path: $file_path"          # Log the provided file path
        log "-----------------------------------------------------------------------------------------"
        stat "$file_path" | tee -a "$REPORT_FILE"  # Show and log file details (size, permissions, etc.)
        echo                                 # Print an empty line
        log "Detailed File Type:"            # Announce the file type analysis
        file "$file_path" | tee -a "$REPORT_FILE"  # Show and log the file type
        echo                                 # Print an empty line
    else
        log "Invalid file path."             # Notify if the input is not a valid file
    fi
    log "-------------------------------------------------------------------------------------------"
    echo                                     # Print an empty line
}

# Function to analyze the word and character count of a text file
text_content() {
    log "Text Content Analysis"              # Announce text file analysis
    echo "Enter the text file path:"         # Ask the user for a text file path
    read file_path                           # Get the file path input from the user

    if [ -f "$file_path" ]; then             # Check if the provided path points to a file
        log "File Path: $file_path"          # Log the file path
        log "----------------------------------------------------------------------------------------"
        log "Word Count:"                    # Announce word count analysis
        wc -w "$file_path" | tee -a "$REPORT_FILE"  # Show and log the word count
        echo                                 # Print an empty line
        log "Character Count:"               # Announce character count analysis
        wc -m "$file_path" | tee -a "$REPORT_FILE"  # Show and log the character count
        echo                                 # Print an empty line
    else
        log "Invalid text file path."        # Notify if the input is not a valid file
    fi
    log "------------------------------------------------------------------------------------------"
    echo                                     # Print an empty line
}

# Function to analyze disk usage
disk_usage() {
    log "Disk Usage Analysis"                # Announce disk usage analysis
    echo "1. Check disk usage of the entire system"  # Present option 1 for overall system disk usage
    echo "2. Check disk usage of a specific file"    # Present option 2 for file-specific disk usage
    read -p "Choose an option (1-2): " option  # Ask the user to pick an option

    if [[ "$option" == "1" ]]; then           # If the user chooses option 1
        log "System-wide Disk Usage:"         # Announce system-wide disk usage analysis
        log "-----------------------------------------------------------------------------------------"
        df -h / | awk 'NR==1 {print "Filesystem", "Size", "Used", "Avail", "Use%", "Mounted on"; print "-------------------------";} NR>1 {print $1, $2, $3, $4, $5, $6}' | column -t | tee -a "$REPORT_FILE"  # Show and log disk usage in human-readable format
        echo                                 # Print an empty line
    elif [[ "$option" == "2" ]]; then         # If the user chooses option 2
        echo "Enter the file path:"           # Ask the user for a file path
        read file_path                        # Get the file path input
        if [ -f "$file_path" ]; then          # Check if the path is a valid file
            log "Disk Usage of File: $file_path"  # Announce file-specific disk usage
            log "-------------------------------------------------------------------------------------"
            du -h "$file_path" | tee -a "$REPORT_FILE"  # Show and log the file's disk usage
            echo                             # Print an empty line
        else
            log "Invalid file path."         # Notify if the input is not a valid file
        fi
    else
        log "Invalid choice. Please select 1 or 2."  # Notify if the user makes an invalid choice
    fi
    log "-------------------------------------------------------------------------------------------"
    echo                                     # Print an empty line
}

# Function to perform security analysis and get file hash
security_info() {
    log "Security Analysis"                  # Announce security analysis
    echo "Enter the file path:"              # Ask the user for a file path
    read file_path                           # Get the file path input

    if [ -f "$file_path" ]; then             # Check if the path is a valid file
        log "File Path: $file_path"          # Log the file path
        log "----------------------------------------------------------------------------------------"
        ls -lh "$file_path" | awk '{print "Permissions:", $1, "\nLinks:", $2, "\nOwner:", $3, "\nGroup:", $4, "\nSize:", $5, "\nDate:", $6, $7, $8, "\nName:", $9}' | tee -a "$REPORT_FILE"  # Show and log file permissions and details
        echo                                 # Print an empty line
        log "File Hash (MD5):"               # Announce MD5 hash analysis
        md5sum "$file_path" | awk '{print $1}' | tee -a "$REPORT_FILE"  # Show and log the file's MD5 hash
        echo                                 # Print an empty line
    else
        log "Invalid file path."             # Notify if the input is not a valid file
    fi
    log "-------------------------------------------------------------------------------------------"
    echo                                     # Print an empty line
}

# Function to check if a file is compressed
compression_analysis() {
    log "Compression Analysis"               # Announce compression analysis
    echo "Enter the file path:"              # Ask the user for a file path
    read file_path                           # Get the file path input

    if [ -f "$file_path" ]; then             # Check if the path is a valid file
        file_type=$(file "$file_path")       # Get the file type using the `file` command
        log "File Path: $file_path"          # Log the file path
        if [[ "$file_type" == *"compressed"* || "$file_type" == *"archive"* || "$file_type" == *"gzip"* || "$file_type" == *"zip"* || "$file_type" == *"bzip2"* ]]; then  # Check if the file is compressed
            log "This file is compressed."   # Log if the file is compressed
            log "Compression Type: ${file_type#*: }"  # Log the compression type
            echo                             # Print an empty line
        else
            log "This file is not compressed."  # Log if the file is not compressed
        fi
    else
        log "Invalid file path."             # Notify if the input is not a valid file
    fi
    log "-------------------------------------------------------------------------------------------"
    echo                                     # Print an empty line
}

# Function to find duplicate files based on content (MD5 hash)
find_duplicates() {
    log "Duplicate Detection"                # Announce duplicate file detection
    echo "Enter the directory path:"         # Ask the user for a directory path
    read directory                           # Get the directory path input

    if [ -d "$directory" ]; then             # Check if the path is a valid directory
        log "Directory Path: $directory"     # Log the directory path
        log "----------------------------------------------------------------------------------------"
        find "$directory" -type f -exec md5sum {} + | sort | uniq -D -w 32 | tee -a "$REPORT_FILE"  # Find and log duplicate files based on their MD5 hash
        echo                                 # Print an empty line
    else
        log "Invalid directory path."        # Notify if the input is not a valid directory
    fi
    log "--------------------------------------------------------------------------------------------"
    echo                                     # Print an empty line
}

# Function to monitor CPU, memory, and specific file resource usage
resource_monitoring() {
    log "Resource Monitoring"                # Announce resource monitoring
    echo "1. Monitor system-wide CPU and Memory"  # Option to monitor system resources
    echo "2. Monitor specific file"               # Option to monitor file-specific resources
    read -p "Choose an option (1-2): " option  # Ask the user to choose an option

    if [[ "$option" == "1" ]]; then           # If the user chooses system-wide monitoring
        log "System-wide CPU and Memory Usage:"  # Announce system-wide resource usage
        log "----------------------------------------------------------------------------------------"
        top -b -n1 | awk 'NR==1 {print $0}; NR>1 && NR<=5 {print $0}' | tee -a "$REPORT_FILE"  # Show and log system resource usage
        echo                                 # Print an empty line
    elif [[ "$option" == "2" ]]; then         # If the user chooses file-specific monitoring
        echo "Enter the file path:"           # Ask the user for a file path
        read file_path                        # Get the file path input
        if [ -f "$file_path" ]; then          # Check if the path is a valid file
            log "Monitoring file: $file_path"  # Announce file-specific monitoring
            log "--------------------------------------------------------------------------------------"
            lsof "$file_path" | tee -a "$REPORT_FILE"  # Show and log file-specific resource usage
            echo                             # Print an empty line
        else
            log "Invalid file path."         # Notify if the input is not a valid file
        fi
    else
        log "Invalid choice. Please select 1 or 2."  # Notify if the user makes an invalid choice
    fi
    log "--------------------------------------------------------------------------------------------"
    echo                                     # Print an empty line
}

# Main loop to display options and run selected analyses
while true; do
    echo "=========================================="          # Display a menu separator
    echo "File Analyzer Script - Menu"                      # Display the menu title
    echo "1. Analyze File Metadata"                         # Option 1 for metadata analysis
    echo "2. Analyze Text File Content"                     # Option 2 for text file content analysis
    echo "3. Analyze Disk Usage"                            # Option 3 for disk usage analysis
    echo "4. Perform Security Analysis"                     # Option 4 for security analysis
    echo "5. Analyze File Compression"                      # Option 5 for compression analysis
    echo "6. Find Duplicate Files"                          # Option 6 for duplicate detection
    echo "7. Monitor Resources"                             # Option 7 for resource monitoring
    echo "8. Exit"                                          # Option 8 to exit the script
    echo "=========================================="          # Display a menu separator
    read -p "Choose an option (1-8): " choice               # Ask the user to choose an option

    case "$choice" in
        1) file_metadata ;;                                 # Run file metadata analysis
        2) text_content ;;                                  # Run text file content analysis
        3) disk_usage ;;                                    # Run disk usage analysis
        4) security_info ;;                                 # Run security analysis
        5) compression_analysis ;;                         # Run compression analysis
        6) find_duplicates ;;                              # Run duplicate detection
        7) resource_monitoring ;;                          # Run resource monitoring
        8) log "Exiting script. Goodbye!"; exit 0 ;;       # Exit the script
        *) log "Invalid choice. Please select 1-8." ;;     # Notify for invalid menu choice
    esac
done
