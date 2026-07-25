import subprocess
import time
import sys
import tkinter as tk
from tkinter import messagebox
from PIL import Image, ImageTk

# --- Configuration ---
# 1. PLACE YOUR LOGO IMAGE IN THE SAME FOLDER
# 2. NAME IT EXACTLY "moomi_logo.png" (OR CHANGE THIS FILENAME)
LOGO_FILENAME = "moomi_logo.png"

def run_adb_command(command):
    """Executes an ADB shell command."""
    try:
        # Construct the ADB command
        full_command = ["adb", "shell"] + command.split()
        
        # Check if running from a script to find the executable if needed
        # (This makes it slightly more robust)
        # full_command = ["path/to/adb", "shell"] + command.split()

        result = subprocess.run(
            full_command,
            capture_output=True,
            text=True,
            check=True
        )
        return result.stdout.strip()
    except FileNotFoundError:
        messagebox.showerror("Error", "ADB is not installed or not added to system PATH.")
        sys.exit(1)
    except subprocess.CalledProcessError as e:
        messagebox.showerror("Error", f"Failed to execute ADB command:\n{e.stderr.strip()}")
        return None # Return None to handle the error in the main loop

def check_device_connection():
    """Verifies that an Android device is connected."""
    try:
        # Check available devices
        devices = subprocess.run(["adb", "devices"], capture_output=True, text=True, check=True).stdout
        lines = [line for line in devices.strip().split("\n")[1:] if line.strip()]
        
        if not lines:
            messagebox.showwarning("Warning", "No device connected.\nPlease connect your Android phone via USB with USB Debugging enabled.")
            return False # Indicated failure
            
        print(f"MooMi found connected Device(s):\n{devices.strip()}\n")
        return True # Indicated success
    except FileNotFoundError:
        messagebox.showerror("Error", "ADB tool not found.\n(Check installation or PATH)")
        return False
    except subprocess.CalledProcessError as e:
        messagebox.showerror("Error", f"Could not check devices:\n{e.stderr.strip()}")
        return False

# --- MooMi GUI Application ---

