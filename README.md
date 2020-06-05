# newpi
Scripts to configure a newly imaged Raspberry Pi device.

## Download and Run as pi user
```
curl -OL https://github.com/regnare/newpi/archive/master.zip
cd newpi-master
bash setup.sh
```

## Remove pi user
After your account is setup, remove the `pi` user.
```
sudo pkill -u pi
sudo userdel -r pi
```
