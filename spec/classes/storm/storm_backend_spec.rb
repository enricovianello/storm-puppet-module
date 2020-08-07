require 'spec_helper'

describe 'storm::backend', :type => :class do

  on_supported_os.each do |os, facts|

    context "on #{os}" do

      let(:params) do 
        {
          'hostname' => 'storm.example.org',
        }
      end

      let(:facts) do
        facts
      end

      context 'with custom backend params' do

        let(:params) do
          super().merge({
            'install_native_libs_gpfs' => true,
            'frontend_public_host' => 'frontend.example.org',
            'db_username' => 'test',
            'db_password' => 'secret',
            'gsiftp_pool_members' => [
              {
                'hostname' => 'gridftp-0.example.org',
              }, {
                'hostname' => 'gridftp-1.example.org',
              }
            ],
            'webdav_pool_members' => [
              {
                'hostname' => 'webdav-0.example.org',
              }, {
                'hostname' => 'webdav-1.example.org',
              }
            ],
            'srm_pool_members' => [
              {
                'hostname' => 'frontend-0.example.org',
                'port' => 8445,
              }, {
                'hostname' => 'frontend-1.example.org',
              }
            ],
            'transfer_protocols' => ['file','gsiftp','webdav'],
            'storage_areas'       => [
              {
                'name' => 'test.vo',
                'root_path' => '/storage/test.vo',
                'access_points' => ['/test.vo'],
                'vos' => ['test.vo', 'test.vo.2'],
                'storage_class' => 'T0D1',
                'online_size' => 4,
                'transfer_protocols' => ['file','gsiftp','webdav','xroot'],
              },
              {
                'name' => 'atlas',
                'root_path' => '/storage/atlas',
                'access_points' => ['/atlas', '/atlasdisk'],
                'vos' => ['atlas'],
                'fs_type' => 'gpfs',
                'storage_class' => 'T1D0',
                'online_size' => 4,
                'nearline_size' => 10,
                'gsiftp_pool_balance_strategy' => 'weight',
                'gsiftp_pool_members' => [
                  {
                    'hostname' => 'gridftp-0.example.org',
                    'weight' => 50,
                  }, {
                    'hostname' => 'gridftp-1.example.org',
                  }
                ],
              },
            ],
            'info_sitename' => 'test',
            'info_storage_default_root' => '/another-storage',
            'info_endpoint_quality_level' => 1,
            'jvm_options' => '-Xms512m -Xmx1024m',
          })
        end

        it "check backend namespace file content" do
          title='/etc/storm/backend-server/namespace.xml'
          is_expected.to contain_file(title).with( 
            :ensure  => 'present',
            :content => my_fixture_read("namespace-0.xml"),
          )
        end

        it "check backend storm.properties file content" do
          title='/etc/storm/backend-server/storm.properties'
          is_expected.to contain_file(title).with( 
            :ensure  => 'present',
          )
          is_expected.to contain_file(title).with( :content => /storm.service.FE-public.hostname=frontend.example.org/ )
          is_expected.to contain_file(title).with( :content => /storm.service.port=8444/ )
          is_expected.to contain_file(title).with( :content => /storm.service.SURL.endpoint=srm:\/\/frontend-0.example.org:8445\/srm\/managerv2,srm:\/\/frontend-1.example.org:8444\/srm\/managerv2/ )
          is_expected.to contain_file(title).with( :content => /storm.service.SURL.default-ports=8445,8444/ )
          is_expected.to contain_file(title).with( :content => /storm.service.request-db.host=storm.example.org/ )
          is_expected.to contain_file(title).with( :content => /storm.service.request-db.username=test/ )
          is_expected.to contain_file(title).with( :content => /storm.service.request-db.passwd=secret/ )
          is_expected.to contain_file(title).with( :content => /directory.automatic-creation=false/ )
          is_expected.to contain_file(title).with( :content => /directory.writeperm=false/ )
          is_expected.to contain_file(title).with( :content => /ptg.skip-acl-setup=false/ )
          is_expected.to contain_file(title).with( :content => /pinLifetime.default=259200/ )
          is_expected.to contain_file(title).with( :content => /pinLifetime.maximum=1814400/ )
          is_expected.to contain_file(title).with( :content => /sanity-check.enabled=true/ )
          is_expected.to contain_file(title).with( :content => /storm.service.du.enabled=false/ )
          is_expected.to contain_file(title).with( :content => /storm.service.du.delay=60/ )
          is_expected.to contain_file(title).with( :content => /storm.service.du.interval=360/ )
          is_expected.to contain_file(title).with( :content => /synchcall.directoryManager.maxLsEntry=2000/ )
          is_expected.to contain_file(title).with( :content => /gc.pinnedfiles.cleaning.delay=10/ )
          is_expected.to contain_file(title).with( :content => /gc.pinnedfiles.cleaning.interval=300/ )
          is_expected.to contain_file(title).with( :content => /purging=true/ )
          is_expected.to contain_file(title).with( :content => /purge.interval=600/ )
          is_expected.to contain_file(title).with( :content => /purge.size=800/ )
          is_expected.to contain_file(title).with( :content => /expired.request.time=21600/ )
          is_expected.to contain_file(title).with( :content => /transit.interval=300/ )
          is_expected.to contain_file(title).with( :content => /transit.delay=10/ )
          is_expected.to contain_file(title).with( :content => /extraslashes.file=/ )
          is_expected.to contain_file(title).with( :content => /extraslashes.root=\// )
          is_expected.to contain_file(title).with( :content => /extraslashes.gsiftp=\// )
          is_expected.to contain_file(title).with( :content => /persistence.internal-db.connection-pool=true/ )
          is_expected.to contain_file(title).with( :content => /persistence.internal-db.connection-pool.maxActive=200/ )
          is_expected.to contain_file(title).with( :content => /persistence.internal-db.connection-pool.maxWait=50/ )
          is_expected.to contain_file(title).with( :content => /asynch.db.ReconnectPeriod=18000/ )
          is_expected.to contain_file(title).with( :content => /asynch.db.DelayPeriod=30/ )
          is_expected.to contain_file(title).with( :content => /asynch.PickingInitialDelay=1/ )
          is_expected.to contain_file(title).with( :content => /asynch.PickingTimeInterval=2/ )
          is_expected.to contain_file(title).with( :content => /asynch.PickingMaxBatchSize=100/ )
          is_expected.to contain_file(title).with( :content => /synchcall.directoryManager.maxLsEntry=2000/ )
          is_expected.to contain_file(title).with( :content => /storm.rest.services.port=9998/ )
          is_expected.to contain_file(title).with( :content => /storm.rest.services.maxthreads=100/ )
          is_expected.to contain_file(title).with( :content => /storm.rest.services.max_queue_size=1000/ )
          is_expected.to contain_file(title).with( :content => /synchcall.xmlrpc.unsecureServerPort=8080/ )
          is_expected.to contain_file(title).with( :content => /synchcall.xmlrpc.maxthread=256/ )
          is_expected.to contain_file(title).with( :content => /synchcall.xmlrpc.max_queue_size=1000/ )
          is_expected.to contain_file(title).with( :content => /synchcall.xmlrpc.security.enabled=true/ )
          is_expected.to contain_file(title).with( :content => /synchcall.xmlrpc.security.token=secret/ )

          is_expected.to contain_file(title).with( :content => /gc.pinnedfiles.cleaning.delay=10/ )
          is_expected.to contain_file(title).with( :content => /gc.pinnedfiles.cleaning.interval=300/ )
          is_expected.to contain_file(title).with( :content => /purging=true/ )
          is_expected.to contain_file(title).with( :content => /purge.interval=600/ )
          is_expected.to contain_file(title).with( :content => /purge.size=800/ )
          is_expected.to contain_file(title).with( :content => /expired.request.time=21600/ )
          is_expected.to contain_file(title).with( :content => /expired.inprogress.time=2592000/ )
          is_expected.to contain_file(title).with( :content => /transit.interval=300/ )
          is_expected.to contain_file(title).with( :content => /transit.delay=10/ )
          is_expected.to contain_file(title).with( :content => /ptg.skip-acl-setup=false/ )
          is_expected.to contain_file(title).with( :content => /http.turl_prefix=/ )

          # is_expected.to contain_file(title).with( :content => // )
          # is_expected.to contain_file(title).with( :content => // )
        end

        it "check info provider configuration file content" do
          title='/etc/storm/info-provider/storm-yaim-variables.conf'
          is_expected.to contain_file(title).with( 
            :ensure => 'present',
          )
          is_expected.to contain_file(title).with( :content => /SITE_NAME=test/ )
          is_expected.to contain_file(title).with( :content => /STORM_FRONTEND_PUBLIC_HOST=frontend.example.org/ )
          is_expected.to contain_file(title).with( :content => /STORM_BACKEND_HOST=storm.example.org/ )
          is_expected.to contain_file(title).with( :content => /STORM_DEFAULT_ROOT=\/another-storage/ )
          is_expected.to contain_file(title).with( :content => /STORM_FRONTEND_PATH=\/srm\/managerv2/ )
          is_expected.to contain_file(title).with( :content => /STORM_FRONTEND_PORT=8444/ )
          is_expected.to contain_file(title).with( :content => /STORM_BACKEND_REST_SERVICES_PORT=9998/ )
          is_expected.to contain_file(title).with( :content => /STORM_ENDPOINT_QUALITY_LEVEL=1/ )

          is_expected.to contain_file(title).with( :content => /STORM_INFO_FILE_SUPPORT=true/ )
          is_expected.to contain_file(title).with( :content => /STORM_INFO_RFIO_SUPPORT=false/ )
          is_expected.to contain_file(title).with( :content => /STORM_INFO_GRIDFTP_SUPPORT=true/ )
          is_expected.to contain_file(title).with( :content => /STORM_INFO_ROOT_SUPPORT=true/ )
          is_expected.to contain_file(title).with( :content => /STORM_INFO_HTTP_SUPPORT=true/ )
          is_expected.to contain_file(title).with( :content => /STORM_INFO_HTTPS_SUPPORT=true/ )

          is_expected.to contain_file(title).with( :content => /STORM_FRONTEND_HOST_LIST=frontend-0.example.org,frontend-1.example.org/ )

          is_expected.to contain_file(title).with( :content => /STORM_WEBDAV_POOL_LIST=http:\/\/webdav-0.example.org:8085\/,https:\/\/webdav-0.example.org:8443\/,http:\/\/webdav-1.example.org:8085\/,https:\/\/webdav-1.example.org:8443\// )

          is_expected.to contain_file(title).with( :content => /STORM_TESTVO_VONAME='test.vo test.vo.2'/ )
          is_expected.to contain_file(title).with( :content => /STORM_TESTVO_ONLINE_SIZE=4/ )
          is_expected.not_to contain_file(title).with( :content => /STORM_TESTVO_NEARLINE_SIZE=0/ )
          is_expected.to contain_file(title).with( :content => /STORM_TESTVO_TOKEN=TESTVO-TOKEN/ )
          is_expected.to contain_file(title).with( :content => /STORM_TESTVO_ROOT=\/storage\/test.vo/ )
          is_expected.to contain_file(title).with( :content => /STORM_TESTVO_STORAGECLASS=T0D1/ )
          is_expected.to contain_file(title).with( :content => /STORM_TESTVO_ACCESSPOINT='\/test.vo'/ )

          is_expected.to contain_file(title).with( :content => /STORM_ATLAS_VONAME='atlas'/ )
          is_expected.to contain_file(title).with( :content => /STORM_ATLAS_ONLINE_SIZE=4/ )
          is_expected.to contain_file(title).with( :content => /STORM_ATLAS_NEARLINE_SIZE=10/ )
          is_expected.to contain_file(title).with( :content => /STORM_ATLAS_TOKEN=ATLAS-TOKEN/ )
          is_expected.to contain_file(title).with( :content => /STORM_ATLAS_ROOT=\/storage\/atlas/ )
          is_expected.to contain_file(title).with( :content => /STORM_ATLAS_STORAGECLASS=T1D0/ )
          is_expected.to contain_file(title).with( :content => /STORM_ATLAS_ACCESSPOINT='\/atlas \/atlasdisk'/ )

          is_expected.to contain_file(title).with( :content => /STORM_STORAGEAREA_LIST='test.vo atlas'/ )
          is_expected.to contain_file(title).with( :content => /VOS='test.vo test.vo.2 atlas'/ )
        end

        it "check if exec of storm-info-provider configure has been run" do
          is_expected.to contain_exec('configure-info-provider')
        end
  
        it "check if exec of storm-info-provider configure has been run" do
          is_expected.to contain_exec('configure-info-provider')
        end

        it "check service directory" do
          is_expected.to contain_file('/etc/systemd/system/storm-backend-server.service.d').with(
            :ensure => 'directory',
            :owner  => 'root',
            :group  => 'root',
            :mode   => '0644',
          )
        end

        it "check service file content" do
          title='/etc/systemd/system/storm-backend-server.service.d/storm-backend-server.conf'
          is_expected.to contain_file(title).with( 
            :ensure => 'present',
          )
          is_expected.to contain_file(title).with( :content => /^Environment="STORM_BE_JVM_OPTS=-Xms512m -Xmx1024m"/ )
          is_expected.to contain_file(title).with( :content => /^Environment="LCMAPS_DB_FILE=\/etc\/storm\/backend-server\/lcmaps.db"/ )
          is_expected.to contain_file(title).with( :content => /^Environment="LCMAPS_POLICY_NAME=standard"/ )
          is_expected.to contain_file(title).with( :content => /^Environment="LCMAPS_LOG_FILE=\/var\/log\/storm\/lcmaps.log"/ )
          is_expected.to contain_file(title).with( :content => /^Environment="LCMAPS_DEBUG_LEVEL=0"/ )
  
        end

        it "check log directory" do
          is_expected.to contain_file('/var/log/storm').with( 
            :ensure => 'directory',
            :owner  => 'storm',
            :group  => 'storm',
            :mode   => '0755',
          )
        end

        it "check backend reload" do
          is_expected.to contain_exec('backend-daemon-reload')
        end

      end

      context 'with custom db username and password' do

        let(:params) do
          super().merge({
            'db_username' => 'test',
            'db_password' => 'secret',
          })
        end
      
        case facts[:operatingsystemmajrelease]
        when '6'
          it 'check mysql repo for centos 6 is installed' do
            is_expected.to contain_yumrepo('repo.mysql.com').with(
              :ensure => 'present',
              :descr => 'repo.mysql.com',
              :baseurl => 'http://repo.mysql.com/yum/mysql-5.6-community/el/6/x86_64/',
              :enabled => 1,
              :gpgcheck => true,
              :gpgkey => 'http://repo.mysql.com/RPM-GPG-KEY-mysql',
            )
          end
        when '7'
          it 'check mysql repo for centos 7 is installed' do
            is_expected.to contain_yumrepo('repo.mysql.com').with(
              :ensure => 'present',
              :descr => 'repo.mysql.com',
              :baseurl => 'http://repo.mysql.com/yum/mysql-5.6-community/el/7/x86_64/',
              :enabled => 1,
              :gpgcheck => true,
              :gpgkey => 'http://repo.mysql.com/RPM-GPG-KEY-mysql',
            )
          end
        end
  
        it 'check mysql client is installed' do
          is_expected.to contain_class('mysql::client').with(
            :package_name => 'mysql-community-client',
          )
        end

        it 'check mysql server is not installed' do
          is_expected.not_to contain_class('mysql::server')
        end

        it "check db scripts exist" do
          storm_db='/tmp/storm_db.sql'
          is_expected.to contain_file(storm_db).with( 
            :ensure => 'present',
          )
          storm_be_isam='/tmp/storm_be_ISAM.sql'
          is_expected.to contain_file(storm_be_isam).with( 
            :ensure => 'present',
          )
        end

        it "check storm db creation" do
          is_expected.to contain_mysql__db('storm_db').with(
            :user => 'test',
            :password => 'secret',
            :host => 'storm.example.org',
            :grant => 'ALL',
            :sql => '/tmp/storm_db.sql',
          )
        end

        it "check grants on storm_db" do
          is_expected.to contain_mysql_grant('test@storm/storm_db.*').with(
            :privileges => 'ALL',
            :provider   => 'mysql',
            :user       => "test@storm",
            :table      => 'storm_db.*',
          )
          is_expected.to contain_mysql_grant('test@localhost/storm_db.*').with(
            :privileges => 'ALL',
            :provider   => 'mysql',
            :user       => "test@localhost",
            :table      => 'storm_db.*',
          )
          is_expected.to contain_mysql_grant('test@%/storm_db.*').with(
            :privileges => 'ALL',
            :provider   => 'mysql',
            :user       => "test@%",
            :table      => 'storm_db.*',
          )
        end

        it "check storm be ISAM db creation" do
          is_expected.to contain_mysql__db('storm_be_ISAM').with(
            :user => 'test',
            :password => 'secret',
            :host => 'storm.example.org',
            :grant => 'ALL',
            :sql => '/tmp/storm_be_ISAM.sql',
          )
        end

        it "check grants on storm_be_ISAM" do
          is_expected.to contain_mysql_grant('test@storm/storm_be_ISAM.*').with(
            :privileges => 'ALL',
            :provider   => 'mysql',
            :user       => "test@storm",
            :table      => 'storm_be_ISAM.*',
          )
          is_expected.to contain_mysql_grant('test@localhost/storm_be_ISAM.*').with(
            :privileges => 'ALL',
            :provider   => 'mysql',
            :user       => "test@localhost",
            :table      => 'storm_be_ISAM.*',
          )
          is_expected.to contain_mysql_grant('test@%/storm_be_ISAM.*').with(
            :privileges => 'ALL',
            :provider   => 'mysql',
            :user       => "test@%",
            :table      => 'storm_be_ISAM.*',
          )
        end

        it "check users" do
          is_expected.to contain_mysql_user('test@storm')
          is_expected.to contain_mysql_user('test@localhost')
          is_expected.to contain_mysql_user('test@%')
        end
      end

      context 'with MySQL server enabled and default db username and password' do

        let(:params) do
          super().merge({
            'mysql_server_install' => true,
            'mysql_server_root_password' => 'secret',
            'mysql_server_override_options' => {
              'mysqld'      => {
                'bind-address'    => '127.0.0.1',
                'log-error'       => '/var/log/mysqld.log',
                'max_connections' => 3000,
              },
              'mysqld_safe' => {
                'log-error' => '/var/log/mysqld.log',
              },
            },
          })
        end
      
        it "check MySQL server is installed" do
          is_expected.to contain_class('mysql::server').with(
            :package_name => 'mysql-community-server',
            :manage_config_file => true,
            :service_name => 'mysqld',
            :root_password => 'secret',
            :override_options => {
              'mysqld'      => {
                'bind-address'    => '127.0.0.1',
                'log-error'       => '/var/log/mysqld.log',
                'max_connections' => 3000,
              },
              'mysqld_safe' => {
                'log-error' => '/var/log/mysqld.log',
              },
            },
          )
        end

        it 'check mysql client is installed' do
          is_expected.to contain_class('mysql::client').with(
            :package_name => 'mysql-community-client',
          )
        end

        it "check db scripts exist" do
          storm_db='/tmp/storm_db.sql'
          is_expected.to contain_file(storm_db).with( 
            :ensure => 'present',
          )
          storm_be_isam='/tmp/storm_be_ISAM.sql'
          is_expected.to contain_file(storm_be_isam).with( 
            :ensure => 'present',
          )
        end

        it "check storm db creation" do
          is_expected.to contain_mysql__db('storm_db').with(
            :user => 'storm',
            :password => 'storm',
            :host => 'storm.example.org',
            :grant => 'ALL',
            :sql => '/tmp/storm_db.sql',
          )
        end

        it "check grants on storm_db" do
          is_expected.to contain_mysql_grant('storm@storm/storm_db.*').with(
            :privileges => 'ALL',
            :provider   => 'mysql',
            :user       => "storm@storm",
            :table      => 'storm_db.*',
          )
          is_expected.to contain_mysql_grant('storm@localhost/storm_db.*').with(
            :privileges => 'ALL',
            :provider   => 'mysql',
            :user       => "storm@localhost",
            :table      => 'storm_db.*',
          )
          is_expected.to contain_mysql_grant('storm@%/storm_db.*').with(
            :privileges => 'ALL',
            :provider   => 'mysql',
            :user       => "storm@%",
            :table      => 'storm_db.*',
          )
        end

        it "check storm be ISAM db creation" do
          is_expected.to contain_mysql__db('storm_be_ISAM').with(
            :user => 'storm',
            :password => 'storm',
            :host => 'storm.example.org',
            :grant => 'ALL',
            :sql => '/tmp/storm_be_ISAM.sql',
          )
        end

        it "check grants on storm_be_ISAM" do
          is_expected.to contain_mysql_grant('storm@storm/storm_be_ISAM.*').with(
            :privileges => 'ALL',
            :provider   => 'mysql',
            :user       => "storm@storm",
            :table      => 'storm_be_ISAM.*',
          )
          is_expected.to contain_mysql_grant('storm@localhost/storm_be_ISAM.*').with(
            :privileges => 'ALL',
            :provider   => 'mysql',
            :user       => "storm@localhost",
            :table      => 'storm_be_ISAM.*',
          )
          is_expected.to contain_mysql_grant('storm@%/storm_be_ISAM.*').with(
            :privileges => 'ALL',
            :provider   => 'mysql',
            :user       => "storm@%",
            :table      => 'storm_be_ISAM.*',
          )
        end

        it "check users" do
          is_expected.to contain_mysql_user('storm@storm')
          is_expected.to contain_mysql_user('storm@localhost')
          is_expected.to contain_mysql_user('storm@%')
        end
      end
        
    end
  end
end