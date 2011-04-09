require 'rubygems'
require 'digest/md5'
require_gem "rails"
gem 'activerecord'
require 'action_view'

$: << "app/models"


#
# Many of these DB sessions will change when it is moved to 
# another machine
#

def connect_db
$DB = ActiveRecord::Base.establish_connection(
        :adapter  => "mysql",
        :database => "php_info",
        :username => "root",
        :password => "",
        :socket   => "/var/run/mysqld/mysqld.sock",
        :host     => "localhost"
)
end
connect_db

