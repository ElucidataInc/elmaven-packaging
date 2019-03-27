breakpad_path=$1
binary_path=$2
binary_name=$3
symbol_file="$binary_name.sym"
dsym_file="$binary_name.dSYM"

$breakpad_path/mac/dump_syms -g $dsym_file $binary_path > $symbol_file

uuid=$(head -n1 $symbol_file | ggrep -o -P "(?<=x86_64).*(?=$binary_name)" | xargs ) 


mkdir -p ../symbols/$binary_name/$uuid/

mv $symbol_file ../symbols/$binary_name/$uuid/


$breakpad_path/mac/sentry-cli --auth-token 00985397724343d496af4d0f88dd8c79adc5f7a5433b4ed9881b9535d0bc5eb4 upload-dif -t breakpad --project el-maven-logging --org el-maven ../symbols/
