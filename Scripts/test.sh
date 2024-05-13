#!/bin/bash

rm ~/.ssh/id_rsa*
ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa
