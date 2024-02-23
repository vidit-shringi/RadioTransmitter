#!/bin/bash

# Install necessary packages
sudo apt install -y libsndfile1-dev
pip install sounddevice numpy

# Clone and compile pifmrds
git clone https://github.com/ChristopheJacquet/PiFmRds.git
cd PiFmRds/src
make clean
make

# Create the Python script
cat << EOF > ~/radio_transmitter.py
import sounddevice as sd
import numpy as np
import os
import tempfile
import subprocess
from scipy.io.wavfile import write

# Set up sounddevice
fs = 44100  # Sample rate
seconds = 3  # Duration of recording

# Main loop
while True:
    print("Recording...")
    # Record audio from the microphone
    myrecording = sd.rec(int(seconds * fs), samplerate=fs, channels=2)
    sd.wait()  # Wait until recording is finished

    # Save the audio to a temporary file
    temp = tempfile.NamedTemporaryFile(delete=False)
    write(temp.name, fs, myrecording)  # Save as WAV file 

    print("Transmitting...")
    # Transmit the audio as an FM signal
    subprocess.call(['sudo', './pifmrds/src/pi_fm_rds', '-audio', temp.name])

    # Remove the temporary file
    os.unlink(temp.name)
EOF

# Run the Python script
sudo python3 ~/radio_transmitter.py
