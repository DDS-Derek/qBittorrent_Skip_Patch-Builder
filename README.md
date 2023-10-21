# qBittorrent 快校版 Docker

![Docker Pulls](https://img.shields.io/docker/pulls/ddsderek/qbittorrent_skip_patch.svg?style=for-the-badge&label=pulls&logo=docker)

此仓库为[DDS-Derek/qBittorrent_Skip_Patch-Docker](https://github.com/DDS-Derek/qBittorrent_Skip_Patch-Docker)的延续维护版本，因为[Ghost-chu](https://github.com/Ghost-chu/qbittorrent-nox-static)大佬已经不再编译快校版`qbittorrent-nox`文件，故重构原项目，对于快校版`qbittorrent-nox`文件进行编译并打包镜像。
 
此项目功能与使用方法和`nevinee/qbittorrent`一致，故详细功能和使用教程[点击这里](https://devome.github.io/blog/p/一款更懂你的-qbittorrent-docker-镜像/)查看。

## 特性

1. 更加快速(但相对而言不安全)的hash校验

2. 快速校验失败后自动暂停，下次开始种子时进行完整校验

## 架构

| Architecture | Tag            |
| :----------: | :------------: |
| x86-64       | latest   |
| arm64        | latest |
| arm32        | latest |

## 标签

1. **`4.x.x` , `latest`**: 标签以纯数字版本号命名，这是qBittorrent正式发布的稳定版，其中最新的版本额外增加`latest`标签。
  
2. **`4.x.x-iyuu` , `latest-iyuu` , `iyuu`**: 标签中带有`iyuu`字样，基于qBittorrent稳定版集成了[IYUUPlus](https://github.com/ledccn/IYUUPlus)，其中最新的版本额外增加`latest-iyuu`和`iyuu`标签，自动安装好[IYUUPlus](https://github.com/ledccn/IYUUPlus)，自动设置好下载器，主要针对不会设置下载器的用户。

## 部署

**latest**
```shell
version: "3.0"
services:
  qbittorrent:
    image: ddsderek/qbittorrent_skip_patch:latest
    container_name: qbittorrent
    restart: always
    tty: true
    network_mode: bridge
    hostname: qbitorrent
    volumes:
      - ./data:/data      # 配置保存目录
    tmpfs:
      - /tmp
    environment:          # 下面未列出的其他环境变量请根据环境变量清单自行添加
      - WEBUI_PORT=8080   # WEBUI控制端口，可自定义
      - BT_PORT=34567     # BT监听端口，可自定义
      - PUID=1000         # 输入id -u可查询，群晖必须改
      - PGID=100          # 输入id -g可查询，群晖必须改
      - QB_USERNAME=admin
      - QB_PASSWORD=adminadmin
    ports:
      - 8080:8080        # 冒号左右一致，必须同WEBUI_PORT一样，本文件中的3个8080要改一起改
      - 34567:34567      # 冒号左右一致，必须同BT_PORT一样，本文件中的5个34567要改一起改
      - 34567:34567/udp  # 冒号左右一致，必须同BT_PORT一样，本文件中的5个34567要改一起改
    #security_opt:       # armv7设备请解除本行和下一行的注释
      #- seccomp=unconfined
```

**latest-iyuu**
```yaml
version: "3.0"
services:
  qbittorrent:
    image: ddsderek/qbittorrent_skip_patch:latest-iyuu
    container_name: qbittorrent
    restart: always
    tty: true
    network_mode: bridge
    hostname: qbitorrent
    volumes:
      - ./data:/data      # 配置保存目录
    tmpfs:
      - /tmp
    environment:          # 下面未列出的其他环境变量请根据环境变量清单自行添加
      - WEBUI_PORT=8080   # WEBUI控制端口，可自定义
      - BT_PORT=34567     # BT监听端口，可自定义
      - PUID=1000         # 输入id -u可查询，群晖必须改
      - PGID=100          # 输入id -g可查询，群晖必须改
      - QB_USERNAME=admin
      - QB_PASSWORD=adminadmin
    ports:
      - 8080:8080        # 冒号左右一致，必须同WEBUI_PORT一样，本文件中的3个8080要改一起改
      - 34567:34567      # 冒号左右一致，必须同BT_PORT一样，本文件中的5个34567要改一起改
      - 34567:34567/udp  # 冒号左右一致，必须同BT_PORT一样，本文件中的5个34567要改一起改
      - 8787:8787        # iyuu Web
    #security_opt:       # armv7设备请解除本行和下一行的注释
      #- seccomp=unconfined
```

## 依赖版本

通过执行下面这条命令可以查看当前镜像的依赖版本。

```shell
docker exec -it [你的qBittorrent容器名] cat /out/usr/bin/dependency-version.json
```

## 感谢

https://github.com/ChisBread/qbittorrent_skip_patch

https://github.com/DDS-Derek/dockerfiles/tree/master/qbittorrent

https://hub.docker.com/r/crazymax/qbittorrent

https://github.com/Ghost-chu/qbittorrent-nox-static
