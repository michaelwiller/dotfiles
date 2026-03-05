import sys
import os
import yaml
import subprocess
from datetime import datetime, timedelta
from pathlib import Path
from collections import defaultdict

DATA_FILE = Path.home() / ".mytime_data.yaml"

def load_data():
    if not DATA_FILE.exists():
        initial_data = {"aliases": {"stop": "Break/End of Day"}, "logs": []}
        save_data(initial_data)
        return initial_data
    
    try:
        with open(DATA_FILE, 'r') as f:
            content = yaml.safe_load(f)
            # Basic structural validation
            if not isinstance(content, dict) or "aliases" not in content or "logs" not in content:
                print("⚠️ Warning: YAML structure was corrupted. Resetting to defaults.")
                return {"aliases": {"stop": "Break/End of Day"}, "logs": []}
            return content
    except yaml.YAMLError as e:
        print(f"❌ YAML Syntax Error in {DATA_FILE}:\n{e}")
        print("\nFix the file manually or delete it to reset.")
        sys.exit(1)

def save_data(data):
    try:
        with open(DATA_FILE, 'w') as f:
            yaml.dump(data, f, sort_keys=False, default_flow_style=False)
    except Exception as e:
        print(f"❌ Error saving data: {e}")

def log_switch(data, alias, comment=""):
    if alias not in data["aliases"]:
        print(f"Error: Alias '{alias}' not found. Use 'mt -l' to see available aliases.")
        return
    now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    data["logs"].append({"timestamp": now, "alias": alias, "comment": comment})
    save_data(data)
    print(f"✅ [{now}] -> {alias} ({data['aliases'][alias]})")

def show_report(data, days_back):
    try:
        days = float(days_back)
    except ValueError:
        print("Error: -d requires a number."); return

    cutoff = datetime.now() - timedelta(days=days)
    fmt = "%Y-%m-%d %H:%M:%S"
    
    # Nested dictionary: daily_usage[date][alias] = duration
    daily_usage = defaultdict(lambda: defaultdict(timedelta))
    logs = data["logs"]
    
    if not logs:
        print("No logs found."); return

    for i in range(len(logs)):
        start_t = datetime.strptime(logs[i]["timestamp"], fmt)
        if start_t < cutoff:
            continue
        
        # Determine end of this specific segment
        end_t = datetime.strptime(logs[i+1]["timestamp"], fmt) if i+1 < len(logs) else datetime.now()
        
        # Calculate duration
        duration = end_t - start_t
        alias = logs[i]["alias"]
        date_str = start_t.strftime("%Y-%m-%d (%a)") # e.g., 2026-03-05 (Thu)

        if alias != "stop":
            # If a task spans across midnight, this simplified version attributes 
            # the whole block to the start date. 
            daily_usage[date_str][alias] += duration

    # Print the grouped report
    print(f"\n--- DAILY TIME USAGE (Last {days} days) ---")
    
    # Sort dates descending (newest first)
    for date in sorted(daily_usage.keys(), reverse=True):
        print(f"\n📅 {date}")
        print(f"{'  ALIAS':<15} | {'TIME':<15} | {'DESCRIPTION'}")
        print("  " + "-" * 45)
        
        day_total = timedelta()
        # Sort aliases by duration within that day
        for alias, td in sorted(daily_usage[date].items(), key=lambda x: x[1], reverse=True):
            hours, rem = divmod(int(td.total_seconds()), 3600)
            mins, _ = divmod(rem, 60)
            time_str = f"{hours}h {mins}m"
            desc = data["aliases"].get(alias, "")
            print(f"  {alias:<13} | {time_str:<15} | {desc}")
            day_total += td
            
        h, r = divmod(int(day_total.total_seconds()), 3600)
        print(f"  {'TOTAL':<13} | {h}h {r//60}m")

def show_current_status(data):
    if not data["logs"]:
        print("No tasks logged yet.")
        return

    last_log = data["logs"][-1]
    alias = last_log["alias"]
    
    if alias == "stop":
        print("Currently: ⏸  On a break / Stopped.")
        return

    # Calculate time elapsed since start
    fmt = "%Y-%m-%d %H:%M:%S"
    start_t = datetime.strptime(last_log["timestamp"], fmt)
    elapsed = datetime.now() - start_t
    
    hours, rem = divmod(int(elapsed.total_seconds()), 3600)
    mins, _ = divmod(rem, 60)
    
    desc = data["aliases"].get(alias, "No description")
    comment = f" | Comment: {last_log['comment']}" if last_log.get('comment') else ""
    
    print(f"Currently: 🚀 {alias} ({desc})")
    print(f"Active for: {hours}h {mins}m{comment}")

def main():
    data = load_data()
    args = sys.argv[1:]
    
    # NEW: Show status if no parameters are passed
    if not args:
        show_current_status(data)
        return

    cmd = args[0]

    # -a <alias> <desc> [-s]
    if cmd == "-a":
        try:
            alias, desc = args[1], args[2]
            data["aliases"][alias] = desc
            if "-s" in args:
                log_switch(data, alias)
            else:
                save_data(data)
                print(f"Registered alias: {alias}")
        except IndexError:
            print("Error: -a requires an alias and a description.")

    # -s <alias> [-c <comment>]
    elif cmd == "-s":
        try:
            alias = args[1]
            comment = args[args.index("-c") + 1] if "-c" in args else ""
            log_switch(data, alias, comment)
        except IndexError:
            print("Error: -s requires an alias.")

    # -l (list)
    elif cmd == "-l":
        print(f"\n{'ALIAS':<12} | {'DESCRIPTION'}")
        print("-" * 45)
        for a, d in data["aliases"].items():
            print(f"{a:<12} | {d}")

    # -e (edit)
    elif cmd == "-e":
        editor = os.environ.get('EDITOR', 'nano')
        print(f"Opening {DATA_FILE} in {editor}...")
        subprocess.call([editor, str(DATA_FILE)])
        # Re-validate after exit
        load_data() 

    # -d <days> (report)
    elif cmd == "-d":
        try:
            show_report(data, args[1])
        except IndexError:
            show_report(data, 1) # Default to 1 day if arg missing

if __name__ == "__main__":
    main()
