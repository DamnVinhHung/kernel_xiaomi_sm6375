check_submodule() {
  local git=$1
  local path=$2
  shift 2
  if [[ ! -d "$path"/.git ]]; then
    rm -rf "$path"
    git clone "$git" "$path" "$@"
  fi
}
installdeps() {
  check_submodule https://github.com/cachiusa/AnyKernel3 AnyKernel3 --depth=1 -b veux
  check_submodule https://github.com/cachiusa/android_kernel_build build --depth=1 -b remaster
  ./build/build-tools/debian.sh
  ./build/build-tools/llvm_cbl.sh -p llvm
}
m() {
  export CLANG_PREBUILT_BIN=llvm/bin
  export DIST_DIR=AnyKernel3
  ./build/build.sh "$@"
  ak3
}
ak3() {
  [ -d AnyKernel3 ] || return
  local zipname="AnyKernel3$(cat localversion)-$(date +"%Y%m%d")"
  if [ -n "${GITHUB_ACTION}" ]; then
    ./AnyKernel3/zip.sh clear
    echo "ARTIFACTNAME=$zipname" >> "${GITHUB_ENV}"
  else
    echo "[+] Creating installer package"
    ./AnyKernel3/zip.sh "${zipname}.zip"
  fi
}
mlog() {
  LOG=1 m "$@"
}
mcc() {
  ccache --set-config=cache_dir="$(pwd)/out/.ccache"
  ccache --set-config=max_size=2G
  ccache --set-config=compression=false
  m "$@" CC="ccache clang"
}
echo "[+] Done."
echo "[+] Run 'm' to build, 'installdeps' to install build tools"
