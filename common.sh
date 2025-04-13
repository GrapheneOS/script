readonly branch=15-qpr1-tegu
readonly aosp_tag_old=android-15.0.0_r25
readonly aosp_tag=android-15.0.0_r25

user_error() {
    echo $1 >&2
    exit 1
}
