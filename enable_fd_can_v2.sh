BLUE='\033[0;34m'
echo -e "\n"
echo -e "${BLUE}Activating CAN FD Bus\n"

# https://canable.io/getting-started.html#socketcan-linux
# -s8 parameter below is 1MBps

sudo modprobe can
sudo modprobe can_raw
sudo modprobe slcan

#PORT=$(ls -1 /dev/ttyACM* | tail -n1)
#sudo slcand -o -c -s8 $PORT can0
sudo slcand -o -c -s8 /dev/ttyACM0 can0
sudo ifconfig can0 up
sudo ifconfig can0 txqueuelen 1000

echo -e "${BLUE}Actived CAN FD Bus and dumping messages below\n"

candump can0

exit 0

