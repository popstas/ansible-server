$VM_BOX = ENV.has_key?('VM_BOX') ? ENV['VM_BOX'] : 'ubuntu/trusty64'

Vagrant.configure('2') do |config|
  config.vm.box = $VM_BOX
  config.vm.network "public_network", ip: "192.168.1.100", bridge: "eth0"

  config.vm.provider "virtualbox" do |config|
    config.memory = 1024
    config.gui = false
    config.name = "ansible-server-test"
  end

  # Provisioning configuration for Ansible (for Mac/Linux hosts).
  config.vm.provision "ansible" do |ansible|
    ansible.extra_vars = { ansible_ssh_user: 'vagrant', vagrant: true }
    ansible.sudo = true
    #ansible.ask_sudo_pass = true
    ansible.playbook = 'server.yml'
    ansible.verbose = 'vv'
    #ansible.tags = 'ssh'
  end
end
