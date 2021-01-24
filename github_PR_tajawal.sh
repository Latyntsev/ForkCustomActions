#!/bin/zsh
source ~/.bash_profile
source ~/.zshrc

git push

branch=$(git rev-parse --abbrev-ref HEAD)
response=$(curl -s "${tajawal_jira_url}/rest/api/2/issue/$branch" -u "$tajawal_jira_access_token" | sed 's#\\n##g;s#\\#\\\\#g')
base_branch=$1

if [ -z "$base_branch" ]; then
	base_branch=$(git show-branch | grep '*' | grep -v "$(git rev-parse --abbrev-ref HEAD)" | head -n1 | sed 's/.*\[\(.*\)\].*/\1/' | sed 's/[\^~].*//')
fi

if [ "$base_branch" = "--legacy" ]; then 
	base_branch=$(echo $response | jq -r '.fields.parent.key')
fi

title=$(echo $response | jq -r '.fields.summary' | sed 's/^[ ]*//;s/[ ]*$//')
type=$(echo $response | jq -r '.fields.issuetype.name')

assign="${tajawal_github_author}"
reviewers="${tajawal_github_reviewers}"
if [ "$type" = "Story" ]; then
	label='Story Done'
fi
if [ "$type" = "Sub-task" ] || [ "$type" = "Task" ]; then
	label='Sub-task'
fi
if [ "$type" = "Bug" ] || [ "$type" = "Story bug" ]; then
	label='BUG'
fi

if [[ "$base_branch" == *"release"* ]]; then
	if [ -z "$label" ]; then
		label='Release'
	else
		label=$label',Release'
	fi
fi


# Build PR description
cat .github/PULL_REQUEST_TEMPLATE.md  >> PR_MESSAGE

echo "[**$branch $title**]($tajawal_jira_url/browse/$branch)" > TMP
sed -i -e '/Story Link/r TMP' PR_MESSAGE

git log -n 10 | grep $branch | sed "s#    $branch#*#g" > TMP
sed -i -e '/Implementation Details/r TMP' PR_MESSAGE

cat PR_MESSAGE

body=$(cat PR_MESSAGE)

if [ -z "$label" ]; then
	gh pr create --base $base_branch --title "$branch $title" --body "$body" --reviewer $reviewers --assignee $assign
else
	gh pr create --base $base_branch --title "$branch $title" --body "$body" --reviewer $reviewers --assignee $assign -l $label
fi

rm -f PR_MESSAGE
rm -f PR_MESSAGE-e
rm -f PR_MESSAGE_DESCRIPTION
rm -f TMP