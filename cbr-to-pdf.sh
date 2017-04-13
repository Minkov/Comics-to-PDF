#!/bin/bash
convert_to_pdf() {
    FILE="$1"
    DEST_DIR="$2"

    BASE_NAME="$(basename "$FILE")"

    echo "-------------------------------------------"
    echo "Converting $BASE_NAME"
    echo "-------------------------------------------"

    TMP_DIR="$(mktemp -d)"

    if [[ "$FILE" == *cbr ]]; then
        unrar x "$FILE" "$TMP_DIR" > /dev/null
    else
        unzip "$FILE" -d "$TMP_DIR" > /dev/null
    fi;

    DEST_FILE_NAME=$DEST_DIR/"$BASE_NAME".pdf
    
    local IMAGES=()
    while read file; do
        IMAGES+=("$file")
       #("$file")
    done < <(find $TMP_DIR -type f -name '*.*' | sort)
    # xargs -0 convert "$DEST_FILE_NAME"

    convert "${IMAGES[@]}" "$DEST_FILE_NAME"  > /dev/null

    echo "-------------------------------------------"
    echo "Converted! $BASE_NAME!"
    echo "-------------------------------------------"

    rm -rf "$TMP_DIR"
}

doConvert() {
    counter=0
    SOURCE=$1
    DEST_DIR=$2
    THREADS_COUNT=$3

    FILES=("$SOURCE"/*)

    for FILE in "${FILES[@]}";
    do
        if [[ $counter == $THREADS_COUNT ]]; then
            wait;
            counter=0;
        fi
        let counter+=1
        convert_to_pdf "$FILE" $DEST_DIR &
    done;
    wait
}

THREADS_COUNT=16

SOURCE_DIR=$1
DEST_DIR=$2

mkdir -p "$DEST_DIR"

time doConvert "$SOURCE_DIR" $DEST_DIR $THREADS_COUNT

wait
