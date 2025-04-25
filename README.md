<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
</head>
<body>

  <h1>Manufacturing Downtime Analysis</h1>

  <div class="section">
    <h2>Overview</h2>
    <p>
      This project analyzes manufacturing downtime to identify bottlenecks, inefficiencies, and their causes.
      By leveraging <strong>SQL</strong>, <strong>Python</strong>, and <strong>Power BI</strong>, the goal is to provide
      data driven insights to improve operational efficiency.
    </p>
  </div>

  <div class="section">
    <h2>Data Used</h2>
    <p>
      Dataset includes production line activity, machine failures, shift details, and downtime reasons.<br>
      Key fields: <code>timestamp</code>, <code>machine_id</code>, <code>failure_type</code>, <code>resolution_time</code>.
    </p>
  </div>

  <div class="section">
    <h2>Tools & Techniques</h2>
    <ul>
      <li><strong>SQL:</strong> Data extraction, transformation, preprocessing.</li>
      <li><strong>Python (pandas, Matplotlib):</strong> Exploratory Data Analysis (EDA) and visualizations.</li>
      <li><strong>Power BI:</strong> Interactive dashboards for trend analysis and insights.</li>
    </ul>
  </div>

  <div class="section">
    <h2>Key Findings</h2>
    <ul>
      <li>Identified top reasons for downtime and their impact on production.</li>
      <li>Analyzed time-based trends to spot peak downtime periods.</li>
      <li>Recommended solutions to reduce unplanned downtime and improve efficiency.</li>
    </ul>
  </div>

</body>
</html>

import tkinter as tk
from tkinter import messagebox
import pandas as pd
import matplotlib.pyplot as plt

# Sample function to analyze data (placeholder)
def analyze_data():
    try:
        # Load the dataset (replace with your actual dataset path)
        data = pd.read_csv("downtime_data.csv")
        
        # Simple analysis (example: downtime per machine)
        downtime_per_machine = data.groupby('machine_id')['resolution_time'].sum()
        
        # Display results in the GUI
        result_text.set(downtime_per_machine.to_string())
        
        # Optionally, plot the data
        downtime_per_machine.plot(kind='bar', title="Downtime per Machine")
        plt.show()
    
    except Exception as e:
        messagebox.showerror("Error", f"An error occurred: {e}")

# Create main window
root = tk.Tk()
root.title("Manufacturing Downtime Analysis")
root.geometry("600x400")

# Header
header_label = tk.Label(root, text="Manufacturing Downtime Analysis", font=("Arial", 18))
header_label.pack(pady=10)

# Instructions
instructions_label = tk.Label(root, text="Click the button to analyze downtime data", font=("Arial", 12))
instructions_label.pack(pady=5)

# Button to trigger analysis
analyze_button = tk.Button(root, text="Analyze Data", font=("Arial", 14), command=analyze_data)
analyze_button.pack(pady=20)

# Text to display analysis results
result_text = tk.StringVar()
result_label = tk.Label(root, textvariable=result_text, font=("Arial", 10), justify="left")
result_label.pack(pady=10)

# Start the GUI event loop
root.mainloop()
