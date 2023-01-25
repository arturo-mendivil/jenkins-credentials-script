# Jenkins credentials script

This is a script for downloading required files used in [go-decrypt-jenkins](https://github.com/thesubtlety/go-decrypt-jenkins).

These are the files the script looks for:
- credentials.xml
- hudson.util.Secret
- master.key
- SecretBytes.key
- config.xml from jobs

For this script to work, it is needed:
- Server PEM file
- Server User
- Server IP

To run the script use:
`./main.sh --pem_file <path-to-file> --user <jenkins-user> --ip <server-ip>`

Or to get help use: 
`./main.sh --help`

The result is an output folder, with the server files.
```
└── output
    ├── credentials.xml
    ├── master.key
    ├── hudson.util.Secret
    ├── com.cloudbees.plugins.credentials.SecretBytes.KEY
    ├── jobs
    │   ├── example_job_1
    │   │   └── config.xml
    │   ├── example_job_2
    │   │   └── config.xml
    .   .
    .   .
    .   .
```
After the files are downloaded, jenkins-credential-decryptor binary can be used to decrypt the credentials.xml or config.xml files.

For credentials.xml files, use:
```
./go-decrypt-jenkins \
-m output/master.key \
-s output/hudson.util.Secret \
-c output/credentials.xml >> output/decrypted-credentials.xml
```
For config.xml files, use: 
```
./go-decrypt-jenkins \
-m output/master.key \
-s output/hudson.util.Secret \
-c output/jobs/example_job_1/config.xml \
-sb output/com.cloudbees.plugins.credentials.SecretBytes.KEY >> output/decrypted-config.xml
```
