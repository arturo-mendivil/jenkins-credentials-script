# Jenkins credentials script

This is a script for downloading required files used in [jenkins-credential-decryptor](https://github.com/hoto/jenkins-credentials-decryptor).

These are the files the script looks for:
- credentials.xml
- hudson.util.Secret
- master.key
- config.xml from jobs

For this script to work, it is needed:
- Server PEM file
- User and IP to login to server

To run the script use:
`./main.sh --pem_file <path-to-file> --user <jenkins-user> --ip <server-ip>`

Or to get help use: 
`./main.sh --help`

After the files are downloaded, jenkins-credential-decryptor binary can be used to decrypt the credentials.xml or config.xml files, for example: 
```
./jenkins-credentials-decryptor \
-m output/master.key \
-s output/hudson.util.Secret \
-c output/credentials.xml \
-o json >> output/decrypted-credentials.json 
```