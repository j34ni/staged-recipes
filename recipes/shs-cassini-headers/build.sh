#!/bin/bash
set -ex

mkdir -p ${PREFIX}/include
cp -r include/* ${PREFIX}/include/
mkdir -p ${PREFIX}/share/cassini-headers
cp -r share/cassini-headers/* ${PREFIX}/share/cassini-headers/

# Minimize package size: remove docs, man pages, etc.
rm -rf ${PREFIX}/man ${PREFIX}/share/man ${PREFIX}/share/doc ${PREFIX}/share/info
