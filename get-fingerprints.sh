#!/bin/bash
ssh ubuntu1 'ssh-keyscan ubuntu1 ubuntu2 ubuntu3 >> /root/.ssh/known_hosts'
ssh ubuntu2 'ssh-keyscan ubuntu1 ubuntu2 ubuntu3 >> /root/.ssh/known_hosts'
ssh ubuntu3 'ssh-keyscan ubuntu1 ubuntu2 ubuntu3 >> /root/.ssh/known_hosts'