import os
import re
import shutil
import sys
from pathlib import Path

# --- Configuration ---
# ATTACHMENT_FOLDER_NAME is the standard subfolder name within each JD folder (e.g., '40.53 Specific use cases/Attachments')
ATTACHMENT_FOLDER_NAME = 'Attachments'

def find_jd_target_directory(jd_root: Path, jd_id: str) -> Path | None:
    """
    Finds the target JD folder (e.g., '40.53 Specific use cases') within the JD root.

    Args:
        jd_root: The root path where the JD system starts (e.g., 'Personal/').
        jd_id: The Johnny.Decimal ID (e.g., '40.53').

    Returns:
        The Path object for the target Attachments folder, or None if not found.
    """
    print(f"Searching for Johnny.Decimal ID '{jd_id}' in '{jd_root}'...")
    
    # 1. Split the JD ID into category (e.g., '40') and specific ID (e.g., '40.53')
    if '.' not in jd_id:
        print("Error: JD ID must contain a decimal point (e.g., '40.53').")
        return None
        
    category_id = jd_id.split('.')[0]
    
    # 2. Find the Category folder (e.g., '40 Kuberntes/')
    category_folder = None
    try:
        # Search directly in jd_root for a folder starting with 'category_id '
        for item in jd_root.iterdir():
            if item.is_dir() and item.name.startswith(f"{category_id} "):
                category_folder = item
                break
    except FileNotFoundError:
        print(f"Error: JD Root directory not found at '{jd_root}'. Check your path.")
        return None
    except PermissionError:
        print(f"Error: Permission denied accessing '{jd_root}'.")
        return None

    if not category_folder:
        print(f"Error: Could not find Category folder starting with '{category_id}' in '{jd_root}'.")
        return None

    print(f"Found Category Folder: {category_folder.name}")

    # 3. Find the specific JD ID folder (e.g., '40.53 Specific use cases/')
    jd_folder = None
    for item in category_folder.iterdir():
        if item.is_dir() and item.name.startswith(f"{jd_id} "):
            jd_folder = item
            break
            
    if not jd_folder:
        print(f"Error: Could not find JD ID folder starting with '{jd_id}' in '{category_folder}'.")
        return None

    print(f"Found JD Folder: {jd_folder.name}")

    # 4. Check for the Attachments subfolder
    attachments_dir = jd_folder / ATTACHMENT_FOLDER_NAME
    if not attachments_dir.exists():
        print(f"Creating missing Attachments folder: '{attachments_dir}'")
        try:
            attachments_dir.mkdir(parents=True, exist_ok=True)
        except OSError as e:
            print(f"Error creating Attachments directory: {e}")
            return None
    
    return attachments_dir

def get_next_sequence_number(attachments_dir: Path, jd_id: str) -> str:
    """
    Scans the attachments directory to find the next available sequence number.
    Files are expected to be named like '40.53.001 My File.pdf'.

    Args:
        attachments_dir: The target Attachments folder path.
        jd_id: The Johnny.Decimal ID (e.g., '40.53').

    Returns:
        The next 3-digit sequence number as a string (e.g., '003').
    """
    max_sequence = 0
    # Regex to match the JD ID followed by a 3-digit sequence number, 
    # e.g., '40.53.001' at the start of the filename.
    pattern = re.compile(rf'^{re.escape(jd_id)}\.(\d{{3}})')

    for filename in os.listdir(attachments_dir):
        match = pattern.match(filename)
        if match:
            # Extract the sequence number as an integer
            sequence_number = int(match.group(1))
            if sequence_number > max_sequence:
                max_sequence = sequence_number

    next_sequence = max_sequence + 1
    # Format as a 3-digit string (e.g., 1 -> '001')
    return f"{next_sequence:03d}"

def process_attachment(jd_id: str, source_file_path: str, jd_root_path: str):
    """
    The main orchestration function to find the folder, rename the file, and move it.
    """
    source_path = Path(source_file_path).resolve()
    # Resolve the JD root path, handling tilde expansion (~)
    jd_root = Path(jd_root_path).expanduser().resolve()

    if not source_path.exists():
        print(f"Error: Source file not found at '{source_path}'")
        return

    # Step 1: Find the target Attachments folder
    attachments_dir = find_jd_target_directory(jd_root, jd_id)

    if not attachments_dir:
        print("Process aborted. Target directory could not be located or created.")
        return

    # Step 2: Determine the next sequence number
    next_sequence = get_next_sequence_number(attachments_dir, jd_id)
    
    # Extract the original filename extension
    original_filename = source_path.name
    # Remove any existing JD prefix in case the file was partially named
    cleaned_name = re.sub(rf'^{re.escape(jd_id)}\.\d{{3}} ', '', original_filename) 

    # Step 3: Construct the final new filename
    new_filename = f"{jd_id}.{next_sequence} {cleaned_name}"
    destination_path = attachments_dir / new_filename

    # Step 4: Move and rename the file
    print(f"\n--- Moving File ---")
    print(f"Source: {source_path}")
    print(f"Target: {destination_path}")

    try:
        shutil.move(source_path, destination_path)
        print("\n✅ Success!")
        print(f"File moved and renamed to: {new_filename}")
        print(f"Obsidian Link Key (for link-by-name): {jd_id}.{next_sequence}")
    except shutil.Error as e:
        print(f"Error moving file: {e}")
    except Exception as e:
        print(f"An unexpected error occurred: {e}")


def main():
    """Handles command-line arguments."""
    # This script requires the JD ID, the source file path, and the JD root path.
    if len(sys.argv) != 4:
        # Note: JD ID should be quoted if running from shell, e.g., './script.py "40.53" ...'
        print(f"Usage: python {sys.argv[0]} <JD_ID> <SOURCE_FILE_PATH> <JD_ROOT_PATH>")
        print("\n<JD_ID>: The full Johnny.Decimal number (e.g., '40.53')")
        print("<SOURCE_FILE_PATH>: Absolute or relative path to the file to move (e.g., '~/Downloads/My File.pdf')")
        print("<JD_ROOT_PATH>: Absolute path to the folder containing your JD categories (e.g., '~/iCloud/Personal')")
        print("\nExample:")
        print(f"python {sys.argv[0]} 40.53 ~/Downloads/report.pdf \"/Users/myuser/Library/Mobile Documents/com~apple~CloudDocs/Personal\"")
        sys.exit(1)

    jd_id = sys.argv[1]
    source_file_path = sys.argv[2]
    jd_root_path = sys.argv[3]

    if not re.match(r'^\d+\.\d+$', jd_id):
        print("Error: JD ID must be in the format XX.YY (e.g., 40.53).")
        sys.exit(1)

    process_attachment(jd_id, source_file_path, jd_root_path)

if __name__ == "__main__":
    main()

