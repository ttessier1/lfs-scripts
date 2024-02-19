# This project is meant to help with building Beyond Linux From Scratch
# See: https://www.linuxfromscratch.org/blfs
# To use a directory structure similar to the following should be used

/ - linux root
/blfs - blfs - storage directory for packages tar archive
/blfs/XServer - build X server - prerequisite tar archives and build scripts
/blfs/XServer/XOrgApps - storage directory for app tar archives
/blfs/XServer/XOrgLibs - storage directory for lib tar archives
/blfs/XServer/XOrgFonts - storage directory for font tar archives

# This should be updated to make everything cleaner - ie scripts folder for most scripts and a bootstrap.sh in the root of XServer
# sources should be built out of this directory and installed into /usr prefix where applicable ( IE XOrg may use different prefix )



