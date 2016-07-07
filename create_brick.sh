#!/bin/bash
# Create a new brick on your GlusterFS

if [ "$1" = "" ] || [ "$2" = "" ]
then
	echo "Usage: create_brick.sh brick_name mount_point"
	echo "i.e: ./create_brick.sh brickX /dev/sdX"
	echo "Make sure the /dev/sdX reprents the disk you are looking for to create the brick on !"
	exit
fi

BRICKNAME=$1
MOUNTPOINT=$2

# Get settings from the file
source cluster/settings

# Create the brick on all nodes
for (( i=1; i<=${COUNT}; i++ ))
do
	# format disk
	echo "Formating the disk if not formated already ..."
	gcloud compute ssh --zone ${REGION}-${ZONES[$i-1]} ${SERVER}-${i} --command \
	"sudo file -sL ${MOUNTPOINT} | grep XFS || sudo mkfs.xfs -i size=512 ${MOUNTPOINT}"
	echo " "
	echo "Mounting the following brick: ${BRICKNAME}"
	gcloud compute ssh --zone ${REGION}-${ZONES[$i-1]} ${SERVER}-${i} --command \
	"sudo mkdir -p /data/${BRICKNAME} && echo '${MOUNTPOINT} /data/${BRICKNAME} xfs defaults 1 2' | sudo tee -a /etc/fstab && sudo mount -a && mount"
	echo " "
done

echo "Your new brick ${BRICKNAME} should now be ready to use."