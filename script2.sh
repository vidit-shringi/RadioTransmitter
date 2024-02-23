#!/bin/bash

# Install necessary packages
sudo apt install -y libsndfile1-dev
pip install sounddevice numpy tkinter

# Clone and compile pifmrds
git clone https://github.com/ChristopheJacquet/PiFmRds.git
cd PiFmRds/src
make clean
make

# Create the Python script
cat << EOF > ~/radio_transmitter.py
import tkinter as tk
import subprocess
from tkinter import filedialog, messagebox

class Application(tk.Frame):
    def __init__(self, master=None):
        super().__init__(master)
        self.master = master
        self.pack()
        self.create_widgets()

    def create_widgets(self):
        self.select_button = tk.Button(self)
        self.select_button["text"] = "Select Audio File"
        self.select_button["command"] = self.select_file
        self.select_button.pack(side="top")

        self.freq_label = tk.Label(self, text="Frequency (MHz):")
        self.freq_label.pack(side="top")
        self.freq_entry = tk.Entry(self)
        self.freq_entry.pack(side="top")

        self.rt_label = tk.Label(self, text="Radiotext (RT):")
        self.rt_label.pack(side="top")
        self.rt_entry = tk.Entry(self)
        self.rt_entry.pack(side="top")

        self.ppm_label = tk.Label(self, text="PPM error: ")
        self.ppm_label.pack(side="top")
        self.ppm_entry = tk.Entry(self)
        self.ppm_entry.pack(side="top")

        self.pi_label = tk.Label(self, text="Programme Identifier (PI):")
        self.pi_label.pack(side="top")
        self.pi_entry = tk.Entry(self)
        self.pi_entry.pack(side="top")

        self.ps_label = tk.Label(self, text="Programme Service name (PS):")
        self.ps_label.pack(side="top")
        self.ps_entry = tk.Entry(self)
        self.ps_entry.pack(side="top")

        self.transmit_button = tk.Button(self)
        self.transmit_button["text"] = "Transmit"
        self.transmit_button["command"] = self.transmit
        self.transmit_button["state"] = "disabled"
        self.transmit_button.pack(side="top")

        self.quit = tk.Button(self, text="QUIT", fg="red",
                              command=self.master.destroy)
        self.quit.pack(side="bottom")

    def select_file(self):
        self.filename = filedialog.askopenfilename(filetypes=[("Audio Files", "*.wav")])
        if self.filename:
            self.transmit_button["state"] = "normal"

    def transmit(self):
        print("Transmitting...")
        # Transmit the audio as an FM signal
        subprocess.call(['sudo', './pifmrds/src/pi_fm_rds', '-audio', self.filename, '-freq', self.freq_entry.get(), '-rt', self.rt_entry.get(), '-ppm', self.ppm_entry.get(), '-pi', self.pi_entry.get(), '-ps', self.ps_entry.get()])
        messagebox.showinfo("Info", "Transmission completed!")

root = tk.Tk()
app = Application(master=root)
app.mainloop()
EOF

# Run the Python script
sudo python3 ~/radio_transmitter.py
