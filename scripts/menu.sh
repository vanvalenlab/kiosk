#!/usr/bin/env bash

export BRAND="Caltech Van Valen Lab"

#dialog --print-maxsize

#trap ctrl_c SIGINT

function ctrl_c() {
  killall dialog
  trap - SIGINT
}

function retval() {
  case $1 in
  ${DIALOG_OK-0}) return 0;;
  ${DIALOG_CANCEL-1}) echo "Cancel pressed."; exit 1;;
  ${DIALOG_ESC-255}) echo "Esc pressed."; exit 2;;
  ${DIALOG_ERROR-255}) echo "Dialog error"; exit 3;;
  *) echo "Unknown error $retval"; exit 4
  esac
}

function msgbox() {
  local title=$1
  local message=$2
  if [ "$testing" = "0" ]; then
    dialog --backtitle "$BRAND" --title "$title" --clear --msgbox "$message" 12 60
  else
    dialog --backtitle "$BRAND" --title "$title" --clear --msgbox "$message" 12 60 \
        --input-fd 3 3<${greeting_test_script}
  fi
  retval $?
}

function inputbox() {
  local value
  local title=$1
  local label=$2
  local default=$3
  local w=${4:-60}
  local h=${5:-8}
  shift
  if [ "$testing" = "0" ]; then
    value=$(dialog --title "$title" \
        --inputbox "$label" "$h" "$w" "$default" \
        --backtitle "${BRAND}" \
        --output-fd 1)
  else
    line=$(head -n 1 ${aws_test_script})
    echo "$line" > ./one_liner
    value=$(dialog --title "$title" \
        --inputbox "$label" "$h" "$w" "$default" \
        --backtitle "${BRAND}" \
        --output-fd 1 \
        --input-fd 3 3<./one_liner )
    tail -n +2 "$aws_test_script" > "$aws_test_script.tmp" && mv "$aws_test_script.tmp" "$aws_test_script"
  fi
  echo $value
}

function radiobox() {
  local value
  local title=$1
  local label=$2
  local h=${3:-8}
  local w=${4:-60}
  local menu_h=${5:-3}
  local text_fields=$6
  IFS=$'\n' read -r -a gpu_array <<< "$text_fields"
  shift
  if [ "$testing" = "0" ]; then
    value=$(dialog --title "$title" \
        --radiolist "$label" "$h" "$w" "$menu_h" \
	    $text_fields \
        --backtitle "${BRAND}" \
        --output-fd 1)
  else
    line=$(head -n 1 ${aws_test_script})
    echo "$line" > ./one_liner
    value=$(dialog --title "$title" \
        --radiolist "$label" "$h" "$w" "$menu_h" \
	    $text_fields \
        --backtitle "${BRAND}" \
        --output-fd 1 \
        --input-fd 3 3<./one_liner )
    tail -n +2 "$aws_test_script" > "$aws_test_script.tmp" && mv "$aws_test_script.tmp" "$aws_test_script"
  fi
  echo $value
}

function infobox() {
  local message="$1"
  local w=${2:-20}
  local h=${3:-3}
  dialog --infobox "$message" $h $w
}

function tailcmd() {
  local title=$1
  local completed_message=${2:-">>> Done!\n"}
  local tmpfile=$(mktemp /tmp/setup.XXXXXX)
  shift
  shift
  :> $tmpfile
  (
    $* 2>&1
    echo
    echo "${completed_message}"
  ) > $tmpfile &

  dialog --clear \
         --begin 0 0 \
         --title "$title" \
         --backtitle "${BRAND}" \
         --begin 3 1 \
         --tailbox "${tmpfile}" $((LINES-5)) $((COLUMNS-3)) 
}

