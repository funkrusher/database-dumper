# Database Dumper

`database-dumper` is a tool that can be used within a software-project, to help with typical developers-tasks / release-manager-tasks of preparing a specific database in ETL (Extract, Transfer, Load) fashion from one environment to another.

- by using docker, the tool is independent of the os (can be used in Windows, Linux, ...)
- by using gitlab, the tool can be used within scheduled gitlab-pipelines to do its task (preparing a testing-system with a live-dump, for example)
- by using database-sanitizer, the tool can sanitize its dumps by replacing sensitive data with help of self-written python-scripts.

# Concepts

- **Entity**: An entity is a specific database, that runs on multiple environments (beta, local, local2, production, staging, testing) but always means the same entity.
- **Config**: The config-folder contains all relevant configs, which can be prepared by the developer for his/her environments.
  - **Environments**: An environment groups together the database-connection-settings for all entities that run on this environment (beta, local, local2, production, staging, testing). It's up to the user of this tool to decide which environments are relevant for his product and remove unnecessary environments or create new ones.
    - The filenames in each environment-folder have a unique name, that is used in all other config-folders to identity this entity (entity-name)
  - **Flows**: A flow defines which entity should be dumped from a source-environment to a target-environment. The flow helps to have a safe way to start our database-dumping and importing, because it defines reoccuring activities (dumping, importing) in a central place for reusing.
  - **Sanitizers**: For each of the entities a sanitizer can be used, which helps to replace sensitive data (email, firstname, lastname, ...) during the dumping with obfuscated data. We use the following project for this feature:
    - https://github.com/andersinno/python-database-sanitizer

# Configuration

Its up to you, to prepare all configuration-files within the `config/*`-Folder of this project. 
- You need to provide your database-settings in the `config/environments/*`-Folders 
- You need to define flow-files in the `config/flows`-Folder for all your relevant tasks, that you want to use on either Local Developer-PCs and/or Gitlab-Pipelines.
- You need to defined sanitizers-files in the `config/sanitizers`-Folder for all your databases, that also contain sensitive data (email, firstname, lastname,...) that you want to obfuscate. For explanation how to do this, also see:
  - https://github.com/andersinno/python-database-sanitizer

## Environment-Configfile

This file has the following parameters:
```
HOST=host.docker.internal
USER=xxx
PASS=xxx
PORT=3306
BASE=databasename
```

Please use `host.docker.internal` if the database resides on your Host-PC that is running the Docker-Container. Otherwise you can use an IP-Adress, Hostname, etc.

Be careful with passwords, and better leave those empty for the Developers to fill them out themselves. You should not commit the passwords to your git. Better use CI/CD-Variables within Gitlab to provide the passwords to the Gitlab-Pipelines.

## Flow-Configfile

This file has the following parameters:
```
ENTITY=databasename
SOURCE=local
TARGET=local2
```
The ENTITY-Parameter is used for identifying the files in the Environments-Folder and in the Sanitizers-Folder.
- The ENTITY-Parameter is mandatory
- Sanitization is only done for the SOURCE, if there is a config-file for the entity in the `config/sanitizers`-Folder.

The SOURCE/TARGET-Parameters are used to define the Source-Environment in the Environments-Folder from which the data is dumped and the Target-Environment in the Environments-Folder to which the data is imported.
- The SOURCE/TARGET-Parameters are both optional
- Dumping/Sanitization is only done if there is a SOURCE-Parameter defined in the flow
- Importing is only done if there is a TARGET-Parameter defined in the flow

## Sanitizers-Configfile

Each Sanitzer-Configfile must be exactly named like the entity.
The root-Folder of the project contains an `requirements.txt`-File. This file defines all relevant python-libraries that are used within the Sanitization-Scripts.


# Local Usage

Before running it, make sure to prepare your `config/environments`-Folder by preparing all the Templates and copying them from `config/environments/xxx/templates/x.env` to `config/environments/xxx/x.env` 

`database-dumper` can be used like this, to execute a specific flow:

```
docker-compose --env-file ./config/flows/flow.env up
```

This command can be used on your local developers PC to dump Live/Staging-databases and import them in your local database.

# Gitlab Usage

`database-dumper` can be used within Gitlab-Pipelines, by merging the branch of the project into a specific branch that triggers the Gitlab-Pipeline.

The project contains an example `.gitlab-ci.yml`-file that can be used as an example.

# Dumps-Folder

the `dumps`-Folder contains the database-dumps that have been created by a run. The dumps are named by the entity-name and the current day/date.

# Scripts-Folder

The `scripts`-Folder contains the Bash-Scripts that are used to create/import dumps. The `dumper.sh`-Script is called by the docker-container when it starts up exactly once, and will execute exactly one given flow which first does an dump and afterwards an import (as defined by the flow). 