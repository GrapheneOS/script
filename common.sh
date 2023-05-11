readonly base_branch=13
readonly branch=13-lynx
readonly aosp_version=TQ2B.230505.005.A1
readonly aosp_tag_old=android-13.0.0_r49
readonly aosp_tag=android-13.0.0_r49
readonly aosp_base_tag=android-13.0.0_r43

user_error() {
    echo $1 >&2
    exit 1
}
