# see
#
#    _posts/2014-02-05-cephforhpc-experiments-table.md
#
# for a list of dependencies and a description of how this script evolves

# issdm
mpi="mpirun -f=/users/ivo/hostfile32 -np"
ior="$HOME/ior/src/ior"
xfers="1m"
maxclients=256
i=10
blocksize="64m"
container=iod1
rados="rados"
user="client.ivo"
rados_client_flag="-n"

# laptop
#mpi="mpirun -np"
#ior="$HOME/projects/ior/src/ior"
#xfers="4k"
#maxclients=1
#i=1
#blocksize="4k"
#container="data"
#rados="$HOME/projects/ceph/src/rados"
#user=""
#rados_client_flag=""

# common

with_checkpoint=1
outfile="expout_1m"
#apis="IOD POSIX"
apis="IOD"

####################################


# checks the exit code of given command; fails if non-zero
function retcheck {
  "$@"
  local status=$?
  if [ $status -ne 0 ]; then
    echo "error with $1"
    exit 1
  fi
  return $status
}


####################################

echo "" > $outfile

for api in `echo $apis`
do

  for xfer in `echo $xfers`
  do
    let "n=1"

    while [ "$n" -le "$maxclients" ]
    do

      runid="f.x-$xfer.c-$n.b-$blocksize.0"

      date

      echo "executing f.x-$xfer.c-$n.b-$blocksize"

      retcheck ${mpi} $n ${ior} -a ${api} -w -z    -E -o ${runid} -b ${blocksize} -F -k -e -i${i} -m -t ${xfer} -d 0.1 -O iodcontainer=$container >> $outfile
      retcheck ${mpi} $n ${ior} -a ${api} -r -z -C    -o ${runid} -b ${blocksize} -F    -e -i${i} -m -t ${xfer} -d 0.1 -O iodcontainer=$container >> $outfile

      if [ "$with_checkpoint" -eq "1" ]
      then
        runid="f.x-$xfer.c-$n.b-$b.1"

        # create as many checkpoints as iterations
        retcheck ${mpi} $n ${ior} -a ${api} -w -z  -E -o ${runid} -b ${blocksize} -F -k -e -i${i} -m -t ${xfer} -d 0.1 -O iodcontainer=$container -O checkpoint=1 >> $outfile
        # execute one read test, that accesses the latest checkpoint
        retcheck ${mpi} $n ${ior} -a ${api} -r -z     -o ${runid} -b ${blocksize} -F -k -e -i 1   -m -t ${xfer} -d 0.1 -O iodcontainer=$container -O checkpoint=1 -O checkpointIdForReads=${i} >> $outfile

        # remove checkpoints
        for snap in $(eval echo "{1..$i}")
        do
          retcheck $rados $rados_client_flag $user -p $container rmsnap $snap
        done

        # delete objects that remain at HEAD snapshot (not measured)
        retcheck ${mpi} $n ${ior} -a ${api} -w     -E -o ${runid} -b 1k           -F    -e -i${i} -m -t 1k      -d 0.1 -O iodcontainer=$container > /dev/null
      fi

      date

      let "n = $n * 2"

    done #n

  done #xfer
done #api

echo "Operation   Max(MiB)   Min(MiB)  Mean(MiB)     StdDev    Mean(s) Test Tasks tPN reps fPP reord reordoff reordrand seed segcnt blksiz xsize aggsize API RefNum" > $outfile.csv
sed -ne'/Operation/,/Finished:/p' $outfile | sed -e's/Finished.*//g' | sed -e's/Operation.*//g' | grep 'read*\|write*' >> $outfile.csv
sed -i -e's/  */\t/g' $outfile.csv
