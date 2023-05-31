readonly branch=13
readonly aosp_version=TQ2A.230505.002
readonly aosp_tag=android-13.0.0_r43

user_error() {
    echo $1 >&2
    exit 1
}