function menu() {
  local value
  local header_text=("You can use the UP/DOWN arrow keys, the first\n"
                     "letter of the choice as a hot key, or the\n"
                     "number keys 1-9 to choose an option.\n"
                     "Choose a task.")

  declare -A cloud_providers
  cloud_providers[${CLOUD_PROVIDER:-none}]="(active)"
  # determine which script, if any, to use
  if [ "$testing" = "1" ]; then
    if [ "$menu_pass" = "1" ]; then
      if [ -n "$menu_test_script" ]; then
        menu_input_script=${menu_test_script}
        menu_pass=2
      else
        testing=0
      fi
    elif [ "$menu_pass" = "2" ]; then
      if [ -n "$menu_second_test_script" ]; then
        menu_input_script=${menu_second_test_script}
        menu_pass=3
      else
        testing=0
      fi
    else
      if [ -n "$menu_third_test_script" ]; then
        menu_input_script=${menu_third_test_script}
      else
        testing=0
      fi
    fi
  fi
  # now display/execute dialog accordingly
  if [ "$testing" = "0" ]; then
    value=$(dialog --clear --help-button --backtitle "${BRAND}" \
        --title "[ M A I N - M E N U ]" \
        --menu "${header_text[*]}" 17 50 7 \
            "AWS"     "Configure Amazon ${cloud_providers[aws]}" \
            "GKE"     "Configure Google ${cloud_providers[gke]}" \
		    "Create"  "Create ${CLOUD_PROVIDER^^} Cluster" \
            "Destroy" "Destroy ${CLOUD_PROVIDER^^} Cluster" \
		    "View"    "View Cluster Address" \
		    "Shell"   "Drop to the shell" \
            "Exit"    "Exit this kiosk" \
            --output-fd 1 \
          )
  else
    value=$(dialog --clear --help-button --backtitle "${BRAND}" \
        --title "[ M A I N - M E N U ]" \
        --menu "${header_text[*]}" 17 50 7 \
            "AWS"     "Configure Amazon ${cloud_providers[aws]}" \
            "GKE"     "Configure Google ${cloud_providers[gke]}" \
		    "Create"  "Create ${CLOUD_PROVIDER^^} Cluster" \
            "Destroy" "Destroy ${CLOUD_PROVIDER^^} Cluster" \
		    "View"    "View Cluster Address" \
		    "Shell"   "Drop to the shell" \
            "Exit"    "Exit this kiosk" \
            --output-fd 1 \
            --input-fd 3 3<${menu_input_script} \
          )
  fi
  retval $?
  echo $value
}

function configure_aws() {
  if [ -z "${NAMESPACE}" ]; then
    # Generate a friendly human readable name
    export NAMESPACE="$(shuf -n 1 /etc/wordlist.txt)-$((1 + RANDOM % 100))"
  fi

  export AWS_ACCESS_KEY_ID=$(inputbox "Amazon Web Services" "Access Key ID" "${AWS_ACCESS_KEY_ID:-invalid_default}")
  if [ "$AWS_ACCESS_KEY_ID" = "" ]; then
	  return 0
  fi
  export AWS_SECRET_ACCESS_KEY=$(inputbox "Amazon Web Services" "AWS Secret Key" "${AWS_SECRET_ACCESS_KEY:-invalid_default}")
  if [ "$AWS_SECRET_ACCESS_KEY" = "" ]; then
	  return 0
  fi
  export AWS_S3_BUCKET=$(inputbox "Amazon Web Services" "AWS S3 Bucket Name" "${AWS_S3_BUCKET:-invalid_default}")
  if [ "$AWS_S3_BUCKET" = "" ]; then
	  return 0
  fi
  export NAMESPACE=$(inputbox "Deepcell" "Cluster Name" "${NAMESPACE:-deepcell-aws-cluster}")
  export NAMESPACE=$(echo ${NAMESPACE} | awk '{print tolower($0)}' | sed -E 's/[^a-z0-9]+/-/g' | sed -E 's/(^-+|-+$)//')
  if [ "$NAMESPACE" = "" ]; then
	  return 0
  fi
  export MASTER_MACHINE_TYPE=$(inputbox "Amazon Web Services" "Master Node Machine Type" "${MASTER_MACHINE_TYPE:-m4.large}")
  if [ "$MASTER_MACHINE_TYPE" = "" ]; then
	  return 0
  fi
  export NODE_MACHINE_TYPE=$(inputbox "Amazon Web Services" "Worker Nodes Machine Type" "${NODE_MACHINE_TYPE:-m4.large}")
  if [ "$NODE_MACHINE_TYPE" = "" ]; then
	  return 0
  fi

  # let's just hardcode the menu, since all instance types are apparently available in all regions
  # and there's no built-in way to list type in the aws-cli
  local gpu_types="g3.xlarge 1GPU OFF
	  g3.4xlarge 1GPU OFF
	  g3.8xlarge 2GPUs OFF
	  g3.16xlarge 4GPUs OFF
	  p2.xlarge 1GPU ON
	  p2.8xlarge 8GPUs OFF
	  p2.16xlarge 16GPUs OFF
	  p3.2xlarge 1GPU OFF
	  p3.8xlarge 4GPUs OFF
	  p3.16xlarge 8GPUs OFF"
  export AWS_GPU_MACHINE_TYPE=$(radiobox "Amazon Web Services" \
	  "Choose your GPU Instance Type:" 15 60 7 "$gpu_types")
  
  export AWS_MIN_GPU_NODES=$(inputbox "Amazon Web Services" "Minimum Number of GPU Instances" "${AWS_MIN_GPU_NODES:-0}")
  if [ "$AWS_MIN_GPU_NODES" = "" ]; then
	  return 0
  fi
  export AWS_MAX_GPU_NODES=$(inputbox "Amazon Web Services" "Maximum Number of GPU Instances" "${AWS_MAX_GPU_NODES:-4}")
  if [ "$AWS_MAX_GPU_NODES" = "" ]; then
	  return 0
  fi

  export KOPS_CLUSTER_NAME=${NAMESPACE}.k8s.local
  export KOPS_DNS_ZONE=${NAMESPACE}.k8s.local
  export KOPS_STATE_STORE=s3://${NAMESPACE}
  export CLOUD_PROVIDER=aws
  
  make create_cache_path
  printenv | grep -e CLOUD_PROVIDER > ${CACHE_PATH}/env
  printenv | grep -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY -e AWS_S3_BUCKET -e NAMESPACE > ${CACHE_PATH}/env.aws
  #printenv | grep -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY -e AWS_S3_BUCKET -e NAMESPACE -e KOPS_CLUSTER_NAME -e KOPS_DNS_ZONE -e KOPS_STATE_STORE > ${CACHE_PATH}/env.aws
}

