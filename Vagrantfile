$VM_BOX = 'ubuntu/trusty64'
$VM_NAME = ENV.has_key?('VM_NAME') ? ENV['VM_NAME'] : "ansible-server"
$VM_IP = ENV.has_key?('VM_IP') ? ENV['VM_IP'] : "192.168.1.100"

# share apt cache - https://gist.github.com/juanje/3797297
require 'fileutils'
def local_cache(basebox_name)
  cache_dir = Vagrant::Environment.new.home_path.join('cache', 'apt', basebox_name)
  partial_dir = cache_dir.join('partial')
  FileUtils::mkdir_p partial_dir unless partial_dir.exist?
  cache_dir
end

Vagrant.configure('2') do |config|
  config.vm.box = $VM_BOX
  config.vm.box_check_update = false
  config.ssh.insert_key = false
  #config.ssh.private_key_path = "/home/popstas/.ssh/id_dsa"

  if $VM_IP
    config.vm.define "public" do |public|
      config.vm.network "public_network", ip: $VM_IP, bridge: "eth0"
    end
  end

  config.vm.network "private_network", type: "dhcp"

  # mount /var/cache/apt/archives to host /root/.vagrant.d/cache/apt/ubuntu/trusty64
  cache_dir = local_cache(config.vm.box)
  config.vm.synced_folder cache_dir, "/var/cache/apt/archives/", create: true

  config.vm.synced_folder ".", "/vagrant", type: "nfs"

  config.vm.provider "virtualbox" do |config|
    config.cpus = 2
    config.memory = 4096
    config.gui = false
    config.name = $VM_NAME
  end

  # Provisioning configuration for Ansible (for Mac/Linux hosts).
  #config.vm.provision "ansible" do |ansible|
  #  ansible.extra_vars = { ansible_ssh_user: 'vagrant', vagrant: true }
  #  ansible.sudo = true
  #  #ansible.ask_sudo_pass = true
  #  ansible.playbook = 'server.yml'
  #  ansible.verbose = 'vv'
  #  #ansible.tags = 'ssh'
  #end
end
