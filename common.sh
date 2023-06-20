readonly base_branch=13
readonly branch=13-tangorpro
readonly aosp_tag_old=android-13.0.0_r71
readonly aosp_tag=android-13.0.0_r71
readonly aosp_base_tag=android-13.0.0_r67

user_error() {
    echo $1 >&2
    exit 1
}
