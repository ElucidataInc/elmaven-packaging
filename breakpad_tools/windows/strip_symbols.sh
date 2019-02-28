BIN_PATH=$1
binary_path=$2
binary_name=$3
pdb_file="$binary_name.pdb"
symbol_file="$binary_name.sym"

chmod +x dump_syms

$BIN_PATH/windows/cv2pdb.exe "$binary_name.exe"

$BIN_PATH/windows/dump_syms $pdb_file > $symbol_file

uuid=$(head -n1 $symbol_file | grep -o -P "(?<=x86_64).*(?=$pdb_file)" | xargs ) 


mkdir -p ../symbols/"$binary_name.pdb"/$uuid/

mv $symbol_file ../symbols/"$binary_name.pdb"/$uuid/

chmod +x $BIN_PATH/windows/sentry-cli.exe 

$BIN_PATH/windows/sentry-cli --auth-token 00985397724343d496af4d0f88dd8c79adc5f7a5433b4ed9881b9535d0bc5eb4 upload-dif -t breakpad --project el-maven-logging --org test-acc ../symbols/
