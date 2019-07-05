MariaDB Galera Cluster on Docker (not Docker Swarm)
===================================================

Docker MariaDB Galera Cluster using official image.

Claim
-----
I only tested on Ubuntu 18.04 LTS

`MariaDB Corporation has acquires Clustrix at September 20, 2018.`_

.. _MariaDB Corporation has acquires Clustrix at September 20, 2018.: https://mariadb.com/newsroom/press-releases/mariadb-acquires-clustrix-adding-distributed-database-technology/

I'm waiting for MariaDB release their acquired ClustrixDB, seems this is the solution which can beat Oracle RAC.

And please remain this for free (at least remain free if <= 7 servers for use to test auto sharding functions)

Credit
------
Based on this `tutorial`_ written by Vijay Singh Shekhawat.

.. _tutorial: https://www.binlogic.io/blog/galera-cluster-docker/


Installation
------------


1. Install Docker-CE on each node

- Replace <username> with your username.

.. code-block:: bash

    sudo bash 1_install_docker.sh <username>


2. Install weave on each node

- Must apply ``Host*_IP`` and separate by "space", you can apply as many host as you want.
  If you want to setup a cluster with 5 hosts, then apply all 5 IPs as parameter,
  execute same command on each node.

.. code-block:: bash

    sudo bash 2_install_weave.sh <Host1_IP> <Host2_IP> <Host3_IP> ...


3. Edit MySQL configuration file on Host 1 to bootstrap Galera Cluster

- Edit ``wsrep_cluster_address``, value must be ``gcomm://``

- See `mariadb_bootstrap_example.cnf`_ for how configured file looks like.

.. _mariadb_bootstrap_example.cnf: mariadb_bootstrap_example.cnf

- Note: Must modify mariadb.cnf by yourself !!


4. Start Docker MariaDB on Host 1

.. code-block:: bash

    docker-compose up -f mariadb1.yml -d


5. Start Docker MariaDB on other Hosts

- Repeat this command on all nodes except the bootstrap node

.. code-block:: bash

    docker-compose up -f mariadb*.yml -d


6. Stop bootstrap container

- In our case, stop container on Host 1

.. code-block:: bash

    docker-compose stop


7. Modify configuration files, add galera communication hosts back

- See `mariadb.cnf`_ ``gcomm://`` section, add those IPs/Hosts back and save.

.. _mariadb.cnf: mariadb.cnf


8. Start container on Host 1 again

- The following command won't recreate container

.. code-block:: bash

    docker-compose up -d --no-recreate