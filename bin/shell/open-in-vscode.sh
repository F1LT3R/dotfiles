#!/bin/bash
# Extract file path, line, and column from the URL
INPUT=$(echo "$1" | sed 's|file://||')
FILE=$(echo "$INPUT" | cut -d ':' -f 1)
LINE=$(echo "$INPUT" | cut -d ':' -f 2)
COLUMN=$(echo "$INPUT" | cut -d ':' -f 3)

# Open the file in VS Code with line and column
code --goto "$FILE:$LINE:$COLUMN"
