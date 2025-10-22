#!/bin/bash
# Don't forget to set your default profile
# export AWS_DEFAULT_PROFILE=nomis-development

set -eo pipefail

# defaults
dryrun=false
max_age_months=1
region='eu-west-2'
valid_actions=("all" "delete" "unattached" "attached")

usage() {
  echo -e "Usage:\n $0 [<opts>] $(IFS='|'; echo "${valid_actions[*]}")
Where <opts>:
  -d                     Dryrun for delete command. Default: false
  -m <months>            Exclude volumes younger than this number of months. Default: 1
And:
  all                    List all volumes in the current account
  attached               List all attached volumes
  unattached.            List all unattached volumes
  delete                 Delete unattached volumes
"
}

main() {
  check_action
  set_date_cmd
  get_volumes
}

while getopts ":de:m:s:" opt; do
  case $opt in
    d) dryrun=true ;;
    m) max_age_months="$OPTARG" ;;
    s) shell_output="$OPTARG" ;;
    \?) echo "Invalid option: -$OPTARG" >&2; usage ;;
    :) echo "Option -$OPTARG requires an argument." >&2; usage ;;
  esac
done
shift $((OPTIND -1))
action=$1

check_action() {
  message="Scanning for $action EBS volumes older than $max_age_months months in $region..."
  case $action in
    all)
      filters=''
      none_message="No volumes found older than $max_age_months months in $region"
      ;;
    attached)
      filters='--filters Name=status,Values=in-use'
      none_message="No attached volumes found older than $max_age_months months in $region"
      ;;
    unattached)
      filters='--filters Name=status,Values=available'
      none_message="No unattached volumes found older than $max_age_months months in $region"
      ;;
    delete)
      filters='--filters Name=status,Values=available'
      if [[ "$dryrun" == true ]]; then
        message="Dryrun - Pretend deleting EBS volumes older than $max_age_months months in $region..."
      else
        message="Deleting EBS volumes older than $max_age_months months in $region..."
      fi
      none_message="No unattached volumes found older than $max_age_months months in $region to delete"
      ;;
    *)
      action=unattached
      filters='--filters Name=status,Values=available'
      message="Scanning for $action EBS volumes older than $max_age_months months in $region..."
      none_message="No unattached volumes found older than $max_age_months months in $region"
      ;;
  esac
}

set_date_cmd(){
  # use linux date command for reliable behaviour
  if [[ "$(uname)" == "Darwin" ]]; then
    if command -v gdate >/dev/null 2>&1; then
      date_cmd="gdate"  # macOS with coreutils installed
    else
      echo "exiting. First you need to run: brew install core-utils"
      exit 1
    fi
  else
    date_cmd="date" # linux
  fi
  now=$($date_cmd +%s)
}

find_reason_from_volume() {
  map=$1
  name=$2
  [[ "$map" == "None" ]] || reason='MAP' ; return
  [[ -n "$name" ]] && reason="$name" ; return
}

find_reason_from_snapshot() {
  snapshot_id=$1
  [[ "$snapshot_id" =~ ^snap- ]] || return
  if ! snapshot_info=$(aws ec2 describe-snapshots \
      --snapshot-ids "$snapshot_id" \
      --region "$region" \
      --query "[Snapshots[0].Tags[?Key=='Name']|[0].Value, Snapshots[0].Description]" \
      --output text 2>/dev/null); then
    snapshot_name='None'
    snapshot_description='None'
    return
  fi
  read -r snapshot_name snapshot_description <<< "$snapshot_info" # snapshot_description captures everything after the first column
  [[ "$snapshot_name" == "None" ]] && return
  reason="from snapshot_name='$snapshot_name', snapshot_description='$snapshot_description'"
}

