filename="${1}"
iodepth=256
size="100M"
mkdir ec_rbd-tests
#for rw in "write" "randwrite" "read" "randread"; do
for rw in "randwrite"; do
for i in 4; do
  bs="${i}K"
  echo "bs ${bs}"
  cmd="sudo fio --ioengine=libaio --direct=1 --bs=${bs} --iodepth=${iodepth} \
    --end_fsync=0 \
    --rw=${rw} --norandommap --size=${size} --numjobs=1 \
    --ramp_time=None --name=rbd_test \
    --filename=${filename}"
  eval ${cmd}  | tee ec_rbd-tests/${rw}-${iodepth}-${bs}-4-2-filestore.txt
done
done