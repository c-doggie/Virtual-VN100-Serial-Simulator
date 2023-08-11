import serial
import time
import math
import random
import string

def generate_output_string(timestamp):
    #Generate the output string based on the current timestamp.
    y = 180 * math.sin(timestamp)
    p = 90 * math.sin(timestamp)
    r = 180 * math.sin(timestamp)
    
    random_char = random.choice(string.ascii_letters + string.digits)
    return f"$VNYPR,{y:.2f},{p:.2f},{r:.2f}*6{random_char}\r\n"

def send_string_to_serial(port, baudrate, frequency):
    #Sends a generated message to the specified serial port at a given frequency.
    
    # Open the serial port
    with serial.Serial(port, baudrate, timeout=1) as ser:
        start_time = time.time()
        while True:
            current_time = time.time()
            elapsed_time = current_time - start_time
            
            message = generate_output_string(elapsed_time)
            # Send the message
            print(message.encode())
            ser.write(message.encode())
            
            # Wait for the next cycle
            time.sleep(1.0 / frequency)

if __name__ == "__main__":
    PORT = "/dev/pts/2"  # Change this to your port name
    BAUDRATE = 115200        # Change if necessary
    FREQUENCY = 200        # Hz
    
    send_string_to_serial(PORT, BAUDRATE, FREQUENCY)
