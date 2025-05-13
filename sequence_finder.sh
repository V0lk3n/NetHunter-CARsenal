#!/bin/bash

# Function to print messages in color
print_color() {
    color="$1"
    message="$2"
    case "$color" in
        green) echo -e "\e[32m$message\e[0m" ;;
        red) echo -e "\e[31m$message\e[0m" ;;
        yellow) echo -e "\e[33m$message\e[0m" ;;
        blue) echo -e "\e[34m$message\e[0m" ;;
        *) echo "$message" ;;
    esac
}

# Check if exactly one argument is provided
if [ "$#" -ne 1 ]; then
    print_color red "Usage: $0 <input_file>"
    exit 1
fi

# Check if the file exists
if [[ ! -f "$1" ]]; then
    print_color red "The file does not exist."
    exit 1
fi

# Create the folder for split parts
split_folder="/root/candump/splitted_part"
mkdir -p "$split_folder"

# Get the number of lines in the file
line_count=$(wc -l < "$1")
echo "File has $line_count lines."

# Loop until the file has one line
while [ "$line_count" -gt 1 ]; do
    # Calculate the split point
    split=$((line_count / 2))
    if (( line_count % 2 != 0 )); then
        split1_lines=$((split + 1))
        split2_lines=$split
    else
        split1_lines=$split
        split2_lines=$split
    fi

    # Split the file into part1 and part2 and move them to the split folder
    head -n "$split1_lines" "$1" > "$split_folder/part1"
    tail -n "$split2_lines" "$1" > "$split_folder/part2"

    # Run canplayer on the first part
    echo ""
    echo "Running first part..."
    canplayer -I "$split_folder/part1"
    echo "Did the car receive the signal? Y/N"
    read -r signal_received
    echo ""

    # Check if the response is "yes" (any case) or not
    if [[ "$signal_received" =~ ^[Yy]([Ee][Ss])?$ ]]; then
        print_color green "Correct signal found. Proceeding..."
        if [[ -f "$split_folder/part2" ]]; then
            rm "$split_folder/part2"  # Remove part2 as we no longer need it
        fi
        line_count=$(wc -l < "$split_folder/part1")  # Update line_count to part1
    else
        if [[ -f "$split_folder/part1" ]]; then
            rm "$split_folder/part1"  # Remove part1 if the answer is not "yes"
        fi
        echo "Running second part..."
        canplayer -I "$split_folder/part2"
        echo "Did the car receive the signal? Y/N"
        read -r signal_received
        echo ""

        # If the second part works, we remove part1 and continue
        if [[ "$signal_received" =~ ^[Yy]([Ee][Ss])?$ ]]; then
            print_color green "Correct signal found in second part."
            if [[ -f "$split_folder/part1" ]]; then
                rm "$split_folder/part1"  # Remove part1
            fi
            line_count=$(wc -l < "$split_folder/part2")  # Update line_count to part2
        else
            print_color red "Correct signal not found. Use candump again."
            break  # Exit the loop if no signal is found
        fi
    fi
done

# Once the loop is done, we will have two or fewer lines in one of the split parts
# So, use the remaining part with 2 or fewer lines for the final process

final_part="$split_folder/part1"  # Default to part1 if it's the last split with 2 or fewer lines
if [[ ! -f "$final_part" ]]; then
    final_part="$split_folder/part2"  # Otherwise, use part2
fi

# Check that the final part exists and isn't empty
if [[ ! -f "$final_part" || ! -s "$final_part" ]]; then
    print_color red "Final part is empty or missing. Exiting."
    exit 1
fi

echo ""
print_color yellow "The file has one line left. Enter your CAN interface: "
read -r can_iface

# Ensure CAN interface is provided
if [[ -z "$can_iface" ]]; then
    print_color red "CAN interface is required. Exiting."
    exit 1
fi

echo ""

# Loop through each line in the final part (either part1 or part2)
while IFS= read -r line; do
    # Extract the CAN message (the part after the second space)
    can_message=$(echo "$line" | awk '{print $3}')

    # Ensure we have a valid CAN message
    if [[ -z "$can_message" ]]; then
        print_color red "Invalid line format or missing CAN message. Skipping..."
        continue
    fi

    print_color yellow "Sending Exact CAN Sequence : $(print_color blue "$can_message")"
    cansend "$can_iface" "$can_message"  # Send the CAN message

done < "$final_part"  # Use the correct final part
