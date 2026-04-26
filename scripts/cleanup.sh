#!/bin/bash
# SPDX-License-Identifier: GPL-2.0
#
# Clean up stale GitHub Actions workflow runs and pull requests.

set -euo pipefail

readonly DEFAULT_AGE=14
readonly DEFAULT_REPO="linux-mm/linux-mm"
readonly BATCH_SIZE=1000

usage() {
	echo "Usage: $(basename "$0") [-a DAYS] [-r OWNER/REPO] [-n] [-h]"
	echo ""
	echo "Clean up stale workflow runs and pull requests."
	echo ""
	echo "Options:"
	echo "	-a DAYS		Age threshold in days (default: $DEFAULT_AGE)"
	echo "	-r OWNER/REPO	Target repository (default: $DEFAULT_REPO)"
	echo "	-n		Dry run: show what would be done"
	echo "	-h		Show this help message"
	exit 0
}

delete_runs() {
	local ids=$1

	for run_id in $ids; do
		if $dry_run; then
			echo "Would delete run $run_id"
			deleted=$((deleted + 1))
			continue
		fi

		if gh run delete "$run_id" --repo "$repo" 2>/dev/null; then
			echo "Deleted run $run_id"
			deleted=$((deleted + 1))
		else
			echo "Failed to delete run $run_id" >&2
			failed=$((failed + 1))
		fi
	done
}

cleanup_workflow_runs() {
	local deleted=0
	local failed=0

	echo "Cleaning up completed workflow runs older than $age days (before $cutoff)"
	$dry_run && echo "DRY RUN: no runs will be deleted"

	while true; do
		local run_ids
		run_ids=$(gh run list \
			--repo "$repo" \
			--status completed \
			--json databaseId,createdAt \
			--jq '[.[] | select(.createdAt < "'"$cutoff"'")] | .[].databaseId' \
			--limit $BATCH_SIZE)

		if [[ -z "$run_ids" ]]; then
			break
		fi

		delete_runs "$run_ids"

		# In dry-run mode nothing is deleted, so the list won't shrink.
		$dry_run && break
	done

	echo "Done: $deleted runs deleted, $failed failures"
}

close_prs() {
	local numbers=$1

	for pr_number in $numbers; do
		if $dry_run; then
			echo "Would close PR #$pr_number"
			closed=$((closed + 1))
			continue
		fi

		if gh pr close "$pr_number" --repo "$repo" 2>/dev/null; then
			echo "Closed PR #$pr_number"
			closed=$((closed + 1))
		else
			echo "Failed to close PR #$pr_number" >&2
			failed=$((failed + 1))
		fi
	done
}

cleanup_pull_requests() {
	local closed=0
	local failed=0

	echo "Closing pull requests not updated since $cutoff ($age days)"
	$dry_run && echo "DRY RUN: no pull requests will be closed"

	while true; do
		local pr_numbers
		pr_numbers=$(gh pr list \
			--repo "$repo" \
			--state open \
			--json number,updatedAt \
			--jq '[.[] | select(.updatedAt < "'"$cutoff"'")] | .[].number' \
			--limit $BATCH_SIZE)

		if [[ -z "$pr_numbers" ]]; then
			break
		fi

		close_prs "$pr_numbers"

		# In dry-run mode nothing is closed, so the list won't shrink.
		$dry_run && break
	done

	echo "Done: $closed pull requests closed, $failed failures"
}

main() {
	age=$DEFAULT_AGE
	repo=$DEFAULT_REPO
	dry_run=false

	while getopts "a:r:nh" opt; do
		case "$opt" in
		a)
			age="$OPTARG"
			;;
		r)
			repo="$OPTARG"
			;;
		n)
			dry_run=true
			;;
		h)
			usage
			;;
		*)
			usage
			;;
		esac
	done

	cutoff=$(date -u -d "$age days ago" +%Y-%m-%dT%H:%M:%SZ)

	echo "Repository: $repo"
	cleanup_workflow_runs
	cleanup_pull_requests
}

main "$@"
