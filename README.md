# dockerized_hub_autobuild

With this archive you can generate a docker image with the Black Duck software hub installed in the image.

You have to put the hub full installer in this directory, the file name has to have the following format:
appmgr.hubinstall.full*.zip

Then you can start the build with starting the autobuild.sh with the parameters <image name> <license>

Note that the autobuild.sh and install.sh have to have execution rights
chmod +x <file name>
