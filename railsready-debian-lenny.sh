#!/bin/bash
#
# Author: Jakub Godawa <jakub.godawa@gmail.com>
# Licence: MIT
#

#
# Original script for Ubuntu 10.04 LTS: Josh Frye <joshfng@gmail.com>
#
# Contributions from: Wayne E. Seguin <wayneeseguin@gmail.com>
# Contributions from: Ryan McGeary <ryan@mcgeary.org>
#

system_version="Debian Lenny 5.0x"

ruby_version="1.9.2"
ruby_version_string="1.9.2-p136"
ruby_source_dir_name="ruby-1.9.2-p136"

passenger_version="3.0.2"

script_runner=$(whoami)
log_file=$(cd && pwd)/rails_install.log

control_c()
{
  echo -en "\n\n*** Exiting ***\n\n"
  exit 1
}

# Trap keyboard interrupt (control-c)
trap control_c SIGINT

shopt -s extglob
set -e

# First things first
cd && touch $log_file
echo -e "\n"
echo "!!! This script will update your system! Run on a fresh $system_version install only !!!"
echo "run tail -f $log_file in a new terminal to watch the install"

# Help with sudo privilages
echo -e "If this is just installed then add a user "$script_runner" to the sudoers.\n"
echo "Do this by yourself:"
echo "su"
echo "apt-get install sudo"
echo -e "echo '$script_runner ALL=(ALL) ALL' >> /etc/sudoers\n"
echo "Is it ready and you want to continue? (y/n): "
read ready

# Ask user if he/she is ready for installation
if [ $ready = "y" ]
then
  echo -e "Starting the installation...\n"
else
  echo -e "Run the script again when you will be ready\n"; exit 1;
fi

# Check if the user has sudo privileges.
sudo -v >/dev/null 2>&1 || { echo $script_runner has no sudo privileges ; exit 1; }

echo -e "\n\n"
echo "#################################"
echo "## Rails Ready -- Debian Lenny ##"
echo "#################################"

echo -e "\n"
echo "What this script gets you:"
echo " * An updated system"
echo " * Ruby $ruby_version_string on RVM"
echo " * Imagemagick"
echo " * libs needed to run Rails (sqlite, etc.)"
echo " * Bundler, Passenger, and Rails gems"
echo " * Git"

echo -e "\nThis script is always changing."
echo "Make sure you got it from https://github.com/vysogot/railsready-debian-lenny"

# Update the system before going any further
echo -e "\n=> Updating system (this may take a while)..."
sudo apt-get update >> $log_file 2>&1
# && sudo apt-get -y -V upgrade >> $log_file 2>&1
echo "==> done..."

# Install build tools
echo -e "\n=> Installing build tools..."
sudo apt-get -y -V install curl \
  git-core gcc make libxml2-dev libxslt-dev libopenssl-ruby \
  libncurses5-dev libreadline5-dev apache2-mpm-prefork apache2-prefork-dev \
  libapr1-dev libaprutil1-dev build-essential libcurl4-openssl-dev \
  libssl-dev zlib1g-dev libopenssl-ruby >> $log_file 2>&1
echo "==> done..."

# Configure backports and install SQLite3 from backports
echo -e "\n=> Configuring backports and installing libs needed for sqlite from backports..."
sudo su -c 'echo deb http://www.backports.org/debian lenny-backports main contrib non-free >> /etc/apt/sources.list'
sudo apt-get -y -V update >> $log_file 2>&1
sudo apt-get -y -V -t lenny-backports install sqlite3 libsqlite3-dev >> $log_file 2>&1
echo "==> done..."

# Install imagemagick
echo -e "\n=> Installing imagemagick (this may take awhile)..."
sudo apt-get -y install imagemagick libmagick9-dev >> $log_file 2>&1
echo "==> done..."

# Install git-core
echo -e "\n=> Installing git..."
sudo apt-get -y install git-core >> $log_file 2>&1
echo "==> done..."

# Install RVM
echo -e "\n=> Installing RVM the Ruby enVironment Manager http://rvm.beginrescueend.com/rvm/install/ \n"
bash < <( curl http://rvm.beginrescueend.com/releases/rvm-install-head )
echo -e "\n=> Setting up RVM to load with new shells..."
echo  '[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"  # Load RVM into a shell session *as a function*' >> "$HOME/.bashrc"
echo "==>done..."

# Load RVM to the shell
echo -e "\n=> Loading RVM..."
source ~/.rvm/scripts/rvm
source ~/.bashrc
echo "==> done..."

# Install zlib and openssl to configure them with Ruby
echo -e "\n=> Installing packages (zlib, openssl) to configure Ruby (this will take awhile)..."
rvm package install zlib openssl >> $log_file 2>&1
echo -r "\n==> done..."

# Install specific Ruby version
echo -e "\n=> Installing $ruby_version_string with zlib and openssl(this will take awhile)..."
echo -e "=> More information about installing Rubies can be found at http://rvm.beginrescueend.com/rubies/installing/ \n"
rvm install $ruby_version_string -C --with-zlib-dir=$HOME/.rvm/usr --with-openssl-dir=$HOME/.rvm/usr
echo -e "\n==> done..."

# Set new Ruby as a default interpreter
echo -e "\n=> Using $ruby_version_string and setting it as default for new shells..."
echo "=> More information about Rubies can be found at http://rvm.beginrescueend.com/rubies/default/"
rvm --default use $ruby_version_string >> $log_file 2>&1
echo "==> done..."

# Configure Ruby with readline lib
echo -e "\n=> Configuring Ruby readline lib"
cd ~/.rvm/src/$ruby_source_dir_name/ext/readline/
ruby extconf.rb >> $log_file 2>&1
make install >> $log_file 2>&1
echo "==> done..."

# Make directory for rails apps
echo -e "\n=> Making directory for Rails apps"
cd && mkdir rails_apps
echo "==> done..."

# Reload bash
echo -e "\n=> Reloading bashrc so Ruby and Rubygems are available..."
source ~/.rvm/scripts/rvm
source ~/.bashrc
echo "==> done..."

# Install bundler and rails
echo -e "\n=> Installing Bundler, Passenger and Rails..."
gem install mail bundler rails >> $log_file 2>&1
gem install passenger --version $passenger_version >> $log_file 2>&1
echo "==> done..."

# Prepare sudo installation and show the env
echo -e "\n=> Preparing apache-passenger installation..."
rvmsudo bash -c export
rvmsudo "rvm_path=/home/$script_runner/.rvm;passenger-install-apache2-module"
echo "==> done..."

# Install apache-passenger
# rvmsudo /home/$script_runner/.rvm/gems/$ruby_source_dir_name/bin/passenger-install-apache2-module
sudo touch /etc/apache2/mods-available/passenger.load
sudo su -c "echo 'LoadModule passenger_module /home/$script_runner/.rvm/gems/$ruby_source_dir_name/gems/passenger-$passenger_version/ext/apache2/mod_passenger.so' >> /etc/apache2/mods-available/passenger.load"
sudo touch /etc/apache2/mods-available/passenger.conf
sudo su -c "echo 'PassengerRoot /home/$script_runner/.rvm/gems/$ruby_source_dir_name/gems/passenger-$passenger_version' >> /etc/apache2/mods-available/passenger.conf"

# Show installation complete message
echo -e "\n"
echo -e "#################################"
echo -e "### Installation is complete! ###"
echo -e "#################################"
echo -e "Please logout/login to access run rails"
echo -e "\n"

echo -e "\n Thanks!\n-Jakub"
