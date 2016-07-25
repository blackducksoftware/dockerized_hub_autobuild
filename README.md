# dockerized_hub_autobuild


###Intro

With this archive you can generate a docker image with the Black Duck software hub installed in the image.

You have to put the hub full installer in this directory, the file name has to have the following format:
appmgr.hubinstall.full*.zip


###Start script
Then you can start the build with the following command

for linux (tested on ubuntu 15.10 / 16.04 and mac)
```console
$./autobuild.sh -i|--image <image name> -l|--license <license string>
``` 

for mac :
```console
$./autobuildMac.sh -i|--image <image name> -l|--license <license string>
``` 
Note that the autobuild*.sh and install.sh have to have execution rights
```console
$chmod +x <file name>
```


### Generate a docker image whithout a license

To generate a image without a licecense do the above but use the autobuildNoLicense.sh script instead
