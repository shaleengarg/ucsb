#!/bin/bash

set -e  # Exit on error
set -x  # Enable command tracing

# Function to update PATH and LD_LIBRARY_PATH
update_paths() {
        # Ensure /usr/local/bin is in PATH
        if [[ ":$PATH:" != *":/usr/local/bin:"* ]]; then
                echo "Adding /usr/local/bin to PATH."
                echo "export PATH=/usr/local/bin:\$PATH" >> ~/.bashrc
                export PATH="/usr/local/bin:$PATH"
        else
                echo "/usr/local/bin is already in PATH."
        fi

        # Ensure /usr/local/lib is in LD_LIBRARY_PATH
        if [[ ":$LD_LIBRARY_PATH:" != *":/usr/local/lib:"* ]]; then
                echo "Adding /usr/local/lib to LD_LIBRARY_PATH."
                echo "export LD_LIBRARY_PATH=/usr/local/lib:\$LD_LIBRARY_PATH" >> ~/.bashrc
                export LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH"
        else
                echo "/usr/local/lib is already in LD_LIBRARY_PATH."
        fi

        # Reload bashrc to ensure changes take effect
        source ~/.bashrc
        echo "Environment paths updated successfully."
}

# Function to check if SWIG is installed
is_swig_installed() {
        if command -v swig &> /dev/null; then
                installed_version=$(swig -version | awk '/SWIG Version/ {print $3}')
                echo "SWIG version $installed_version is installed."
                return 0
        fi
        return 1
}

# Function to check if Python 3.9 is installed
is_python39_installed() {
        if command -v python3.9 &> /dev/null; then
                installed_version=$(python3.9 --version 2>&1 | awk '{print $2}')
                echo "Python 3.9 version $installed_version is installed."
                return 0
        fi
        return 1
}

# Compile and install SWIG
compile_swig() {
        sudo yum install -y pcre2-devel

        # Download only if the tar file does not already exist
        if [ ! -f swig.tar.gz ]; then
                wget https://github.com/swig/swig/archive/refs/tags/v4.1.1.tar.gz -O swig.tar.gz
        else
                echo "SWIG tar file already exists. Skipping download."
        fi

        tar --overwrite -xf swig.tar.gz
        pushd ./swig-4.1.1
        ./autogen.sh
        ./configure
        make -j$(nproc)
        sudo make install
        popd

        echo "SWIG installed. Check installation with: swig -version"
}

# Compile and install Python 3.9.9
compile_python39() {
        sudo yum install -y libffi-devel

        # Download only if the tar file does not already exist
        if [ ! -f Python-3.9.9.tgz ]; then
                wget https://www.python.org/ftp/python/3.9.9/Python-3.9.9.tgz
        else
                echo "Python 3.9 tar file already exists. Skipping download."
        fi
        tar --overwrite -xf Python-3.9.9.tgz

        pushd Python-3.9.9

        CFLAGS="-fPIC" ./configure --enable-shared --prefix=/usr/local --enable-optimizations
        make -j$(nproc)
        sudo make install -j$(nproc)

        popd

        echo "Python 3.9.9 installed. Check installation with: python3.9 --version"
}


gcc_version=$(gcc -dumpversion | cut -f1 -d.)

# Check if the version is greater than 7
if [ "$gcc_version" -ge 11 ]; then
        echo "GCC version is >= 11 (version $gcc_version)."
else
        echo "GCC version is < 11 (version $gcc_version). scl enable devtoolset-11 bash"
fi

update_paths

# Create a directory for compiled packages
mkdir -p ./pkgs_compiled
pushd pkgs_compiled

# Check and install SWIG
if is_swig_installed; then
        echo "SWIG is already installed. Skipping installation."
else
        echo "SWIG is not installed. Installing..."
        compile_swig
fi

# Check and install Python 3.9
if is_python39_installed; then
        echo "Python 3.9 is already installed. Skipping installation."
else
        echo "Python 3.9 is not installed. Installing..."
        compile_python39
fi

popd
