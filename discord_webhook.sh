JOB_URL="$GITHUB_API_URL/repos/$GITHUB_REPOSITORY/actions/runs/$GITHUB_RUN_ID/jobs"

function getResults() {
  curl -L $JOB_URL \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer $GITHUB_TOKEN" \
    -H "X-GitHub-Api-Version: 2022-11-28"
}

RESULTS=`getResults | jq '[ .jobs[] | select(.name | contains("refresh_token")) | "\(if .conclusion == "success" then "☑️" else "❎" end) \(.name[15:-1])" ] | join("\n")'`

read -d '' REQ_BODY <<EOF
  {
    "username": "E5 Refresh Results",
    "content": "${RESULTS:1:-1}\\\\n\\\\nLast Run: <t:`date "+%s"`:R>"
  }
EOF

curl -X PATCH -H "Content-Type: application/json" -d "$REQ_BODY" $DISCORD_WEBHOOK 1> /dev/null