find_reason_from_ami() {
  snapshot_description=$1
  ami_name='None'
  ami_name_tag='None'
  [[ -z "$snapshot_description" || "$snapshot_description" == "None" ]] && return
  if [[ $snapshot_description =~ DestinationAmi[[:space:]]+(ami-[0-9a-f]+) ]]; then
    ami_id="${BASH_REMATCH[1]}"
  elif [[ $snapshot_description =~ (ami-[0-9a-f]+) ]]; then
    ami_id="${BASH_REMATCH[1]}"
  else
    return 0
  fi

  if ! ami_info=$(aws ec2 describe-images \
      --image-ids $ami_id \
      --region "$region" \
      --query "Images[0].{AmiName:Name, NameTag:Tags[?Key=='Name']|[0].Value}" \
      --output text 2>/dev/null); then
    return
  fi
  read -r ami_name ami_name_tag <<< "$ami_info"
  [[ "$ami_name" == "None" ]] && [[ "$ami_name_tag" == "None" ]] && return
  if [[ "$ami_name" =~ AwsBackup ]] && [[ "$ami_name_tag" != "None" ]] ; then
    reason="ami='AWS backup for $ami_name_tag', snapshot_description='$snapshot_description'"
    return
  fi
  if [[ "$ami_name" != "None" ]] && [[ "$ami_name_tag" != "None" ]]; then
    reason="ami_name='$ami_name', ami_name_tag='$ami_name_tag' snapshot_description='$snapshot_description'"
    return
  fi
}

nice_date() {
  create_date=$1 # "2023-11-10T11:04:22.026000+00:00"
  create_date_short="${create_date:0:16}"  # first 16 chars → 2023-11-10T11:04
  nice_date="${create_date_short/T/ }" # replace T with space
  echo $nice_date
}

show_what_we_have() {
  create_time=$1
  info_string=''
  nice_date=$(nice_date "$create_time")

  [[ -n "$ami_name" && "$ami_name" != "None" ]] && info_string+="ami_name='$ami_name', "
  [[ -n "$ami_name_tag" && "$ami_name_tag" != "None" ]] && info_string+="ami_name_tag='$ami_name_tag', "
  [[ -n "$snapshot_description" && "$snapshot_description" != "None" ]] && info_string+="snapshot_description='$snapshot_description', "

  reason="Unsure. ${info_string}created='${nice_date}'"
}

do_action() {
  created_epoch=$($date_cmd -d "$create_time" +%s)
  age_months_dp=$(awk "BEGIN { printf \"%.1f\", ($now - $created_epoch) / 2592000 }") # 1 decimal place
  age_months=$(awk "BEGIN { print int($age_months_dp) }")

  (( age_months >= max_age_months )) || return

  case $action in
    all)
      echo "$volume_id $state $age_months_dp months old" ;;
    attached)
      echo "$volume_id $age_months_dp months old" ;;
    unattached)
      echo "$volume_id $age_months_dp months old. Reason: $reason" ;;
    delete)
      if [[ "$dryrun" == true ]]; then
        echo "$volume_id $age_months_dp months old. Reason: $reason"
      else
        echo "Deleting $volume_id $age_months_dp months old"
        aws ec2 delete-volume --volume-id "$volume_id" --region "$region"
      fi
      ;;
  esac
}

get_volumes() {
  echo $message

  volume_info=$(aws ec2 describe-volumes \
    --region "$region" \
    --query "Volumes[*][CreateTime, VolumeId, State, SnapshotId, Tags[?Key=='map-migrated']|[0].Value, Tags[?Key=='Name']|[0].Value]" \
    --output text \
    $filters)

  if [[ -n "$volume_info" ]]; then
    while read -r create_time volume_id state snapshot_id tag_map tag_name; do
      reason="?"
      find_reason_from_volume $tag_map $tag_name
      [[ "$reason" == "?" ]] && find_reason_from_snapshot "$snapshot_id"
      [[ "$reason" == "?" ]] && find_reason_from_ami "$snapshot_description"
      [[ "$reason" == "?" ]] && show_what_we_have $create_time
      do_action
    done <<< "$volume_info"
  else
    echo $none_message
  fi
}

main