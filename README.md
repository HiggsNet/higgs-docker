## Higgs Network in Docker

这是Higgs网络的`docker`版本，推荐使用`systemd`作为higgs的管理程序。
对于不方便部署`systemd`的系统可以使用此项目。

### 配置说明

* 从higgs子目录里复制`rait.conf`和`env`到根目录。
* 利用`wg genkey`命令生成wireguard的密钥，并更新`rait.conf`和`env`中的参数。
* `docker-compose build`
* `docker-compose up -d`

**注意：docker在这里仅作管理程序，因而容器所需权限很高，需要`priviedged`以及`net_admin`。还是推荐`systemd`作为higgs网络的管理程序**
