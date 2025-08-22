#!/bin/bash
set -ex

mkdir -p $PREFIX/include/uapi
mkdir -p $PREFIX/include/linux
cp -r include/uapi/* $PREFIX/include/uapi/
cp -r include/linux/* $PREFIX/include/linux/

# Minimize package size: remove docs, man pages, etc.
rm -rf $PREFIX/man $PREFIX/share/man $PREFIX/share/doc $PREFIX/share/info
