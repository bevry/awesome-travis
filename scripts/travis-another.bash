#!/bin/bash
set -ueE -o pipefail

# Trigger another travis projects tests after completion of the current travis project.
# Useful for when you have a content repository that is used by a different repository,
# and as such, when the content repository changes, you want to rerun the tests for the other repository,
# perhaps even for deployment purposes.


# TRAVIS SCRIPT
#
# sudo: false
# language: ruby
# rvm:
#   - "2.2"
# install:
#   - gem install travis --no-rdoc --no-ri
# script:
#   - eval "$(curl -s https://raw.githubusercontent.com/bevry/awesome-travis/master/scripts/travis-another.bash)"


# TRAVIS ENVIRONMENT VARIABLES
#
# GITHUB_TRAVIS_TOKEN
# Specify your [GitHub Personal Access Token](https://help.github.com/articles/creating-an-access-token-for-command-line-use/) with the `repo` permission.
# travis env set GITHUB_TRAVIS_TOKEN "$GITHUB_TRAVIS_TOKEN"
#
# OTHER_REPO_SLUG
# Specify the other repository to trigger the travis tests for:
# travis env set OTHER_REPO_SLUG "bevry/staticsitegenerators-website" --public


# Set Local Environment Variables
export TRAVIS_ACCESS_TOKEN

# Run
if test -n "$GITHUB_TRAVIS_TOKEN"; then
	echo "pinging $OTHER_REPO_SLUG..."

	# install deps in case they are missing, this can happen if this script runs in combination with others
	if ! type "gem"; then
		rvm install 2.2
	fi
	if ! type "travis"; then
		gem install travis --no-rdoc --no-ri
	fi

	# This should be easier but https://github.com/travis-ci/travis.rb/issues/315 is a thing. Also don't use --debug on `travis login` as that will output the github token.
	travis login --skip-completion-check --org --github-token "$GITHUB_TRAVIS_TOKEN"
	TRAVIS_ACCESS_TOKEN="$(grep access_token < ~/.travis/config.yml | sed 's/ *access_token: *//')"
	travis restart --debug --skip-completion-check --org -r "$OTHER_REPO_SLUG" -t "$TRAVIS_ACCESS_TOKEN"

	echo "pinged $OTHER_REPO_SLUG"
else
	echo "skipped ping $OTHER_REPO_SLUG"
fi
