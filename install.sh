#!/bin/bash
set -e
shopt -s extglob
shopt -s globstar

#Checks if in Google Colab and does not run installation if it is not
python -c 'import google.colab' 2>/dev/null || exit
#Don't run again if it's already installed
[ -f /content/habitat_sim_installed ] && echo "Habitat is already installed. Aborting..." >&2 && exit
trap 'catch $? $LINENO' EXIT # Installs trap now
catch() {
  if [ "$1" != "0" ]; then
    echo "An error occured during the installation of Habitat-sim or Habitat-Lab." >&2
  fi
}
#Don't change the colab versions for these libraries
PYTHON_VERSION="$( python -c 'import sys; print(".".join(map(str, sys.version_info[:2])))' )"
PIL_VERSION="$(python -c 'import PIL; print(PIL.__version__)')"
CFFI_VERSION="$(python -c 'import cffi; print(cffi.__version__)')"
#Install Miniconda
cd /content/
wget -c https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh && bash Miniconda3-latest-Linux-x86_64.sh -bfp /usr/local

#Adds the conda libraries directly to the colab path.
ln -s "/usr/local/lib/python${PYTHON_VERSION}/dist-packages" "/usr/local/lib/python${PYTHON_VERSION}/site-packages"

##Install Habitat-Sim and Magnum binaries
conda config --set pip_interop_enabled True
NIGHTLY="${NIGHTLY:-false}" #setting the ENV $NIGHTLY to true will install the nightly version from conda
CHANNEL="${CHANNEL:-aihabitat}"
if ${NIGHTLY}; then
  CHANNEL="${CHANNEL}-nightly"
fi

conda install -y --prefix /usr/local -c aihabitat -c conda-forge bullet=2.88 habitat-sim=0.1.6 headless withbullet python=3.6

#Shallow GIT clone for speed
git clone -b v0.1.6 https://github.com/facebookresearch/habitat-lab --depth 1
git clone -b v0.1.6 https://github.com/facebookresearch/habitat-sim --depth 1

#Install Requirements.
cd /content/habitat-lab/
set +e
pip install -r ./requirements.txt
reqs=(./habitat_baselines/**/requirements.txt)
pip install "${reqs[@]/#/-r}"
set -e
python setup.py develop --all
pip install . #Reinstall to trigger sys.path update
cd /content/habitat-sim/
rm -rf habitat_sim/ # Deletes the habitat_sim folder so it doesn't interfere with import path

#Download Assets
wget -c http://dl.fbaipublicfiles.com/habitat/habitat-test-scenes.zip && unzip -o habitat-test-scenes.zip
wget -c http://dl.fbaipublicfiles.com/habitat/objects_v0.2.zip && unzip -o objects_v0.2.zip -d data/objects/
wget -c http://dl.fbaipublicfiles.com/habitat/locobot_merged_v0.2.zip && unzip -o locobot_merged_v0.2.zip -d data/objects

#symlink assets appear in habitat-api folder
ln -s /content/habitat-sim/data /content/habitat-lab/.

touch /content/habitat_sim_installed