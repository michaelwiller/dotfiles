#!/usr/bin/env bash

# Uses https://github.com/paxtonhare/demo-magic/blob/master/demo-magic.sh
# Download/clone, and define DEMO_MAGIC_LIB to point at the folder

. $DEMO_MAGIC_LIB/demo-magic.sh

DEMO_PROMPT=""
DEMO_COMMENT_COLOR=${GREEN}
clear

pe 'ls .bash*' 
#export NO_WAIT=true
p '# Hello and welcome ..
I will add comments in here - to explain what is happening on the screen.
'

p '# This presentation should take around 15 minutes. 
Here is what you will see:
* A migration of schema information from an Oracle database to EDB Postgres Advanced Server
* Creation of a migration project in a copy of Migration Portal (running in HCP)
* Establish a connection from pgAdmin to the migrated database
* Show the content of the database, including migrated PL/SQL code.
'

p '# I have the following things available on my laptop
* a running Oracle instance (VM-based)
* EDB Hybrid Control Plane (EDB Postgres AI) is installed and running
'

p '# As a first step, I will create a migration project, inside HCP, using the extracted schema:'

p '# It seems that we have a slight error to deal with…
Using the included reference material it is easy to fix'

p '# Done - we have a 100% compatible schema, now we can migrate this to EPAS.'

p '# Now we can start migration.
Note that we can always download the SQL, using the offline migration:'

p '
# Or … we can migrate to a running database.
Notice that I have a few databases running in HCP… and one is an EPAS database
EPAS is the target for Migration Portal.:
'

p '# We can set up a connection and migrate directly from here..
However, there is a small diviation....
Since I am running Mac OS X with Docker Desktop and KIND (Kubernetes In Docker) 
so the connect strings displayed on the database cluster, will not work out of the box.
We just need to find the service that the external port is attached to.'

p '# To find the service we use the port number the service is shown to run at"'
pe 'kubectl get services | head -n 1 && kubectl get services -o wide --all-namespaces | grep 32027'

p "We now know the namespace the database is installed in (p-spkzwlasoq). And everything, else we need, follows that"
p "Here, we can use the internal service    p-spkzwlasoq-rw  available on port 5432."

pe 'kubectl get service -o wide --namespace p-spkzwlasoq'

p '# We can use that service name internally using the classic Kubernetes DNS.
DNS: (<service-name>.<namespace>.svc.cluster.local). 
So, the hostname will be: p-spkzwlasoq-rw.p-spkzwlasoq.svc.cluster.local.
I will set up the connection, test it and start the migration:'

p '# I want to show the content of the database using pgAdmin:'

p '# To connect from outside the Kubernetes cluster, I cannot use the connection strings shown in here
But, I can set up a port-forward and get a similar result.'

p '# We just need to run a port forword in the other pane'
p '# I will forward from port 8432 to the service <servicename>-rw-external on the service port 5432. Note, the port 32027 would work in a normal ops environment (KIND is not for production use).:'

pe 'kubectl get services | head -n 1 && kubectl get services -o wide --all-namespaces | grep 32027'
pe 'kubectl port-forward --namespace p-spkzwlasoq services/p-spkzwlasoq-rw-external 8432:5432'

p '# Now we can create a connection in pgAdmin and look at the code ...:'

p '# Note that the schema is there - and it contains PL/SQL that has barely been touched, now running on EPAS. This is the power of EPAS. With a 95% compatibility to Oracle, this reduces the risk of migrating (and the effort needed) significantly.'

p '# Thank you for watching'
