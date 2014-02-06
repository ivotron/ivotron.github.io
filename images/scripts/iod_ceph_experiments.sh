# see
#
#    _posts/2014-02-05-cephforhpc-experiments-table.md
#
# for a list of dependencies and a description of how this script evolves

# issdm
mpi="mpirun -f=/users/ivo/hostfile4 -np"
ior="$HOME/ior/src/ior"
xfers="4096 524288 1048576"
maxclients=32
i=10
block_size_factor="1 10 100"
container=iod1
num_checkpoints_before_first_read="10"
rados="rados"
user="client.ivo"
rados_client_flag="-n"

# laptop
#mpi="mpirun -np"
#ior="$HOME/projects/ior/src/ior"
#xfers="4096"
#maxclients=1
#i=1
#block_size_factor="1"
#container="data"
#num_checkpoints_before_first_read=1
#rados="$HOME/projects/ceph/src/rados"
#user=""
#rados_client_flag=""

# common

with_checkpoint=1
outfile="expout"
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

      for blocks in `echo $block_size_factor`
      do

        let b="${xfer} * ${blocks}"

        runid="p.$xfer.$n.$b.0"

        date

        echo "executing $runid"

        retcheck ${mpi} $n ${ior} -a ${api} -w -z    -E -o ${runid} -b ${b} -F -k -e -i${i} -m -t ${xfer} -d 0.1 -O iodcontainer=$container >> $outfile
        retcheck ${mpi} $n ${ior} -a ${api} -r -z -C    -o ${runid} -b ${b} -F    -e -i${i} -m -t ${xfer} -d 0.1 -O iodcontainer=$container >> $outfile

        if [ "$with_checkpoint" -eq "1" ]
        then
          runid="p.$xfer.$n.$b.1"

          # create as many checkpoints as iterations
          retcheck ${mpi} $n ${ior} -a ${api} -w -z    -E -o ${runid} -b ${b} -F -k -e -i${num_checkpoints_before_first_read} -m -t ${xfer} -d 0.1 -O iodcontainer=$container -O checkpoint=1 >> $outfile
          # execute one read test, that accesses the latest checkpoint
          retcheck ${mpi} $n ${ior} -a ${api} -r -z       -o ${runid} -b ${b} -F -k -e -i 1                                   -m -t ${xfer} -d 0.1 -O iodcontainer=$container -O checkpoint=1 -O checkpointIdForReads=${num_checkpoints_before_first_read} >> $outfile

          # remove checkpoints
          for snap in $(eval echo "{1..$num_checkpoints_before_first_read}")
          do
            retcheck $rados $rados_client_flag $user -p $container rmsnap $snap
          done

          # delete remaining objects (not measured)
          retcheck ${mpi} $n ${ior} -a ${api} -w    -E -o ${runid} -b 1k -F    -e -i 1 -m -t 1k -d 0.1 -O iodcontainer=$container > /dev/null
        fi

        date

      done #blocks

      let "n = $n * 2"

    done #n

  done #xfer
done #api

echo "Operation   Max(MiB)   Min(MiB)  Mean(MiB)     StdDev    Mean(s) Test# #Tasks tPN reps fPP reord reordoff reordrand seed segcnt blksiz xsize aggsize API RefNum" > $outfile.csv
sed -ne'/Operation/,/Finished:/p' $outfile | sed -e's/Finished.*//g' | sed -e's/Operation.*//g' | grep 'read*\|write*' >> $outfile.csv
sed -i -e's/  */\t/g' $outfile.csv
