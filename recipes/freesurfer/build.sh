#!/usr/bin/env bash
set -euo pipefail

# Fetch git-annex data files needed for build and installation
git remote add datasrc https://surfer.nmr.mgh.harvard.edu/pub/dist/freesurfer/repo/annex.git
git fetch datasrc
git config annex.diskreserve 0
git-annex get --metadata fstags=makeinstall .
git-annex get distribution/
git-annex get mri_claustrum_seg/
git-annex get mri_pglands_seg/

# Patch: fix glut.h includes
grep -rl '"glut.h"' --include="*.cpp" --include="*.c" --include="*.h" . | \
    xargs sed -i 's|#include "glut.h"|#include <GL/glut.h>|g' || true
grep -rl '<glut.h>' --include="*.cpp" --include="*.c" --include="*.h" . | \
    xargs sed -i 's|#include <glut.h>|#include <GL/glut.h>|g' || true

# Patch: remove conflicting errno declarations
grep -rl 'extern int errno' --include="*.cpp" --include="*.c" . | \
    xargs sed -i 's|extern int errno;|/* extern int errno; */|g' || true

# Patch: remove Ubuntu24-specific block that breaks the conda build
sed -i '/^if(HOST_OS MATCHES "Ubuntu24")/,/^endif()/d' python/fsbindings/CMakeLists.txt

# Patch: use system Python
sed -i 's|set(PYBIND11_PYTHON_VERSION 3)|set(PYBIND11_PYTHON_VERSION 3)\nset(PYBIND11_FINDPYTHON ON)|' CMakeLists.txt
sed -i "s|set(PYTHON_EXECUTABLE \"\${FS_PACKAGES_DIR}/fspython/\${FSPYTHON_VERSION}/bin/python\")|set(PYTHON_EXECUTABLE \"${PYTHON}\")|" python/CMakeLists.txt
sed -i 's|prune_cuda()||g' python/CMakeLists.txt
sed -i 's|integrate_samseg()||g' python/CMakeLists.txt

cmake \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DMARTINOS_BUILD=OFF \
    -DBUILD_GUIS=ON \
    -DDISTRIBUTE_FSPYTHON=OFF \
    -DINFANT_MODULE=OFF \
    -DINSTALL_PYTHON_DEPENDENCIES=OFF \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_PREFIX_PATH="${PREFIX}" \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
    -DVTK_COMPONENT_REQUIREMENTS_RENDERINGTK=OFF \
    -DPython3_EXECUTABLE="${PYTHON}" \
    -DPython3_ROOT_DIR="${PREFIX}" \
    -DPYTHON_EXECUTABLE="${PYTHON}" \
    -DZLIB_ROOT="${PREFIX}" \
    .

make -j"${CPU_COUNT}"

# Patch cmake_install.cmake scripts to use the conda Python
find . -name "cmake_install.cmake" | \
    xargs sed -i "s|/fspython/3.8/bin/python3.8|${PYTHON}|g"

make install
