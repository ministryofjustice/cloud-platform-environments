#!/bin/bash

# This script is used to generate a CODEOWNERS file for the environments repo
normal="$(tput sgr0)"
red="$(tput setaf 1)"
green="$(tput setaf 2)"

# To test the script locally, uncomment the following two lines
base_repo_dir=..

# To test the script locally, comment out the following two lines
# env_repo_dir=~
namespace_dir=/namespaces/
codeowners_file=${base_repo_dir}/.github/CODEOWNERS

generate_teams() {

  local cluster=$1
  array=($(find ${base_repo_dir}${namespace_dir}${cluster} -mindepth 1 -maxdepth 1 -type d -exec basename {} \;))

  echo -e "\n## Codeowners for ${cluster} namespaces" >> $codeowners_file
  for i in "${array[@]}"
  do
    case $i in
      "monitoring"|"trivy-system")
        team="@ministryofjustice/webops"
        ;;
      *)
        t=$(cat ${base_repo_dir}${namespace_dir}${cluster}/${i}/*namespace.yaml | grep -i "cloud-platform.justice.gov.uk/team-name: " | cut -d '"' -f2)
        if [[ ${t} == "webops" || ${t} == "" ]]; then
          team="@ministryofjustice/webops"
        else { 
          team="@ministryofjustice/${t} @ministryofjustice/webops"
        }
        fi
        ;;
    esac
    echo "Adding codeowners for $i"
    echo "${namespace_dir}${cluster}/$i ${team}" >> $codeowners_file
  done
}

generate_codeowners_file() {

# find all the namespaces in the live.cloud-platform.service.justice.gov.uk directory and add them to an array
echo "Writing codeowners file"
# Creates a codeowners file in the environments repo to ensure only teams can approve PRs referencing their code
cat > $codeowners_file << EOL
# This file is auto-generated here, do not manually amend.


* @ministryofjustice/webops
EOL
array=("live.cloud-platform.service.justice.gov.uk" "live-2.cloud-platform.service.justice.gov.uk")
for cluster in ${array[@]}
do
  generate_teams "${cluster}"
done
}
generate_codeowners_file