function configure_gke() {
  export PROJECT=$(inputbox "Google Cloud" "Existing Project ID" "${PROJECT:-invalid_default}")
  if [ "$PROJECT" = "" ]; then
	  return 0
  fi
  make gke/login
  export CLUSTER_NAME=$(inputbox "Deepcell" "Cluster Name" "${CLUSTER_NAME:-deepcell}")
  export CLUSTER_NAME=$(echo ${CLUSTER_NAME} | awk '{print tolower($0)}' | sed -E 's/[^a-z0-9]+/-/g' | sed -E 's/(^-+|-+$)//')
  if [ "$CLUSTER_NAME" = "" ]; then
	  return 0
  fi
  export GKE_BUCKET=$(inputbox "Deepcell" "Bucket Name" "${GKE_BUCKET:-invalid_default}")
  if [ "$GKE_BUCKET" = "" ]; then
	  return 0
  fi
  export GKE_COMPUTE_REGION=$(inputbox "Google Cloud" "Compute Region" "${GPU_COMPUTE_REGION:-us-west1}")
  if [ "$GKE_COMPUTE_REGION" = "" ]; then
	  return 0
  fi
  export GKE_COMPUTE_ZONE=$(inputbox "Google Cloud" "Compute Zone" "${GKE_COMPUTE_ZONE:-us-west1-b}")
  if [ "$GKE_COMPUTE_ZONE" = "" ]; then
	  return 0
  fi
  export GKE_MACHINE_TYPE=$(inputbox "Google Cloud" "Node (non-GPU) Type" "${GKE_MACHINE_TYPE:-n1-standard-2}")
  if [ "$GKE_MACHINE_TYPE" = "" ]; then
	  return 0
  fi

  gcloud config set project ${PROJECT}
  local gpus_in_region=$(gcloud compute accelerator-types list | \
	  grep ${GKE_COMPUTE_ZONE} | awk '{print $1 " _ OFF"}')
  local gpus_with_default=${gpus_in_region/nvidia-tesla-k80 _ OFF/nvidia-tesla-k80 _ ON}
  local base_box_height=7
  local selector_box_lines=$(echo "${gpus_in_region}" | tr -cd '\n' | wc -c)
  local total_lines=$(($base_box_height + $selector_box_lines))
  export GPU_TYPE=$(radiobox "Google Cloud" \
	  "Choose from the GPU types available in your region:" \
	  $total_lines 60 $selector_box_lines "$gpus_with_default")
  
  export GPU_PER_NODE=$(inputbox "Google Cloud" "GPUs per GPU Node" "${GPU_PER_NODE:-1}")
  if [ "$GPU_PER_NODE" = "" ]; then
	  return 0
  fi
  export GPU_MACHINE_TYPE=$(inputbox "Google Cloud" "GPU Node Type" "${GPU_MACHINE_TYPE:-n1-standard-4}")
  if [ "$GPU_MACHINE_TYPE" = "" ]; then
	  return 0
  fi
  export GPU_NODE_MIN_SIZE=$(inputbox "Google Cloud" "Minimum Number of GPU Nodes" "${GPU_NODE_MIN_SIZE:-0}")
  if [ "$GPU_NODE_MIN_SIZE" = "" ]; then
	  return 0
  fi
  export GPU_NODE_MAX_SIZE=$(inputbox "Google Cloud" "Maximum Number of GPU Nodes" "${GPU_NODE_MAX_SIZE:-4}")
  if [ "$GPU_NODE_MAX_SIZE" = "" ]; then
	  return 0
  fi
  export CLOUD_PROVIDER=gke

  
  make create_cache_path
  printenv | grep -e CLOUD_PROVIDER > ${CACHE_PATH}/env
  printenv | grep -e PROJECT -e CLUSTER_NAME -e GKE_BUCKET \
	  -e GKE_COMPUTE_REGION -e GKE_COMPUTE_ZONE \
	  -e GKE_MACHINE_TYPE -e GPU_TYPE -e GPU_PER_NODE \
	  -e GPU_MACHINE_TYPE -e GPU_NODE_MIN_SIZE \
	  -e GPU_NODE_MAX_SIZE > ${CACHE_PATH}/env.gke
}


