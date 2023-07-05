readonly branch=13
readonly aosp_tag_old=android-13.0.0_r61
readonly aosp_tag=android-13.0.0_r61

user_error() {
    echo $1 >&2
    exit 1
}
