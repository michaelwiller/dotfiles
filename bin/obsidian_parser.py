#
# Not ready
#
import os
import re
#import yaml

print("Program not ready. Exiting")
exit(0)

def parse_obsidian_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    properties = {}
    content = []
    in_frontmatter = False
    frontmatter_lines = []
    
    # Parse YAML frontmatter
    for i, line in enumerate(lines):
        if line.strip() == '---':
            if not in_frontmatter:
                in_frontmatter = True
            else:
                in_frontmatter = False
                frontmatter = ''.join(frontmatter_lines)
                properties = yaml.safe_load(frontmatter) or {}
                content = lines[i+1:]
                break
        elif in_frontmatter:
            frontmatter_lines.append(line)
    else:
        content = lines

    # Parse inline properties (e.g., "key:: value")
    for line in content:
        match = re.match(r'^([\w\s]+)::\s*(.+)$', line)
        if match:
            properties[match.group(1).strip()] = match.group(2).strip()

    # Extract backlinks ([[filename]])
    backlinks = set()
    link_pattern = re.compile(r'\[\[([^\]]+)\]\]')
    for line in content:
        for link in link_pattern.findall(line):
            backlinks.add(link.split('|')[0].strip())

    return {
        'properties': properties,
        'content': [l.strip() for l in content if l.strip()],
        'backlinks': list(backlinks)
    }

def parse_obsidian_folder(folder_path):
    all_files = {}
    for filename in os.listdir(folder_path):
        if filename.endswith('.md'):
            filepath = os.path.join(folder_path, filename)
            all_files[filename] = parse_obsidian_file(filepath)
    return all_files

# Example usage:
# all_notes = parse_obsidian_folder('/path/to/obsidian/folder')