#Rails Ready for Debian Lenny

##Get a full Ruby on Rails stack up very fast on Debian Lenny

###This project is inspired by https://github.com/joshfng/railsready/ by Joshua Frye which refers to Ubuntu Server 10.04 LTS. Check it out!

##Run this on a fresh Debian Lenny install.

##To run:
  * `bash < <( wget --no-check-certificate https://github.com/vysogot/railsready/raw/master/railsready-debian-lenny.sh)`
  * If you want to watch the install log run `tail -f ~/railsready/install.log` in a next shell (ALT+<F2-F6> for non-gui)

##What this gives you:

  * An updated system
  * Apache
  * Ruby 1.9.2-p136 on RVM running 1.9.2p136
  * Imagemagick
  * libs needed to run Rails (sqlite, etc.)
  * Bundler, Passenger, and Rails gems
  * Git

Please note: If you are running on a super slow connection your sudo session may timeout and you'll have to enter your password again.

I use this to setup VMs. For any suggestions: jakub.godawa@gmail.com
