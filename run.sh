#!/bin/bash

. common.sh


load_properties prop.properties
if [ $? != 0 ]; then
    exit 1
fi

load_encrypted_properties encrypted.txt passwordfile.txt
if [ $? != 0 ]; then
    exit 1
fi

env | grep "P_"

echo END

