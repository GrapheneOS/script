readonly branch=15-qpr2
readonly aosp_tag_old=android-15.0.0_r14
readonly aosp_tag=android-15.0.0_r14

user_error() {
    echo $1 >&2
    exit 1
}
