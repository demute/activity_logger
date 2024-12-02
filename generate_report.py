import os

# Path to your logfile
logfile_path = 'activity.log'

# Read and parse the logfile
data = []
with open(logfile_path, 'r') as f:
    for line in f:
        line = line.strip()
        if not line:
            continue
        parts = line.split(';')
        if len(parts) < 2:
            continue  # Skip lines that don't have enough parts
        timestamp = parts[0]
        title = parts[1]
        data.append({'timestamp': timestamp, 'title': title})

# Aggregate data
from collections import defaultdict

title_counts = defaultdict(int)
for entry in data:
    title = entry['title']
    title_counts[title] += 1

# Find the maximum count for scaling
max_count = max(title_counts.values())

# HTML generation
html_content = '''
<!DOCTYPE html>
<html>
<head>
    <style>
        body {
            background-color: black;
            color: white;
            font-family: Arial, sans-serif;
        }
        .bar-container {
            display: flex;
            align-items: center;
            margin-bottom: 10px;
        }
        .bar-label {
            width: 200px;
            text-align: left;
            margin-right: 10px;
            word-wrap: break-word;
        }
        .bar {
            height: 20px;
            margin-right: 10px;
            flex-shrink: 0;
        }
        .time-label {
            margin-left: 10px;
            min-width: 80px;
            text-align: right;
        }
        h2 {
            border-bottom: 1px solid #444;
            padding-bottom: 5px;
        }
        pre {
            background-color: #222;
            padding: 10px;
            border-radius: 5px;
            overflow-x: auto;
        }
        .bar-percentage {
            min-width: 50px;
            text-align: right;
            margin-left: 10px;
            color: #aaa;
        }
    </style>
</head>
<body>
    <h2>Activity Report</h2>
'''

# Generate bars
total_entries = sum(title_counts.values())
for title, count in sorted(title_counts.items(), key=lambda x: x[1], reverse=True):
    # Calculate bar width percentage
    width_percent = (count / max_count) * 70  # 70% of container width
    color = 'orange'  # Default for UNKNOWN
    # Convert count to hours and minutes
    total_minutes = count
    hours = total_minutes // 60
    minutes = total_minutes % 60
    if hours > 0 and minutes > 0:
        time_str = f"{hours}h {minutes}m"
    elif hours > 0:
        time_str = f"{hours} hours"
    else:
        time_str = f"{minutes} minutes"
    # Calculate percentage
    percentage = (count / total_entries) * 100
    percentage_str = f"{percentage:.1f}%"
    # Add bar to HTML
    html_content += f'''
    <div class="bar-container">
        <div class="bar-label">{title}</div>
        <div class="bar" style="background-color:{color}; width:{width_percent}%;"></div>
        <div class="time-label">{time_str}</div>
        <div class="bar-percentage">{percentage_str}</div>
    </div>
    '''

# Add the raw logfile content in reverse order
html_content += '''
    <h2>Raw Logfile</h2>
    <pre>
'''

with open(logfile_path, 'r') as f:
    logfile_lines = f.readlines()
    reversed_lines = logfile_lines[::-1]  # Reverse the list of lines
    logfile_content = ''.join(reversed_lines)
    html_content += logfile_content

html_content += '''
    </pre>
</body>
</html>
'''

# Write the HTML content to a file
output_html_path = 'activity_report.html'
with open(output_html_path, 'w') as f:
    f.write(html_content)

print(f"HTML report generated at {output_html_path}")

