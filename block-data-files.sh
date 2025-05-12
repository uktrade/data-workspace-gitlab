#!/bin/bash

# this pre-receive hook checks for data files within all commits during push
# and posts a warning message with listing all suspected files

disallowed_extensions="csv|tsv|xlsx|xls|parquet|json|xml|png|pdf|rdata"
disallowed_files=""

while read oldrev newrev refname; do
  # Skip branch deletes
  if [ "$newrev" = "0000000000000000000000000000000000000000" ]; then
    continue
  fi

  # Handle new branches (nothing to diff from)
  if [ "$oldrev" = "0000000000000000000000000000000000000000" ]; then
    changed_files=$(git diff-tree --no-commit-id --name-only -r "$newrev")
  else
    changed_files=$(git diff --name-only "$oldrev" "$newrev")
  fi

  for file in $changed_files; do
    lowercase_file=$(echo "$file" | tr '[:upper:]' '[:lower:]')
    if [[ "$lowercase_file" =~ \.($disallowed_extensions)$ ]]; then
      disallowed_files+="$file"$'\n'
    fi
  done
done

if [[ -n "$disallowed_files" ]]; then
  echo "************************************************************************************"
  echo "WARNING: The following files are suspected to contain data:"
  echo
  echo "$disallowed_files"
  echo
  echo "There are very limited cases when data is allowed to be stored in GitLab. See"
  echo "https://data-services-help.trade.gov.uk/data-workspace/add-share-and-manage-data/manage-data/avoid-a-data-breach-store-your-data-securely-on-data-workspace/"
  echo
  echo "for more information. If this data is not an allowed case, please contact the Data"
  echo "Workspace Team at https://data.trade.gov.uk/contact-us/ who can help to remove it."
  echo "************************************************************************************"
fi

exit 0
