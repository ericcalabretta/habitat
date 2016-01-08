pkg_name=erlang
pkg_derivation=chef
pkg_version=18.2.1
pkg_dirname=otp_src_${pkg_version}
pkg_license=('erlang')
pkg_maintainer='Joshua Timberman <joshua@chef.io>'
pkg_source=http://www.erlang.org/download/otp_src_${pkg_version}.tar.gz
pkg_filename=otp_src_${pkg_version}.tar.gz
pkg_shasum=82d76ebfeeda5db64ea5b0f1a04aa0e9ac63380b278722e0e6052249bd3fe39a
pkg_gpg_key=3853DA6B
pkg_deps=(chef/glibc chef/zlib)
pkg_lib_dirs=(lib)
pkg_include_dirs=(include)

do_build() {
  ./configure --enable-threads \
              --enable-smp-support \
              --enable-kernel-poll \
              --enable-threads \
              --enable-smp-support \
              --enable-kernel-poll \
              --enable-dynamic-ssl-lib \
              --enable-shared-zlib \
              --enable-hipe \
              --without-javac \
              --disable-debug
  make
}
