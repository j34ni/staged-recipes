#!/bin/bash
set -ex

# Activate conda environment and set up compilers
export CC="${CC}"
export CXX="${CXX}"
export FC="${FC}"
export PERL="${PERL}"
export PYTHON="${PYTHON}"

# Set environment variables for compilation
export CFLAGS="-I${PREFIX}/include"
export LDFLAGS="-L${PREFIX}/lib -lz -lgfortran -lstdc++ -lcurl -ltinfo -Wl,-rpath,${PREFIX}/lib"
export PERL_MM_USE_DEFAULT=1
export PERL_EXTUTILS_AUTOINSTALL="--defaultdeps"

# Debug: Verify libtinfo library
echo "Checking for required library..."
find "${PREFIX}/lib" -name "libtinfo.so*" || echo "WARNING: libtinfo not found"

# Install Devel::CheckLib via CPAN
${PERL} -MCPAN -e 'install Devel::CheckLib'

# Build HEAsoft
cd heasoft/BUILD_DIR
./configure --prefix="${PREFIX}" \
    --x-includes="${PREFIX}/include" \
    --x-libraries="${PREFIX}/lib"
make
make install
