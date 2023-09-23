#!/bin/bash

. common.sh


#load_properties prop.properties
load_encrypted_properties encrypted.txt passwordfile.txt

env | grep "P_"

echo END