function shell() {
  clear
  echo "Type 'exit' to return to the menu."
  bash -l
}

function create() {
  tailcmd "Create Cluster" "---COMPLETE---" make create
}

function destroy() {
  tailcmd "Destroy Cluster" "---COMPLETE--" make destroy
}

function view() {
  local title="Deepcell Cluster Address"
  if [ -f ./cluster_address ]; then
	  local cluster_address=$(cat ./cluster_address | sed 's/export CLUSTER_ADDRESS=\([[:graph:]]\+\)/\1/')
  else
	  local cluster_address="No current address -- no cluster has been started yet."
  fi
  clear
  echo "The cluster's address is: " ${cluster_address}
  read -p "Press enter to return to main menu"
}


function usage() {
  clear
  echo "No help written yet."
  read -p "Press enter to return to main menu"
}


function main() {
  export MENU=true
  msgbox "Welcome!" \
	 "Welcome to the Deepcell Kiosk!

This Kiosk was developed by the Van Valen Lab at the California Institute of Technology.

https://vanvalenlab.caltech.edu"

  while true; do
    ACTION=$(menu)
    if [ $? -ne 0 ]; then
      break
    fi

    case $ACTION in
      "Shell") shell ;;
      "AWS") configure_aws ;;
      "GKE") configure_gke ;;
      "Create") create ;;
      "Destroy") destroy;;
      "View") view;;
      "Exit") break ;;
    esac
  done

  infobox "Good bye!"
  sleep 0.5
  clear

  exit 0
}



### Execution begins here
testing=0 #controls whether we take user input or feed in scripts, off by default
greeting_test_script=
menu_test_script=
aws_test_script=
gke_test_script=
shell_test_script=
menu_sceond_test_script=
menu_third_test_script=
menu_pass=1 # indicates which menu script should be executed

while [ "$1" != "" ]; do
    case $1 in
        -t | --testing )        testing=1
                                ;;
        -g | --greeting )       shift
								greeting_test_script=$1
                                ;;
        -m | --menu )           shift
								menu_test_script=$1
                                ;;
        -a | --awsconfig )      shift
								aws_test_script=$1
                                ;;
        -g | --gkeconfig )      shift
								gke_test_script=$1
                                ;;
        -s | --shellscript )    shift
								shell_test_script=$1
                                ;;
        -mm | --menusecond )    shift
								menu_second_test_script=$1
                                ;;
        -mmm | --menuthird )    shift
								menu_third_test_script=$1
                                ;;
        -h | --help )           usage
                                exit
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done

[ -n "$MENU" ] || main
