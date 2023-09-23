#

load_properties_from_data() {
	IFS=$'\n'
	local lines=( $1 )
	local filename=$2

	local n=${#lines[*]}
	local i=0

	for ((i = 0; i < n; i++)); do
		local line=${lines[$i]}

		# 正規化
		line=$(echo $line | sed -E 's/^ *//;s/^#.*//;s/^([a-zA-Z0-9_]+)="(.*)"$/\1=\2/')

		# 空行無視
		[[ -z $line ]] && continue

		if [[ $line =~ ^([a-zA-Z0-9_]+)=(.*)$ ]]; then
			local key=${BASH_REMATCH[1]}
			local value=${BASH_REMATCH[2]}

			# 大文字にする
			key=${key^^[a-z]}

			# OK!
			echo $filename:$((i+1)): OK. ${key} = ${value}
			eval export ${key}='${value}'
		else
			echo $filename:$((i+1)): bad line: $line
		fi
	done
}

load_properties() {
	local filename=$1
	IFS=
	local data=$(< $filename)
	load_properties_from_data $data $filename
}

load_encrypted_properties() {
	local input_file=$1
	local password_file=$2
	IFS=
	local data=$(decrypt_file $input_file $password_file)
	load_properties_from_data $data $input_file
}

decrypt_file() {
	local input_file=$1
	local password_file=$2
	openssl enc -aes-256-cbc -d -in $input_file -kfile $password_file 2>/dev/null
}

