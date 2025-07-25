function kill-port {
    local port=$1
    local pids
    pids=$(lsof -t -i:$port)

    if [ -n "$pids" ]; then
        echo "Found process(es) on port $port:"
        echo "$pids"
        echo "$pids" | while read pid; do
            if [ -n "$pid" ]; then
                echo "Killing process $pid..."
                kill -9 "$pid"
                if [ $? -eq 0 ]; then
                else
                    echo "Failed to kill process $pid"
                fi
            fi
        done
    else
        echo "No process found on port $port"
    fi
}
