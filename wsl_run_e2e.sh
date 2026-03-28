#!/usr/bin/env bash
set -euo pipefail

# WSL Ubuntu E2E runner for Personal Finance Manager
# - Installs Java 17, Maven, curl, bc if missing
# - Builds and starts the Spring Boot app
# - Waits until port 8080 responds
# - Runs financial_manager_tests.sh
# - Cleans up app process

PROJECT_DIR="/mnt/c/Users/Vishakha/OneDrive/Desktop/Personal_Finance_Manager-main/Personal_Finance_Manager-main"
APP_LOG="/tmp/pfm_app.log"
WAIT_SECONDS=120
BASE_URL="http://localhost:8080"

red() { echo -e "\033[31m$*\033[0m"; }
green() { echo -e "\033[32m$*\033[0m"; }
yellow() { echo -e "\033[33m$*\033[0m"; }

require_cmd() {
	local cmd="$1"; local pkg="$2"
	if ! command -v "$cmd" >/dev/null 2>&1; then
		yellow "Installing $pkg (missing $cmd)..."
		sudo apt-get install -y "$pkg"
	fi
}

cleanup() {
	if [[ -n "${APP_PID:-}" ]] && ps -p "$APP_PID" >/dev/null 2>&1; then
		yellow "Stopping app (PID $APP_PID)..."
		kill "$APP_PID" || true
		sleep 3
		if ps -p "$APP_PID" >/dev/null 2>&1; then
			yellow "Force killing app (PID $APP_PID)..."
			kill -9 "$APP_PID" || true
		fi
	fi
}
trap cleanup EXIT

if ! grep -qi microsoft /proc/version; then
	red "This script is intended to run inside WSL (Ubuntu)."
	exit 1
fi

sudo apt-get update -y
require_cmd java openjdk-17-jdk
require_cmd mvn maven
require_cmd curl curl
require_cmd bc bc

cd "$PROJECT_DIR"

yellow "Building the app (skip tests)..."


JAR_PATH="target/finance-manager-1.0.0.jar"
RUN_CMD=""
if [[ -f "$JAR_PATH" ]]; then
	RUN_CMD="java -jar \"$JAR_PATH\""
else
	RUN_CMD="mvn -q -DskipTests spring-boot:run"
fi

yellow "Starting Spring Boot app in background..."
nohup bash -c "$RUN_CMD" >"$APP_LOG" 2>&1 &
APP_PID=$!

yellow "Waiting for $BASE_URL to respond (timeout ${WAIT_SECONDS}s)..."
READY=0
for i in $(seq 1 "$WAIT_SECONDS"); do
	if curl -s -o /dev/null "$BASE_URL/api/auth/login"; then
		READY=1
		break
	fi
	sleep 1
done

if [[ "$READY" -ne 1 ]]; then
	red "App did not start within ${WAIT_SECONDS}s. Last log lines:"
	tail -n 200 "$APP_LOG" || true
	exit 1
fi

green "App is up. Running E2E tests..."
if [[ ! -f "$PROJECT_DIR/financial_manager_tests.sh" ]]; then
	red "E2E script not found at $PROJECT_DIR/financial_manager_tests.sh"
	exit 1
fi

bash "$PROJECT_DIR/financial_manager_tests.sh"
TEST_EXIT=$?

if [[ "$TEST_EXIT" -eq 0 ]]; then
	green "E2E tests PASSED."
else
	red "E2E tests FAILED (exit code $TEST_EXIT)."
	yellow "Last 200 lines of app log:"
	tail -n 200 "$APP_LOG" || true
fi

exit "$TEST_EXIT"
	TEST_EXIT=$?
