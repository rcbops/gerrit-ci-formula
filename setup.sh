#!/bin/bash
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}")" && pwd)
MODULES_SRC_DIR=${DIR}/modules
MODULES_DST_DIR=${DIR}/../_modules

# Install custom modules
mkdir -p ${MODULES_DST_DIR}
cp ${MODULES_SRC_DIR}/jenkins.py ${MODULES_DST_DIR}/jenkins.py

# Generate ssh key for gerrit
mkdir -p $DIR/gerrit/files/keys/
ssh-keygen -t rsa -N "" -f $DIR/gerrit/files/keys/id_rsa
echo "Created keypair for gerrit at $DIR/gerrit/files/keys/id_rsa"

# Generate ssh key for jenkins
mkdir -p $DIR/jenkins/files/keys/
ssh-keygen -t rsa -N "" -f $DIR/jenkins/files/keys/id_rsa
echo "Created keypair for jenkins at $DIR/jenkins/files/keys/id_rsa"

# Generate uuid for jenkins credentials file
if [ ! -e ${DIR}/jenkins/files/credentials_uuid ]; then
    python -c "import uuid; print uuid.uuid4()" > ${DIR}/jenkins/files/credentials_uuid
fi
