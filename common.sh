readonly base_branch=14
readonly branch=14-shusky
readonly aosp_tag_old=android-14.0.0_r12
readonly aosp_tag=android-14.0.0_r12
readonly aosp_base_tag=android-14.0.0_r14

user_error() {
    echo $1 >&2
    exit 1
}
