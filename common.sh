readonly branch=13
readonly aosp_version=TQ3A.230605.012
readonly aosp_tag_old=android-13.0.0_r52
readonly aosp_tag=android-13.0.0_r52

user_error() {
    echo $1 >&2
    exit 1
}
