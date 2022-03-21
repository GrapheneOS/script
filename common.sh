branch=12.1-raviole
branch_base=12.1
aosp_version=SP2A.220305.013.A3
aosp_tag=android-12.1.0_r2
aosp_tag_base=android-12.1.0_r1

user_error() {
    echo $1 >&2
    exit 1
}
