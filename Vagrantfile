# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "genebean/centos-7-puppet"

  if Vagrant.has_plugin?("vagrant-cachier")
    # Configure cached packages to be shared between instances of the same base box.
    # More info on http://fgrehm.viewdocs.io/vagrant-cachier/usage
    config.cache.scope = :box
  end

  config.vm.network "forwarded_port", guest: 80,    host: 8080
  config.vm.network "forwarded_port", guest: 443,   host: 8443

  config.vm.network "public_network"

  config.vm.provision "shell", inline: <<-SHELL1
    yum -y install cmake gcc gcc-c++ git python-devel ruby-devel tree vim
    gem install --no-ri --no-rdoc bundler
    puppet module install puppetlabs-apache
    puppet module install Slashbunny-phpfpm
    puppet module install genebean-nginx_proxy

    echo --- > /etc/puppet/hiera.yaml
    puppet apply /vagrant/site.pp
    puppet apply /vagrant/site.pp
  SHELL1

  config.vm.provision "shell", inline: <<-SHELL2
    ln -sf /opt/rh/httpd24/root/etc/httpd /root/etc-httpd
    ln -sf /opt/rh/httpd24/root/etc/httpd /home/vagrant/etc-httpd
    ln -sf /opt/rh/httpd24/root/var/www /root/var-www
    ln -sf /opt/rh/httpd24/root/var/www /home/vagrant/var-www
    systemctl restart mariadb55-mariadb
  SHELL2

  config.vm.synced_folder "old-site", "/opt/rh/httpd24/root/var/www/old-site"
  config.vm.synced_folder "new-site", "/opt/rh/httpd24/root/var/www/new-site"

  # Uncomment to for manifest development via Vim
  #config.vm.provision "shell", path: 'vim-setup.sh'

end
