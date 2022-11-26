FROM python:3.8-slim-buster

RUN apt-get update && apt-get install -y build-essential mariadb-client dos2unix && rm -rf /var/lib/apt

RUN pip install database-sanitizer[MySQL]

# we want to keep the dumper in a volume, to be able to edit files without needing to rebuild the docker-image
# volumes / volume-mappings are only assigned via docker-compose just as the container is started.
# therefore we put everthing related to setup/start of the dumper-script in one command, that will be started
# evertime when the container is started and after the volume is already available to the container.
CMD cd /dumper; pip install -r requirements.txt; dos2unix /dumper/scripts/*.sh; chmod +x /dumper/scripts/*.sh; /dumper/scripts/dumper.sh