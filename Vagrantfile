require_relative 'vagrant/patches.rb'

Vagrant.configure("2") do |config|

  config.vm.box = "dummy"
  config.env.enable
  local_env = { 'WORKDIR' => ENV['AWS_WORKDIR'] }
  local_env['USER_NAME'] = ENV['AWS_SSH_USER']

  config.vm.provider "aws" do |aws, override|
    aws.access_key_id = ENV['AWS_ACCESS_KEY_ID']
    aws.secret_access_key = ENV['AWS_SECRET_ACCESS_KEY']
    aws.instance_type = ENV['AWS_INSTANCE_TYPE']
    aws.keypair_name = ENV['AWS_KEYPAIR_NAME']
    aws.region = ENV['AWS_REGION']
    aws.ami = ENV['AWS_AMI']
    aws.block_device_mapping = [{ 'DeviceName' => '/dev/sda1', 'Ebs.VolumeSize' => ENV['AWS_VOLUME_SIZE'] }]
    aws.security_groups = [ENV['AWS_SECURITY_GROUPS']]

    override.ssh.username = ENV['AWS_SSH_USER']
    override.ssh.private_key_path = ENV['AWS_SSH_PRIVATE_KEY_PATH']
  end

  config.vm.synced_folder ".", "/vagrant", disabled: true
  config.vm.synced_folder ".", ENV['AWS_WORKDIR'], type: "rsync", rsync__exclude: ".git/", rsync__auto: true

  config.vm.provision "shell", path: "./vagrant/provision/ubuntu-base.bash", env: local_env

  # this vm is not reusable, everything runs directly inside the vm
  config.vm.define "vm", autostart: true do |vm|
    vm.vm.provision "shell", path: "./vagrant/provision/ubuntu-dev.bash", env: local_env
  end
end
