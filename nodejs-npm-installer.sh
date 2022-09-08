```
# version: 16.17.0
# get current stable recommended version link from https://nodejs.org/en/download/
#

wget https://nodejs.org/dist/v16.17.0/node-v16.17.0-linux-x64.tar.xz

tar xf node-v16.17.0-linux-x64.tar.xz

cp -R node-v16.17.0-linux-x64 /usr/share/nodejs

ln -s /usr/share/nodejs/bin/node /usr/bin/
ln -s /usr/share/nodejs/bin/npm  /usr/bin/
```
