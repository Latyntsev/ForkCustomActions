#!/bin/zsh
source ~/.bash_profile
git push

base_branch=$1
branch=$(git rev-parse --abbrev-ref HEAD)
response=$(curl -s "${tajawal_jira_url}/rest/api/2/issue/$branch" -u "$tajawal_jira_access_token" | sed 's#\\n##g;s#\\#\\\\#g')

title=$(echo $response | jq -r '.fields.summary')
type=$(echo $response | jq -r '.fields.issuetype.name')

assign="latyntsev"
reviewers="mohammad19991,thahirtajawal,Haneef-Habib"
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


# add PR title
if [ "$title" != "null" ]; then
	echo "$branch $title" > PR_MESSAGE
else
	git log -n 10 | grep $branch | head -1 | sed "s#    IOS-##g" > PR_MESSAGE
fi
echo "" >> PR_MESSAGE


# Build PR description
cat .github/PULL_REQUEST_TEMPLATE.md  >> PR_MESSAGE

echo "[$branch $title]($tajawal_jira_url/browse/$branch)" > TMP
sed -i -e '/Story Link/r TMP' PR_MESSAGE

git log -n 10 | grep $branch | sed "s#    $branch#*#g" > TMP
sed -i -e '/Implementation Details/r TMP' PR_MESSAGE

cat PR_MESSAGE
if [ -z "$label" ]; then
	# hub pull-request -b $base_branch -F PR_MESSAGE --no-edit -o -r $reviewers -a $assign
else
	# hub pull-request -b $base_branch -F PR_MESSAGE --no-edit -o -r $reviewers -a $assign -l $label
fi

rm -f PR_MESSAGE
rm -f PR_MESSAGE-e
rm -f PR_MESSAGE_DESCRIPTION
rm -f TMP
