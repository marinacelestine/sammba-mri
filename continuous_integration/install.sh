#!/bin/bash
# This script is meant to be called by the "install" step defined in
# .travis.yml. See http://docs.travis-ci.com/ for more details.
# The behavior of the script is controlled by environment variabled defined
# in the .travis.yml in the top level folder of the project.
#
# This script is adapted from a similar script from the scikit-learn repository.
#
# License: 3-clause BSD

set -e

# Fix the compilers to workaround avoid having the Python 3.4 build
# lookup for g++44 unexpectedly.
export CC=gcc
export CXX=g++

create_new_venv() {
    # At the time of writing numpy 1.9.1 is included in the travis
    # virtualenv but we want to be in control of the numpy version
    # we are using for example through apt-get install
    deactivate
    virtualenv --system-site-packages testvenv
    source testvenv/bin/activate
    pip install nose
    pip install doctest-ignore-unicode
}

print_conda_requirements() {
    # Echo a conda requirement string for example
    # "pip nose python='2.7.3 scikit-learn=*". It has a hardcoded
    # list of possible packages to install and looks at _VERSION
    # environment variables to know whether to install a given package and
    # if yes which version to install. For example:
    #   - for numpy, NUMPY_VERSION is used
    #   - for scikit-learn, SCIKIT_LEARN_VERSION is used
    TO_INSTALL_ALWAYS="pip nose"
    REQUIREMENTS="$TO_INSTALL_ALWAYS"
    TO_INSTALL_MAYBE="python numpy scipy matplotlib scikit-learn nipype"
    for PACKAGE in $TO_INSTALL_MAYBE; do
        # Capitalize package name and add _VERSION
        PACKAGE_VERSION_VARNAME="${PACKAGE^^}_VERSION"
        # replace - by _, needed for scikit-learn for example
        PACKAGE_VERSION_VARNAME="${PACKAGE_VERSION_VARNAME//-/_}"
        # dereference $PACKAGE_VERSION_VARNAME to figure out the
        # version to install
        PACKAGE_VERSION="${!PACKAGE_VERSION_VARNAME}"
        if [ -n "$PACKAGE_VERSION" ]; then
            REQUIREMENTS="$REQUIREMENTS $PACKAGE=$PACKAGE_VERSION"
        fi
    done
    echo $REQUIREMENTS
}

create_new_conda_env() {
    # Skip Travis related code on circle ci.
    if [ -z $CIRCLECI ]; then
        # Deactivate the travis-provided virtual environment and setup a
        # conda-based environment instead
        deactivate
    fi

    # Use the miniconda installer for faster download / install of conda
    # itself
    wget http://repo.continuum.io/miniconda/Miniconda-latest-Linux-x86_64.sh \
        -O miniconda.sh
    chmod +x miniconda.sh && ./miniconda.sh -b
    export PATH=/home/travis/miniconda2/bin:$PATH
    echo $PATH
    conda update --quiet --yes conda

    # Configure the conda environment and put it in the path using the
    # provided versions
    REQUIREMENTS=$(print_conda_requirements)
    echo "conda requirements string: $REQUIREMENTS"
    conda create -n testenv --yes $REQUIREMENTS
    source activate testenv

    if [[ "$INSTALL_MKL" == "true" ]]; then
        # Make sure that MKL is used
        conda install --quiet --yes mkl
    elif [[ -z $CIRCLECI ]]; then
        # Travis doesn't use MKL but circle ci does for speeding up examples
        # generation in the html documentation.
        # Make sure that MKL is not used
        conda remove --yes --features mkl || echo "MKL not installed"
    else
        # Make sure that MKL is not used
        conda remove --yes --features mkl || echo "MKL not installed"
    fi

    bash <(wget -q -O- http://neuro.debian.net/_files/neurodebian-travis.sh)
    travis_retry sudo apt-get install -y -qq graphviz afni fsl
    source /etc/afni/afni.sh
    echo "AFNI plugin path $AFNI_PLUGINPATH."
    echo "AFNI binaries installed in $(which afni)"
    source /etc/fsl/fsl.sh
    export FSLOUTPUTTYPE=NIFTI_GZ
    travis_retry sudo apt-get install -y -qq  ants
    export ANTSPATH=${ANTSPATH:="/usr/lib/ants"}
    export PATH=${PATH}:/usr/bin/ANTS
    export PATH=${PATH}:/usr/lib/ants
    echo "ANTS path $ANTSPATH."
    echo "ANTS binaries installed in $(which ANTS)"
}

if [[ "$DISTRIB" == "neurodebian" ]]; then
    create_new_venv
    bash <(wget -q -O- http://neuro.debian.net/_files/neurodebian-travis.sh)
    sudo apt-get install -y -qq python-scipy python-nose python-nibabel\
         python-sklearn python-nilearn python-nipype
    travis_retry sudo apt-get install -y -qq  afni fsl
    source /etc/afni/afni.sh
    echo "AFNI plugin path $AFNI_PLUGINPATH."
    echo "AFNI binaries installed in $(which afni)"
    source /etc/fsl/fsl.sh
    travis_retry sudo apt-get install -y -qq  ants
    export ANTSPATH=${ANTSPATH:="/usr/lib/ants"}
    export PATH=${PATH}:/usr/bin/ANTS
    export PATH=${PATH}:/usr/lib/ants
    echo "ANTS path $ANTSPATH."
    echo "ANTS binaries installed in $(which ANTS)"
elif [[ "$DISTRIB" == "conda" ]]; then
    create_new_conda_env
    # Note: nibabel is in setup.py install_requires so nibabel will
    # always be installed eventually. Defining NIBABEL_VERSION is only
    # useful if you happen to want a specific nibabel version rather
    # than the latest available one.
    if [ -n "$NIBABEL_VERSION" ]; then
        pip install nibabel=="$NIBABEL_VERSION"
    fi
    # Install the latest available version of nilearn
    pip install nilearn

    # Allow nose to ignore unicode in doctest
    pip install doctest-ignore-unicode
    
    conda install --channel conda-forge nipype --yes
else
    echo "Unrecognized distribution ($DISTRIB); cannot setup travis environment."
    exit 1
fi

if [[ "$COVERAGE" == "true" ]]; then
    pip install coverage coveralls
fi

# numpy not installed when skipping the tests so we do not want to run
# setup.py install
if [[ "$SKIP_TESTS" != "true" ]]; then
    python setup.py install
fi
