# Nginx Config
template "#{node['nginx']['dir']}/sites-available/typo3" do
  source 'typo3.erb'
  owner 'root'
  group node['root_group']
  mode '0644'
  action :create
  notifies :reload, 'service[nginx]'
end

# Enable Typo3
nginx_site 'typo3' do
  enable true
end

# Disable default page
nginx_site 'default' do
  enable false
end

# Enable PHP Error Logging
php_fpm_pool "www" do
  php_options 'php_flag[display_errors]' => 'on', 'php_admin_flag[display_errors]' => 'on', 'php_admin_value[memory_limit]' => '1024M', 'php_admin_value[upload_max_filesize]' => '1024M', 'php_admin_value[post_max_size]' => '1024M', 'php_admin_value[max_execution_time]' => '240', 'php_admin_value[date.timezone]' => 'Europe/Berlin'
end

# Install php-mysql
apt_package "php5-mysql" do
  action :install
end

# Install php5-gd
apt_package "php5-gd" do
  action :install
end

# Install graphicsmagick
apt_package "graphicsmagick" do
  action :install
end

# Install git
apt_package "git" do
  action :install
end

# Install custom php.ini
template "/etc/php5/fpm/php.ini" do
  action :delete
end

template "/etc/php5/fpm/php.ini" do
  source 'php.ini.erb'
  owner 'root'
  group node['root_group']
  mode '0644'
  action :create
  notifies :reload, 'service[nginx]'
  notifies :reload, 'service[php5-fpm]'
end

# Run Composer install for neos
composer_project "#{node['ifserver-neos']['composer_root']}"  do
    quiet false
    dev false
    action :install
end
