#!/usr/bin/env bats

# One-time setup code for all tests
apk update
apk add bash curl docker git make openssh shadow
#sed "s/\(^docker.\+$\)/\1root/" < /etc/group > ./temp_group
#cp ./temp_group /etc/group
usermod -a -G docker $(whoami)
git clone https://github.com/vanvalenlab/kiosk.git
cd kiosk
make init
#cat /etc/group
#bash
sed 's/sudo -E //' < ./Makefile > ./temp_makefile
cp ./temp_makefile ./Makefile
make docker/build
make install
echo "Did stuff"

#setup() {
#kiosk
#}




@test "View cluster IP before configuring cluster" {
run kiosk <<EOF

v

e

EOF
echo "Whatevre"
[ "$status" -eq 0 ]
#[[ "$output" =~ "The cluster's address is:  No current address -- no cluster has been started yet." ]]
}
