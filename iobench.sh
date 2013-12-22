# iobench: Simple I/O benchmarking script for roughly measuring 8K read speed
# on a Linux machine.
# Matt Davies @mdaviesnet http://blog.mdavies.net/

TIMEFORMAT=%R
read -p "Enter your instance RAM size (GB): " ramSize
read -p "Enter a path disk for testing against ie /data (no trailing slash): " path

writeCount=`bc -l <<< "scale=0; $ramSize * 1024 * 1024 / 8 * 2"`
echo
echo "Testing sequential 8K write speed, please wait..."

# Measure the time taken to write a file 2xRAM size to disk and synch it.
# At this size, we are making sure caching can have little effect.

writeTime=`time (sh -c "dd if=/dev/zero of=$path/ddfile bs=8k count=$writeCount > /dev/null 2>&1 && sync") 2>&1`
writeSpeed=`bc -l <<< "scale=0; $writeCount * 8 / $writeTime / 1024"`

echo "Write speed: $writeSpeed MB/s"

# Write a file the size of RAM to disk to flush the filesystem cache.
# There are other ways to achieve this, but I found this method to be
# the most reliable on the CentOS image I'm using.

echo
echo "Flushing the filesystem cache..."

flushCount=`bc -l <<< "scale=0; $writeCount / 2"`
dd if=/dev/zero of=$path/ddfile2 bs=8K count=$flushCount > /dev/null 2>&1

# This last test is now pretty simple - just read in the original
# file from the write speed test.

echo
echo "Testing 8K sequential read speed, please wait..."

readTime=`time (sh -c "dd if=$path/ddfile bs=8K > /dev/null 2>&1") 2>&1`
readSpeed=`bc -l <<< "scale=0; $writeCount * 8 / $readTime / 1024"`

echo "Read speed: $readSpeed MB/s"
echo