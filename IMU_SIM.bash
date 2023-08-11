#!/bin/bash

cleanup() {
    # This function will be executed upon pressing Ctrl+C
    echo -e "\nCleaning up..."
    pkill -f "python3 IMU_SIM.py"
    pkill socat
    pkill cat
    rm -f tmp_log.txt
    rm -f error_log.txt
    echo "Done!"
    exit 0
}

# Set up the trap
trap cleanup SIGINT

echo "Creating virtual ports..."

stdbuf -oL -eL socat -d -d pty,raw,echo=0 pty,raw,echo=0 > tmp_log.txt 2>&1 &
sleep 5

# Read the log file to get the PTY names
output=$(cat tmp_log.txt)

port_lines=$(echo "$output" | grep "/dev/pts/")
port1=$(echo "$port_lines" | head -1 | awk '{print $NF}')
port2=$(echo "$port_lines" | tail -1 | awk '{print $NF}')

echo "Extracted ports: $port1 and $port2"

# Determine which port has the lower index
if [ $(basename $port1 | sed 's/[^0-9]*//g') -lt $(basename $port2 | sed 's/[^0-9]*//g') ]; then
    send_port=$port1
    receive_port=$port2
else
    send_port=$port2
    receive_port=$port1
fi

echo "Setting $send_port as sending port and modifying Python script accordingly..."
# Modify the Python script to use the determined port
sed -i "s|PORT = \".*\"|PORT = \"$send_port\"|" IMU_SIM.py

# Run Python script in the background and log any potential errors
echo "Starting Python script..."
python3 IMU_SIM.py 2>> error_log.txt &

# Open a new terminal window to show received data
echo "Opening new terminal for received data..."
gnome-terminal -- bash -c "echo 'Received data on $receive_port:'; cat $receive_port; read -p 'Press [Enter] to close this terminal.' "

# Inform the user
echo "Script setup complete. Press Ctrl+C to cleanup and exit."

# Keep the script running so it can catch the SIGINT
while true; do
    sleep 10
done
