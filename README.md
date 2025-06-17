# scp-file-copy
Repository with script for copying files between hosts to multiple destination paths.

## Requirements
- bash
- ssh (openssh-server)
- rsync
- python
- cron (optional)
- ansible (on coordinator host)

## Configuration
Here is example of configuration, it can be edited under `roles/rsync_copy/defaults/main.yml`:
```
copy_tasks:
  - source_host: ubuntu1
    source_user: root
    source_path: /files/src1
    target_hosts: 
    - host: ubuntu2
      user: root
      target_paths: 
      - /files/dest1
      - /files/dest2
      - /files/dest3
      - /files/dest4
    - host: ubuntu3
      target_paths: 
      - /files/dest1
  - source_host: ubuntu2
    user: root
    source_path: /files/src1
    target_hosts: 
    - host: ubuntu1
      target_paths: 
      - /files/dest5
    - host: ubuntu3
      target_paths: 
      - /files/dest2
```
With configuration above script will:
- copy files from /files/src1 on ubuntu1
    - to /files/dest1 on ubuntu2
    - to /files/dest2 on ubuntu2
    - to /files/dest3 on ubuntu2
    - to /files/dest4 on ubuntu2
- copy files from /files/src1 on ubuntu2
    - to /files/dest5 on ubuntu1
    - to /files/dest2 on ubuntu3

Script will automatically check if files were copied successfully and if not it will log it to local log files under `/var/log/ansible-sync.log`</br>
If file has been sucessfully copied it will be deleted from source host directory.</br>

## Running bare script
1. Make sure your hosts meet requirements (see above)
2. Clone this repository or copy its data to your coordinator host. This may be almost every host with ansible nad networking to hosts from configuration (it may be also a host from configuration)
3. The best way to run this script is to provide ssh-keys and public keys on dependent hosts:
- to allow coordinator host ssh connections to all hosts mentioned in configuration
- to allow rsync copy (over ssh) from source hosts to target hosts (depends on your configuration)
- additionaly make sure that all dependent hosts know each other fingerprints, auto accept fingerprints is not recommended
4. Provide files in source hosts
5. run `ansible-playbook ./repo/playbook.yaml`
6. Optionaly set cron for this or use tool like AWX/Ansible Tower/Semaphore to copy files periodically. Example cron to run this script every 5 minutes: */5 * * * * ansible-playbook /repo/playbook.yaml

## Running local tests with docker and docker-compose
This repository provides docker-compose configuration and Dockerfile for building test nodes.</br>
This is step by step instruction how to run tests locally:
1. Clone this repository
2. Create demo ssh keys:
>cd ./build-ssh-ubuntu/demo-keys</br>
bash create-demo-keys.sh</br>
3. From root of repository run:
>docker-compose up -d --build</br>
4. Check if containers are running:
>docker-compose ps
```
NAME      IMAGE                   COMMAND       SERVICE   CREATED         STATUS         PORTS
ubuntu1   scp-file-copy-ubuntu1   "/start.sh"   ubuntu1   5 minutes ago   Up 5 minutes   0.0.0.0:2022->22/tcp
ubuntu2   scp-file-copy-ubuntu2   "/start.sh"   ubuntu2   5 minutes ago   Up 5 minutes   0.0.0.0:3022->22/tcp
ubuntu3   scp-file-copy-ubuntu3   "/start.sh"   ubuntu3   5 minutes ago   Up 5 minutes   0.0.0.0:4022->22/tcp
```
Created containers have:
- mounted this repository under `/repo`
- mounted `./files/ubuntu<id>` under `/files` for source/destination files when copying data
- mounted `./files/logs/ubuntu<id>_log` under `/var/log` for easy script log checking

5. Provide two bulks of test files to copy. Paste them into `./files/ubuntu1/src1` and `./files/ubuntu2/src1`
6. Jump on any container, example on ubuntu1
>docker-compose exec -it ubuntu1 bash
7. Apply fingerprints on all test containers. Run inside any container:
>bash /repo/get-fingerprints.sh
8. Finally run script
>ansible-playbook /repo/playbook.yaml
9. Wait till script finishes, then check results. It should have copied your files from `src` directiories into destination directories as it has been configured in `roles/rsync_copy/defaults/main.yml`
10. Check logs, it should appear in `./files/logs/ubuntu<id>_log/ansible-sync.log`
11. Optionaly: setup cron inside container to run script periodically.
>crontab -e
Example cron to run this script every 5 minutes: `*/5 * * * * ansible-playbook /repo/playbook.yaml`
