[
  "yum-utils",
  "device-mapper-persistent-data",
  "lvm2"
].each do |pkg|
  package pkg
end

bash "prepare_docker_prerequisites" do
  code <<-EOC
    yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    yum makecache fast
  EOC
  not_if { File.exist? "/usr/bin/dockerd" }
end

package "docker-ce" do
  # docker-ce-17.03.1.ce-1.el7.centos
  options("--setopt=obsoletes=0")
  version "#{node["docker"]["version"]}"
  notifies :run, 'execute[daemon-start]', :immediately
end

template "/usr/lib/systemd/system/docker.service" do
  source "docker.service.erb"
  mode "0644"
  notifies :run, 'execute[daemon-reload]', :delayed
end

execute 'daemon-reload' do
  command "systemctl daemon-reload"
  action :nothing
end

service "docker" do
  action :enable
end

execute 'daemon-start' do
  command "systemctl restart docker"
  # command "sudo gpasswd -a vagrant docker && service docker restart"
  action :nothing
end





