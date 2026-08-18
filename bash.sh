git clone https://github.com/auraecosystem/Lexilla.git
cd Lexilla

# Using CMake (Recommended)
mkdir build && cd build
cmake ..
make -j$(nproc)

# Direct Makefile build
cd src
make -f Lexilla.mak
