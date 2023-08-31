#!/bin/bash

PREV_VERSION=$(jq -r '.version' package.json)
echo "Prev Patch Version $PREV_VERSION"

# Split the version number into major, minor, and patch components
IFS='.' read -ra VERSION_ARRAY <<< "$PREV_VERSION"
echo "SPLITTING COMPLETED"
PATCH_VERSION="${VERSION_ARRAY[2]}"
PATCH_VERSION="${PATCH_VERSION}"
echo "CURRENT PATCH VERSION" $PATCH_VERSION

# Increment patch for new backport branch
((PATCH_VERSION++))
echo "UPDATED PATCH VERSION" $PATCH_VERSION

VERSION="${VERSION_ARRAY[0]}.${VERSION_ARRAY[1]}.${PATCH_VERSION}"

if [$BRANCH != "refs/heads/master"]; then
    BRANCH="${VERSION_ARRAY[0]}.${VERSION_ARRAY[1]}.x"
fi

echo "Version $VERSION"

echo "VERSION=$VERSION" >> $GITHUB_ENV
