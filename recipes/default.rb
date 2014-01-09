#
# Cookbook Name:: phpmyadmin
# Recipe:: default
#
# Copyright 2014, Koichi Tsutsumi <koichi.tsutsumi@gmail.com>
#
# All rights reserved - Do Not Redistribute
#

download_filename = "phpMyAdmin-#{node['phpmyadmin']['version']}-all-languages.tar.gz"
download_url = "http://sourceforge.net/projects/phpmyadmin/files/phpMyAdmin/#{node['phpmyadmin']['version']}/#{download_filename}/download"

dest_dir = File.join('/opt', cookbook_name.to_s)
docroot_dir = File.join(dest_dir, download_filename.gsub('.tar.gz', ''))
download_file = File.join('/tmp', download_filename)

directory dest_dir do
  action :create
end

execute 'remove old version' do
  command "rm -rf #{File.join(dest_dir, 'phpMyAdmin-*')}"
  creates docroot_dir
end

tar_extract download_url do
  target_dir dest_dir
  creates docroot_dir
end

template File.join(node['apache']['dir'], 'conf.d', 'phpmyadmin.conf') do
  variables docroot_dir: docroot_dir

  %w{apache2 php-fpm}.each do |svc|
    if node.recipe? svc
      notifies :reload, "service[#{svc}]"
    end
  end
end

log docroot_dir
log download_file

