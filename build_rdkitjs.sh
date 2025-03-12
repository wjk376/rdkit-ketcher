set -e

BOOST_VERSION="1.87.0"
EXCEPTION_HANDLING="-fexceptions -sNO_DISABLE_EXCEPTION_CATCHING"

rm -rf build
mkdir -p build
cd build
echo "Building RDKit..."

emcmake cmake -DRDK_BUILD_FREETYPE_SUPPORT=ON -DRDK_BUILD_MINIMAL_LIB=ON \
  -DRDK_BUILD_PYTHON_WRAPPERS=OFF -DRDK_BUILD_CPP_TESTS=OFF -DRDK_BUILD_INCHI_SUPPORT=OFF \
  -DRDK_USE_BOOST_SERIALIZATION=OFF -DRDK_OPTIMIZE_POPCNT=OFF -DRDK_BUILD_THREADSAFE_SSS=OFF \
  -DRDK_BUILD_DESCRIPTORS3D=OFF -DRDK_TEST_MULTITHREADED=OFF \
  -DRDK_BUILD_MAEPARSER_SUPPORT=OFF -DRDK_BUILD_COORDGEN_SUPPORT=ON \
  -DBoost_DIR=/opt/boost/lib/cmake/Boost-$BOOST_VERSION \
  -Dboost_headers_DIR=/opt/boost/lib/cmake/boost_headers-$BOOST_VERSION \
  -DRDK_BUILD_SLN_SUPPORT=OFF -DRDK_USE_BOOST_IOSTREAMS=OFF \
  -DFREETYPE_INCLUDE_DIRS=/opt/freetype/include/freetype2 \
  -DFREETYPE_LIBRARY=/opt/freetype/lib/libfreetype.a \
  -DCMAKE_CXX_FLAGS="$EXCEPTION_HANDLING -O3 -DNDEBUG" \
  -DCMAKE_C_FLAGS="$EXCEPTION_HANDLING -O3 -DNDEBUG -DCOMPILE_ANSI_ONLY" \
  -DCMAKE_EXE_LINKER_FLAGS="$EXCEPTION_HANDLING -s STACK_OVERFLOW_CHECK=1 -s USE_PTHREADS=0 -s ALLOW_MEMORY_GROWTH=1 -s MAXIMUM_MEMORY=4GB -s MODULARIZE=1 -s EXPORT_NAME=\"'initRDKitModule'\"" ..

# build and "install"
make -j2 RDKit_minimal
cp Code/MinimalLib/RDKit_minimal.* ../Code/MinimalLib/demo

# run the tests
cd ../Code/MinimalLib/tests
/root/opt/emsdk/node/*/bin/node tests.js

cd ..
rm -rf dist
mkdir -p dist
mv demo/RDKit_minimal.* dist
cd dist
printf "\nexport default initRDKitModule;\n" >> RDKit_minimal.js