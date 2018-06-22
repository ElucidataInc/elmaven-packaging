binary_path=$1
binary_name=$2
symbol_file="$binary_name.sym"

chmod +x dump_syms

./dump_syms $binary_path > $symbol_file

uuid=$(head -n1 $symbol_file | grep -o -P "(?<=x86_64).*(?=$binary_name)" | xargs ) 


mkdir -p symbols/$binary_name/$uuid/

mv $symbol_file symbols/$binary_name/$uuid/

chmod +x 

./sentry-cli --auth-token 00985397724343d496af4d0f88dd8c79adc5f7a5433b4ed9881b9535d0bc5eb4 upload-dif -t breakpad --project el-maven-logging --org test-acc ./symbols/
