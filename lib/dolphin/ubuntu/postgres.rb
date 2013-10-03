# postgres related tasks
class Dolphin::Postgres < Dolphin::Base

  desc "install", "install postgres"
  def install
    menu = [
      %{
        sudo echo 'deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main' | sudo tee /etc/apt/sources.list.d/pgdg.list
        wget --quiet -O - http://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc | sudo apt-key add -
        sudo apt-get update
        sudo apt-get -y install postgresql postgresql-contrib libpq-dev
      },

    ]

    execute menu
  end

  desc "disable", "disable postgresql"
  def disable
    menu = [
      "
        sudo service postgresql stop
        sudo update-rc.d postgresql disable
      ",
    ]

    execute menu
  end

  desc "enable", "enable postgresql"
  def enable
    menu = [
      "
        sudo update-rc.d postgresql enable
        sudo service postgresql start
      ",
    ]

    execute menu
  end

  desc "config", "config postgres"
  def config
    # upload files
    upload("#{@config_root}/postgres/shared/*", "/tmp")

    master = @server_hash[:pgm]
    slave = @server_hash[:pgs]
    menu = [
      # set kernel sysctl
      %{
        cp /etc/sysctl.conf /tmp/
        echo kernel.shmmax = 2147483648 >> /tmp/sysctl.conf
        echo kernel.shmall = 2097152 >> /tmp/sysctl.conf
        echo kernel.shmmni = 4096 >> /tmp/sysctl.conf
        sudo mv /tmp/sysctl.conf /etc/
        sudo sysctl -p
      },

      # conf
      %{
        sudo mv /tmp/postgresql.conf /etc/postgresql/9.2/main/
        sudo chown postgres:postgres /etc/postgresql/9.2/main/postgresql.conf
      },

      # auth for replication
      %{
        echo hostssl replication replicator #{master}/32 trust >> /tmp/pg_hba.conf
        echo hostssl replication replicator #{slave}/32 trust >> /tmp/pg_hba.conf
        sudo mv /tmp/pg_hba.conf /etc/postgresql/9.2/main/
        sudo chown postgres:postgres /etc/postgresql/9.2/main/pg_hba.conf
      },

      # firewall
      %{
        sudo ufw allow from 192.168.0.0/16 to any port 5432
        # only for replicator
        sudo ufw allow from #{master}/32 to any port 5432
        sudo ufw allow from #{slave}/32 to any port 5432
      },
    ]

    execute menu
  end

  desc "master", "config pgmaster"
  def master(user, password)
    menu = [
      %{
        # plugin for pgadmin
        sudo -u postgres psql -c 'CREATE EXTENSION adminpack;'

        # create replicator user
        sudo -u postgres psql -c "CREATE USER replicator REPLICATION LOGIN ENCRYPTED PASSWORD '#{password}';"

        # create application user
        sudo -u postgres psql -c "CREATE USER #{user} LOGIN ENCRYPTED PASSWORD '#{password}' NOSUPERUSER INHERIT CREATEDB CREATEROLE;"

        sudo service postgresql restart
      },
    ]

    execute menu
  end

  desc "slave", "config pgslave"
  def slave
    # upload files
    upload("#{@config_root}/postgres/slave/*", "/tmp")

    master = @server_hash[:pgm]
    menu = [
      %{
        sudo service postgresql stop
        sudo -u postgres rm -rf /var/lib/postgresql/9.2/main
        sudo -u postgres pg_basebackup -h #{master} -D /var/lib/postgresql/9.2/main -U replicator -v -P

        sed -i 's/MASTER/#{master}/' /tmp/recovery.conf
        sudo mv /tmp/recovery.conf /var/lib/postgresql/9.2/main/
        sudo chown postgres:postgres /var/lib/postgresql/9.2/main/recovery.conf

        sudo service postgresql start

      },
    ]

    execute menu
  end

  desc "createdb", "postgres createdb"
  def createdb(dbname)
    menu = [
      %{
        psql -d postgres -c 'CREATE DATABASE #{dbname}'
      },
    ]

    execute menu
  end

  desc "backup", "backup postgres"
  def backup
    # upload files
    upload("#{@config_root}/postgres/slave/*", "/tmp")

    menu = [
      %{
        mkdir -p ~/backups/postgresql
        mv /tmp/pg_backup.* ~/backups/postgresql
        # # add cron job to /var/spool/cron/crontabs/user
        crontab /tmp/cron.txt
      },

    ]

    execute menu
  end

end
