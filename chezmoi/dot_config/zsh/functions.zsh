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

mkcd() {
  mkdir -p "$1" && cd "$1"
}


# Redact common secrets/PII from stdin or args before sharing.
# Usage:
#   pbpaste | desecret | pbcopy
#   desecret "my token is ghp_abc123..."
#   echo "$VAR" | desecret
desecret() {
  local input
  if [[ -n "$1" ]]; then
    input="$*"
  else
    input="$(cat)"
  fi

  print -r -- "$input" | perl -pe '
    # JWTs (three base64url segments separated by dots)
    s/\beyJ[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+/[JWT_REDACTED]/g;

    # GitHub tokens (ghp_, gho_, ghu_, ghs_, ghr_)
    s/\bgh[pousr]_[A-Za-z0-9]{36,}/[GITHUB_TOKEN_REDACTED]/g;

    # AWS access key IDs and secret keys
    s/\bAKIA[0-9A-Z]{16}\b/[AWS_ACCESS_KEY_REDACTED]/g;
    s/\b(aws_secret_access_key\s*[=:]\s*)["'\'']?[A-Za-z0-9\/+=]{40}["'\'']?/$1[AWS_SECRET_REDACTED]/gi;

    # Anthropic and OpenAI style keys (Anthropic first so it gets the specific label)
    s/\bsk-ant-[A-Za-z0-9_-]{20,}/[ANTHROPIC_KEY_REDACTED]/g;
    s/\bsk-[A-Za-z0-9_-]{20,}/[OPENAI_KEY_REDACTED]/g;

    # Slack tokens
    s/\bxox[baprs]-[A-Za-z0-9-]{10,}/[SLACK_TOKEN_REDACTED]/g;

    # Stripe keys
    s/\b(sk|pk|rk)_(live|test)_[A-Za-z0-9]{20,}/[STRIPE_KEY_REDACTED]/g;

    # Google API keys
    s/\bAIza[0-9A-Za-z_-]{35}\b/[GOOGLE_API_KEY_REDACTED]/g;

    # Generic bearer tokens in headers
    s/(Bearer\s+)[A-Za-z0-9._-]{20,}/$1[BEARER_TOKEN_REDACTED]/gi;
    s/(Authorization:\s*\w+\s+)[A-Za-z0-9._-]{20,}/$1[AUTH_REDACTED]/gi;

    # Generic high-entropy key=value pairs (api_key, token, secret, password)
    s/((?:api[_-]?key|token|secret|password|passwd|pwd)\s*[=:]\s*)["'\'']?[A-Za-z0-9._\/+=-]{12,}["'\'']?/$1[REDACTED]/gi;

    # PEM-encoded private keys
    s/-----BEGIN [A-Z ]*PRIVATE KEY-----[\s\S]*?-----END [A-Z ]*PRIVATE KEY-----/[PRIVATE_KEY_REDACTED]/g;
  '
}