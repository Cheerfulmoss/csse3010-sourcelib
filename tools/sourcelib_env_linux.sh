export SOURCELIB_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export PATH="$SOURCELIB_ROOT/tools:$PATH"
export PATH="$HOME/.local/bin:$PATH"

if [ -d /opt/SEGGER/JLink ]; then
    export PATH="/opt/SEGGER/JLink:$PATH"
fi
