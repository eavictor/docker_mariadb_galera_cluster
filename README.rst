MariaDB Galera Cluster on Docker (not Docker Swarm)
===================================================

Docker MariaDB Galera Cluster using official image.


Credit
------
Based on this `tutorial`_ written by Vijay Singh Shekhawat.

.. _tutorial: https://www.binlogic.io/blog/galera-cluster-docker/


Claim
-----
I only tested on Ubuntu 18.04 LTS

`MariaDB Corporation has acquires Clustrix at September 20, 2018.`_

.. _MariaDB Corporation has acquires Clustrix at September 20, 2018.: https://mariadb.com/newsroom/press-releases/mariadb-acquires-clustrix-adding-distributed-database-technology/

I'm waiting for MariaDB release their acquired ClustrixDB, seems this is the solution which can beat Oracle RAC.

And please remain this for free (at least remain free if <= 7 servers for use to test auto sharding functions)


Installation
------------

0. Create ``db_data`` folder and clone repo

- This example assume username is eavictor, otherwise you have to modify ``yml`` files

.. code-block:: bash

    cd ~
    mkdir db_data
    git clone https://github.com/eavictor/docker_mariadb_galera_cluster.git


1. Install Docker-CE on each node

- Replace <username> with your username.

.. code-block:: bash

    sudo bash 1_install_docker.sh <username>


2. Install weave on each node

- Must apply ``Host*_IP`` and separate by "space", you can apply as many host as you want.
  If you want to setup a cluster with 5 hosts, then apply all 5 IPs as parameter,
  execute same command on each node.

- Note : Enter all hosts (including self) will showing 1 failure later, this does not impact performance.

.. code-block:: bash

    sudo bash 2_install_weave.sh <Host1_IP> <Host2_IP> <Host3_IP> ...


3. Edit MySQL configuration file on Host 1 to bootstrap Galera Cluster

- Edit ``wsrep_cluster_address``, value must be ``gcomm://``

- See `mariadb1_bootstrap_example.cnf`_ for how configured file looks like.

.. _mariadb1_bootstrap_example.cnf: mariadb1_bootstrap_example.cnf

- Note: Must modify mariadb1.cnf by yourself !!


4. Start Docker MariaDB on Host 1

.. code-block:: bash

    docker-compose -f mariadb1.yml up
    docker-compose -f mariadb1.yml up -d


5. Start Docker MariaDB on other Hosts

- Repeat this command on all nodes except the bootstrap node

- NOTE : On Host 2 and Host 3 after running the docker container the entrypoint script checks the mysqld service in the background after database initialization by using MySQL root user without password. Since Galera automatically performs synchronization through SST or IST when starting up, the MySQL root user password will change, mirroring the bootstrapped node. Thus, you would see the following error during the first start up:

- First Run (fail) :

.. code-block:: bash

    docker-compose -f mariadb*.yml up
    docker-compose -f mariadb*.yml up -d

- Second Run (start sync) :

.. code-block:: bash

    docker-compose -f mariadb*.yml up --no-recreate
    docker-compose -f mariadb*.yml up -d --no-recreate

6. Stop bootstrap container

- In our case, stop container on Host 1

.. code-block:: bash

    docker-compose -f mariadb1.yml stop


7. Modify configuration files, add galera communication hosts back

- See `mariadb1.cnf`_ ``gcomm://`` section, add those IPs/Hosts back and save.

.. _mariadb1.cnf: mariadb1.cnf


8. Start container on Host 1 again

- The following command won't recreate container

.. code-block:: bash

    docker-compose -f mariadb1.yml up --no-recreate
    docker-compose -f mariadb1.yml up -d --no-recreate