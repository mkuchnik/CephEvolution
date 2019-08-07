filename="${1}"
iodepth=256
size="10G"
mkdir rbd-tests
for rw in "write" "randwrite" "read" "randread"; do
for i in 4096 2048 1024 512 256 128 64 32 16 8 4; do
  bs="${i}K"
  echo "bs ${bs}"
  cmd="sudo fio --ioengine=libaio --direct=1 --bs=${bs} --iodepth=${iodepth} \
    --end_fsync=0 \
    --rw=${rw} --norandommap --size=${size} --numjobs=1 \
    --ramp_time=None --name=rbd_test \
    --filename=${filename}"
  eval ${cmd} | tee rbd-tests/${rw}-${iodepth}-${bs}.txt
done
done