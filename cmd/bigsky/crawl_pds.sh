set -e              # fail on error
set -u              # fail if variable not set in substitution
set -o pipefail     # fail if part of a '|' command fails

if test -z "${RELAY_ADMIN_KEY}"; then
    echo "RELAY_ADMIN_KEY secret is not defined"
    exit -1
fi

if test -z "${RELAY_HOST}"; then
    echo "RELAY_HOST config not defined"
    exit -1
fi

if test -z "$1"; then
    echo "expected PDS hostname as an argument"
    exit -1
fi

# NOTE01 -> Relay 启动爬取时 需要调用这个接口
# idea01 -> RELAY_HOST 可以用 localhost 代替吗？（https -> http）
# 验证 -> 可以
echo "requestCrawl $1"
http --quiet --ignore-stdin post http://${RELAY_HOST}/admin/pds/requestCrawl Authorization:"Bearer ${RELAY_ADMIN_KEY}" \
	hostname=$1

echo "changeLimits $1"
http --quiet --ignore-stdin post http://${RELAY_HOST}/admin/pds/changeLimits Authorization:"Bearer ${RELAY_ADMIN_KEY}" \
	per_second:=100 \
	per_hour:=1000000 \
	per_day:=1000000 \
	crawl_rate:=10 \
	repo_limit:=1000000 \
	host=$1