class MooMi_App:
    def __init__(self, root):
        self.root = root
        self.root.title("MooMi - ADB Auto Clicker")
        self.root.geometry("400x520") # Adjust size as needed
        self.root.configure(bg="#101010") # Dark theme

        # 1. Add the Logo
        self.add_logo()

        # 2. Main content area
        main_frame = tk.Frame(root, bg="#101010")
        main_frame.pack(pady=20)

        self.label_info = tk.Label(main_frame, text="MooMi: Phone Auto Clicker", font=("Arial", 16, "bold"), fg="white", bg="#101010")
        self.label_info.pack()

        # --- Controls ---
        controls_frame = tk.Frame(root, bg="#101010")
        controls_frame.pack(pady=20, padx=20)

        # X Coordinate
        label_x = tk.Label(controls_frame, text="X Coordinate:", font=("Arial", 10), fg="white", bg="#101010")
        label_x.grid(row=0, column=0, padx=10, pady=5, sticky="e")
        self.entry_x = tk.Entry(controls_frame, font=("Arial", 10), width=15)
        self.entry_x.grid(row=0, column=1, padx=10, pady=5)
        self.entry_x.insert(0, "500") # Default

        # Y Coordinate
        label_y = tk.Label(controls_frame, text="Y Coordinate:", font=("Arial", 10), fg="white", bg="#101010")
        label_y.grid(row=1, column=0, padx=10, pady=5, sticky="e")
        self.entry_y = tk.Entry(controls_frame, font=("Arial", 10), width=15)
        self.entry_y.grid(row=1, column=1, padx=10, pady=5)
        self.entry_y.insert(0, "1000") # Default

        # Interval
        label_interval = tk.Label(controls_frame, text="Interval (sec):", font=("Arial", 10), fg="white", bg="#101010")
        label_interval.grid(row=2, column=0, padx=10, pady=5, sticky="e")
        self.entry_interval = tk.Entry(controls_frame, font=("Arial", 10), width=15)
        self.entry_interval.grid(row=2, column=1, padx=10, pady=5)
        self.entry_interval.insert(0, "1.0") # Default

        # --- Status ---
        self.status_label = tk.Label(root, text="Status: MooMi is Ready", font=("Arial", 10, "italic"), fg="#aaaaaa", bg="#101010")
        self.status_label.pack(pady=(10, 20))

        # --- Buttons ---
        button_frame = tk.Frame(root, bg="#101010")
        button_frame.pack(pady=10)

        self.start_button = tk.Button(button_frame, text="START CLICKING", font=("Arial", 12, "bold"), bg="#ff00ff", fg="white", command=self.start_clicker, width=20, height=2)
        self.start_button.grid(row=0, column=0, padx=10)

        self.stop_button = tk.Button(button_frame, text="STOP", font=("Arial", 12, "bold"), bg="#aa0000", fg="white", command=self.stop_clicker, width=10, height=2, state="disabled")
        self.stop_button.grid(row=0, column=1, padx=10)

        # Initialize internal variables
        self.clicking_process = None
        self.is_clicking = False

    def add_logo(self):
        """Attempts to load and display the image logo."""
        try:
            image = Image.open(LOGO_FILENAME)
            # Resize the logo to fit the window while maintaining aspect ratio
            # image = image.resize((200, 200), Image.ANTIALIAS)
            # It's better to calculate a good size based on current window size
            logo_width = 300
            aspect_ratio = image.width / image.height
            logo_height = int(logo_width / aspect_ratio)

            # Create a PhotoImage
            self.logo_image = ImageTk.PhotoImage(image.resize((logo_width, logo_height), Image.LANCZOS))
            
            # Display it in a Label
            self.logo_label = tk.Label(self.root, image=self.logo_image, bg="#101010")
            self.logo_label.pack(pady=(30, 10)) # Top padding
        except FileNotFoundError:
            # Handle missing logo image gracefully
            print(f"[MooMi] Info: No logo image found ({LOGO_FILENAME}). Displaying text placeholder.")
            self.logo_placeholder = tk.Label(self.root, text="[ Logo Missing ]", font=("Arial", 20), fg="#333333", bg="#101010")
            self.logo_placeholder.pack(pady=40)
        except Exception as e:
            # Handle other image loading errors
            print(f"[MooMi] Error: Could not load logo image: {e}")
            self.logo_placeholder = tk.Label(self.root, text="[ Logo Error ]", font=("Arial", 20), fg="red", bg="#101010")
            self.logo_placeholder.pack(pady=40)

    def start_clicker(self):
        """Prepares for auto clicking and starts a countdown thread."""
        if not check_device_connection():
            return # Don't start if no device

        try:
            x = int(self.entry_x.get())
            y = int(self.entry_y.get())
            interval = float(self.entry_interval.get())
        except ValueError:
            messagebox.showwarning("Warning", "Invalid input!\nPlease enter numbers only for coordinates and interval.")
            return

        print(f"\n--- MooMi Initializing ---")
        print(f"Target: ({x}, {y}) | Interval: Every {interval} sec(s)")
        
        # UI updates
        self.is_clicking = True
        self.start_button.config(state="disabled")
        self.stop_button.config(state="normal")
        self.status_label.config(text="Status: Preparing...", fg="#ff8800")
        self.root.update_idletasks() # Refresh UI
        
        # 3-second countdown before starting
        for i in range(3, 0, -1):
            self.status_label.config(text=f"Status: Starting in {i}...", fg="#ff8800")
            self.root.update_idletasks()
            time.sleep(1)
        
        # Start the clicking loop (run in a separate thread to keep UI responsive)
        import threading
        self.click_thread = threading.Thread(target=self.clicking_loop, args=(x, y, interval))
        self.click_thread.start()

    def clicking_loop(self, x, y, interval):
        """The main continuous tapping logic, run in a separate thread."""
        self.status_label.config(text="Status: MooMi is Clicking!", fg="#00ff00")
        click_count = 0
        
        try:
            while self.is_clicking:
                run_adb_command(f"input tap {x} {y}")
                click_count += 1
                
                # Check for exit condition (errors during tap)
                # (You might want more robust error handling here)

                print(f"Tapped {click_count} time(s) at ({x}, {y})", end="\r")
                time.sleep(interval)
        except Exception as e:
            print(f"\n[MooMi Loop Error] Clicker loop terminated unexpected: {e}")
            # Consider notifying the user on the UI thread
            
        # Cleanup
        print(f"\n\n[Stopped] Total taps sent: {click_count}")

    def stop_clicker(self):
        """Stops the clicking process."""
        self.is_clicking = False # Signal the thread to stop
        self.status_label.config(text="Status: MooMi Stopped", fg="#ffaa00")
        self.start_button.config(state="normal")
        self.stop_button.config(state="disabled")
        print("\n\n--- MooMi Stopping Clicking Loop ---")

# --- Startup ---

def main():
    check_device_connection() # Final check on startup

    root = tk.Tk()
    app = MooMi_App(root)
    root.mainloop()

if __name__ == "__main__":
    main()
          
