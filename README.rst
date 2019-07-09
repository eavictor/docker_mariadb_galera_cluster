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


Before You Start
----------------

1. Make sure your network is not overlapped with ``10.32.0.0/12``. This IP range is used by weave network.


3. I wrote both commands running as foreground and background process started from Step 3. If you choose to run commands as background task (with ``-d``), use docker logs to retrieve logs in container

.. code-block:: bash

    docker logs <container_name>

- NOTE 1 : I recommend run as foreground on Step 5 First Run, then run as background on Step 5 Second Run.

- NOTE 2 : you can find container name in ``yml`` file, value of ``container_name`` is the container name we defined. Or you can execute below command to retrieve container names.

.. code-block:: bash

    docker container ls -a


4. Check IP address AFTER installation complete, don't forget make the IP static for these hosts if you use DHCP Server to distribute IPs.

.. code-block:: bash

    ip addr show

- NOTE : There are other commands to get system's IP address, use `Google Search`_ !!

.. _Google Search: https://lmgtfy.com/?iie=1&q=linux+get+ip+address


Installation
------------

0. Create ``db_data`` folder and clone repo

- This example assume username is eavictor, otherwise you have to modify ``yml`` files

.. code-block:: bash

    cd ~
    mkdir db_data
    git clone https://github.com/eavictor/docker_mariadb_galera_cluster.git


1. Install Docker-CE on EVERY Hosts

- Replace <username> with the actual user, or leave it blank. This is for join user into docker group, so we don't have to execute ``sudo`` and enter password every time.

.. code-block:: bash

    sudo bash 1_install_docker.sh <username>


2. Install weave on EVERY Hosts

- Must apply ``Host*_IP`` and separate by "space", you can apply as many host as you want.
  If you want to setup a cluster with 5 hosts, then apply all 5 IPs as parameter,
  execute same command on each node.

.. code-block:: bash

    sudo bash 2_install_weave.sh <Host1_IP> <Host2_IP> <Host3_IP> ...

- NOTE : Enter all hosts will show 1 connection failure in status, just ignore this message. Or we can choose NOT enter the machine's IP. For example when applying peers on Host 1.

.. code-block:: bash

    sudo bash 2_install_weave.sh <Host2_IP> <Host3_IP> ...


3. Edit volume bind ``source`` paths in `mariadb1.yml`_, `mariadb2.yml`_ and `mariadb3.yml`_ before start. DO NOT touch ``target`` path !!

.. _mariadb1.yml: mariadb1.yml

.. _mariadb2.yml: mariadb2.yml

.. _mariadb3.yml: mariadb3.yml


4. Edit MySQL configuration file on Host 1 to bootstrap Galera Cluster

- Edit ``wsrep_cluster_address``, value must be ``gcomm://``

- See `bootstrap_example.cnf`_ for how configured file looks like.

.. _bootstrap_example.cnf: bootstrap_example.cnf

- NOTE : Must modify mariadb1.cnf by yourself !!


5. Start Docker MariaDB on Host 1

.. code-block:: bash

    docker-compose -f mariadb1.yml up
    docker-compose -f mariadb1.yml up -d


6. Start Docker MariaDB on other Hosts

- Repeat this command on all nodes except the bootstrap node

- Important : On Host 2 and Host 3 after running the docker container the entrypoint script checks the mysqld service in the background after database initialization by using MySQL root user without password. Since Galera automatically performs synchronization through SST or IST when starting up, the MySQL root user password will change, mirroring the bootstrapped node. Thus, you would see the following error during the first start up:

- First Run (fail, wrong password) :

.. code-block:: bash

    docker-compose -f mariadb*.yml up
    docker-compose -f mariadb*.yml up -d

- Second Run (start syncing) :

.. code-block:: bash

    docker-compose -f mariadb*.yml up
    docker-compose -f mariadb*.yml up -d

7. Stop bootstrap container

- In our case, stop container on Host 1

.. code-block:: bash

    Press Ctrl + C
    docker-compose -f mariadb1.yml stop


8. Modify configuration files, add galera communication hosts back

- See `mariadb1.cnf`_ ``gcomm://`` section, add those IPs/Hosts back and save.

.. _mariadb1.cnf: mariadb1.cnf


9. Start container on Host 1 again

- The following command won't recreate container

.. code-block:: bash

    docker-compose -f mariadb1.yml up
    docker-compose -f mariadb1.yml up -d


Tips for bootstrap more than 3 Database Instances
-------------------------------------------------

Here are some tips to create MariaDB Galera Cluster for more than 3 hosts

1. 2_install_weave.sh
    Enter IP of all Hosts (optional: except the host you currently on)

    If not, execute this command to reset and stop weave, then rerun the install script with IP of all Hosts entered.

    .. code-block:: bash

        sudo weave stop
        sudo weave reset
        sudo rm /etc/sysconfig/weave

2. Create ``cnf`` files
    Make sure the following key's value are the same on every file

    .. code-block:: bash

        wsrep_cluster_name
        wsrep_cluster_address

    Make sure ``wsrep_cluster_address`` contains value of ``wsrep_node_address``

    Make sure value of ``wsrep_node_name`` is unique


3. Create ``yml`` files, some values depends on ``cnf`` file
    Make sure value of ``hostname`` and ``wsrep_node_address`` are the same

    Make sure value of ``container_name`` and ``wsrep_node_name`` are the same

    Make sure ``MYSQL_ROOT_PASSWORD``, ``MYSQL_DATABASE``, ``MYSQL_USER``, ``MYSQL_PASSWORD`` are the same on every file

    Change volumes ``source`` path, do not touch ``target`` path
