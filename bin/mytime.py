import sys
import os
import yaml
import subprocess
from datetime import datetime, timedelta
from pathlib import Path
from collections import defaultdict

# Configuration
DATA_FILE = Path.home() / ".mytime_data.yaml"

def load_data():
    """Load and validate the YAML data file."""
    if not DATA_FILE.exists():
        initial_data = {"aliases": {"stop": "Break/End of Day"}, "logs": []}
        save_data(initial_data)
        return initial_data
    
    try:
        with open(DATA_FILE, 'r') as f:
            content = yaml.safe_load(f)
            if not isinstance(content, dict) or "aliases" not in content or "logs" not in content:
                print("⚠️ Warning: YAML structure corrupted. Resetting to defaults.")
                return {"aliases": {"stop": "Break/End of Day"}, "logs": []}
            return content
    except yaml.YAMLError as e:
        print(f"❌ YAML Syntax Error in {DATA_FILE}:\n{e}")
        print("\nFix the file manually (mt -e) or delete it to reset.")
        sys.exit(1)

def save_data(data):
    """Save the current state to the YAML file."""
    try:
        with open(DATA_FILE, 'w') as f:
            yaml.dump(data, f, sort_keys=False, default_flow_style=False)
    except Exception as e:
        print(f"❌ Error saving data: {e}")

def log_switch(data, alias, comment=""):
    """Register a new timestamp for a task switch."""
    if alias not in data["aliases"]:
        print(f"Error: Alias '{alias}' not found. Use 'mt -l' to see available aliases.")
        return
    now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    data["logs"].append({"timestamp": now, "alias": alias, "comment": comment})
    save_data(data)
    print(f"✅ [{now}] -> {alias} ({data['aliases'][alias]})")

def show_current_status(data):
    """Display the currently active task and duration."""
    if not data["logs"]:
        print("No tasks logged yet. Use 'mt -s <alias>' to start.")
        return

    last_log = data["logs"][-1]
    alias = last_log["alias"]
    
    if alias == "stop":
        print("Currently: ⏸  On a break / Stopped.")
        return

    fmt = "%Y-%m-%d %H:%M:%S"
    start_t = datetime.strptime(last_log["timestamp"], fmt)
    elapsed = datetime.now() - start_t
    
    hours, rem = divmod(int(elapsed.total_seconds()), 3600)
    mins, _ = divmod(rem, 60)
    
    desc = data["aliases"].get(alias, "No description")
    comment = f" | Comment: {last_log['comment']}" if last_log.get('comment') else ""
    
    print(f"Currently: 🚀 {alias} ({desc})")
    print(f"Active for: {hours}h {mins}m{comment}")

def show_report(data, days_back):
    """Generate a daily usage report grouped by date."""
    try:
        days = float(days_back)
    except ValueError:
        print("Error: -d requires a number."); return

    cutoff = datetime.now() - timedelta(days=days)
    fmt = "%Y-%m-%d %H:%M:%S"
    daily_usage = defaultdict(lambda: defaultdict(timedelta))
    
    logs = data["logs"]
    if not logs:
        print("No logs found."); return

    for i in range(len(logs)):
        start_t = datetime.strptime(logs[i]["timestamp"], fmt)
        
        # Determine logical start (handle cutoff window)
        if start_t < cutoff:
            if i + 1 < len(logs) and datetime.strptime(logs[i+1]["timestamp"], fmt) > cutoff:
                start_t = cutoff
            else:
                continue
            
        end_t = datetime.strptime(logs[i+1]["timestamp"], fmt) if i+1 < len(logs) else datetime.now()
        alias = logs[i]["alias"]
        
        if alias == "stop": continue

        # Handle crossing midnight for accurate daily totals
        current_cursor = start_t
        while current_cursor.date() < end_t.date():
            midnight = datetime.combine(current_cursor.date() + timedelta(days=1), datetime.min.time())
            daily_usage[current_cursor.strftime("%Y-%m-%d (%a)")][alias] += (midnight - current_cursor)
            current_cursor = midnight
            
        daily_usage[current_cursor.strftime("%Y-%m-%d (%a)")][alias] += (end_t - current_cursor)

    print(f"\n--- DAILY REPORT (Last {days} days) ---")
    for date_str in sorted(daily_usage.keys(), reverse=True):
        print(f"\n📅 {date_str}")
        print(f"  {'ALIAS':<15} | {'TIME':<10} | {'DESCRIPTION'}")
        print("  " + "-" * 50)
        day_total = timedelta()
        for alias, td in sorted(daily_usage[date_str].items(), key=lambda x: x[1], reverse=True):
            h, r = divmod(int(td.total_seconds()), 3600)
            print(f"  {alias:<15} | {h:>2}h {r//60:>2}m  | {data['aliases'].get(alias, '')}")
            day_total += td
        
        th, tr = divmod(int(day_total.total_seconds()), 3600)
        print(f"  {'TOTAL':<15} | {th:>2}h {tr//60:>2}m")

def show_help():
    """Print the user guide."""
    print(f"""
📅 mytime (mt) - Simple CLI Time Tracker
Usage:
  mt                         Show currently active task and duration
  mt -a <alias> "<desc>"     Register a new task alias
  mt -a <alias> "<desc>" -s  Register and switch to it immediately
  mt -s <alias>              Switch to a task (starts the timer)
  mt -s <alias> -c "note"    Switch to a task with a custom comment
  mt -l                      List all registered aliases
  mt -d <days>               Show daily report (e.g., mt -d 1)
  mt -e                      Open YAML data file in default editor
  mt stop                    Stop current timer (break/end of day)
  mt -h, -?, --help          Show this help menu

Data: {DATA_FILE}
    """)

def main():
    data = load_data()
    args = sys.argv[1:]
    
    if not args:
        show_current_status(data)
        return

    cmd = args[0]

    if cmd in ["-h", "-?", "--help"]:
        show_help()
    
    elif cmd == "-a":
        try:
            alias, desc = args[1], args[2]
            data["aliases"][alias] = desc
            if "-s" in args or (len(args) > 3 and args[3] == "-s"):
                log_switch(data, alias)
            else:
                save_data(data)
                print(f"Registered alias: {alias}")
        except IndexError:
            print("Error: -a requires an alias and a description.")

    elif cmd == "-s":
        try:
            alias = args[1]
            comment = ""
            if "-c" in args:
                idx = args.index("-c")
                if idx + 1 < len(args):
                    comment = args[idx + 1]
            log_switch(data, alias, comment)
        except IndexError:
            print("Error: -s requires an alias.")

    elif cmd == "-l":
        print(f"\n{'ALIAS':<12} | {'DESCRIPTION'}")
        print("-" * 45)
        for a, d in sorted(data["aliases"].items()):
            print(f"{a:<12} | {d}")

    elif cmd == "-e":
        editor = os.environ.get('EDITOR', 'nano')
        subprocess.call([editor, str(DATA_FILE)])
        print("Manual edits saved.")

    elif cmd == "-d":
        days = args[1] if len(args) > 1 else 1
        show_report(data, days)
            
    elif cmd == "stop":
        log_switch(data, "stop", "Session ended")
    
    else:
        print(f"Unknown command: {cmd}")
        show_help()

if __name__ == "__main__":
    main()