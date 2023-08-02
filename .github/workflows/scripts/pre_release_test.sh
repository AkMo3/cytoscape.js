#!/bin/bash

# Make script exit on first failure
# set -e

# Check if VERSION variable is set
if [ -z "$VERSION" ]; then
  echo "VERSION variable is not set."
  exit 1;
else
  echo "VERSION is set to: $VERSION"
fi

# Check if current Git branch is named "master"
current_branch=$(git symbolic-ref --short HEAD 2>/dev/null)

if [ "$current_branch" = "master" ]; then
  echo "Current Git branch is unstable."
else
  echo "Current Git branch is not unstable."
  return 2;
fi


jq --arg ver "$VERSION" '.versions += [$ver]' ./documentation/versions.json >> /tmp/temp.json
mv /tmp/temp.json ./documentation/versions.json
npm run release

echo "Starting to check changed files"

# List the files  to check
files_to_check=("documentation/index.html" "documentation/js/cytoscape.min.js" "documentation/versions.json")

echo "files initialised"

git status

# Loop through the files
for file in "${files_to_check[@]}"
do
    echo "Checking $file"

    git status -s $file

    # Check if the file has changed
    output="$(git status -s $file)"

    echo "For $file, $output"

    if [ -z "$output" ]; then
        echo "The file $file has not changed."
        exit 1
    else
        echo "The file $file has changed."
    fi
done

git add . && git commit -m "Build $VERSION"

git log -n 1

npm version $VERSION --allow-same-version

git push && git push --tags

git remote -v

exit 0
