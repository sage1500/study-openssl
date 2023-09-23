#

# データからプロパティ読込
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

            # 環境変数に変換
            eval export ${key}='${value}'
        else
            # 行フォーマット異常
            echo ${filename}:$((i+1)): bad line: $line
            return 1
        fi
    done
}

# プロパティファイル読込
load_properties() {
    local filename=$1

    # ファイル存在チェック
    if [ ! -f $filename ]; then
        echo "file not found: $filename" 1>&2
        return 1
    fi

    # ファイル読込
    IFS=
    local data
    data=$(< $filename)
    if [ $? != 0 ]; then
        echo "property file read failed. file=$filename" 1>&2
        return 1
    fi

    # プロパティ読込
    load_properties_from_data $data $filename
}

# 暗号化されたプロパティファイル読込
load_encrypted_properties() {
    local input_file=$1
    local password_file=$2

    # ファイル存在チェック
    if [ ! -f $input_file ]; then
        echo "file not found: $input_file" 1>&2
        return 1
    fi

    # ファイル存在チェック
    if [ ! -f $password_file ]; then
        echo "file not found: $password_file" 1>&2
        return 1
    fi

    # 復号化 
    IFS=
    local data
    data=$(decrypt_file $input_file $password_file)

    if [ $? != 0 ]; then
        echo "decrypt failed." 1>&2
        return 1
    fi

    # プロパティ読込
    load_properties_from_data $data $input_file
}

# 復号化
decrypt_file() {
    local input_file=$1
    local password_file=$2
    #openssl enc -aes-256-cbc -d -in $input_file -kfile $password_file
    openssl enc -aes-256-cbc -d -in $input_file -kfile $password_file 2>/dev/null
}

