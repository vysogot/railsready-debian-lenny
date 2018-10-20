Quite outdated

# Rails Ready for Debian Lenny

## Get a full Ruby on Rails stack up very fast on Debian Lenny

UPDATE: it also works for Debian 6.0x Squeeze

This project is inspired by https://github.com/joshfng/railsready/ by Joshua Frye which refers to Ubuntu Server 10.04 LTS. Check it out!

## Run this on a fresh Debian Lenny install.

## To run
  * `wget --no-check-certificate https://github.com/vysogot/railsready-debian-lenny/raw/master/railsready-debian-lenny.sh && bash railsready-debian-lenny.sh`
  * If you want to watch the install log run `tail -f ~/rails_install.log` in a next shell (ALT+<F2-F6> for non-gui)

## What this gives you?

In order of being installed:

  * an updated system with necessary packages
  * SQLite3 from lenny-backports
  * imagemagick
  * git-core
  * RVM
  * Ruby 1.9.2-p136 on RVM
  * Configure Ruby for Debian
  * Bundler, Passenger, and Rails gems
  * Apache + Phusion Passenger slightly configured

## What you should do by yourself?

  * Create new rails appliaction
  * Configure Apache virtual host that points to it
  * Browse the app :)

Please note: If you are running on a super slow connection your sudo session may timeout and you'll have to enter your password again.

I use this to setup VMs. For any suggestions: jakub.godawa@gmail.com
