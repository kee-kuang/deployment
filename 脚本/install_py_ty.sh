---
- name: Deploy FFmpeg (Root) and Conda Project (Ubuntu User)
  hosts: sucai-hw-py
  vars:
    ffmpeg_version: "7.1"
    ffmpeg_prefix: "/usr/local/ffmpeg"
    src_dir: "/usr/local/src"
    target_user: "ubuntu"
    conda_path: "/home/ubuntu/miniconda3"
    project_path: "/www/sucai-hw-cms-python"
    conda_installer: "Miniconda3-latest-Linux-x86_64.sh"

  tasks:
    # ===========================================================
    # 1. Root 权限任务：系统依赖与 FFmpeg 编译
    # ===========================================================
    - name: Install System packages and Build FFmpeg
      become: yes
      block:
        - name: Install APT dependencies
          apt:
            pkg: [build-essential, pkg-config, yasm, nasm, autoconf, automake, libtool, cmake, libfreetype6-dev, libfontconfig1-dev, libharfbuzz-dev, libfribidi-dev, libx264-dev, libx265-dev, libssl-dev, libnuma-dev, ca-certificates, curl, wget, supervisor, git]
            state: present
            update_cache: yes

        - name: Download & Compile FFmpeg
          shell: |
            wget -nc https://ops-kee-1392049403.cos.ap-guangzhou.myqcloud.com/ffmpeg-{{ ffmpeg_version }}.tar.gz
            tar -zxf ffmpeg-{{ ffmpeg_version }}.tar.gz
            cd ffmpeg-{{ ffmpeg_version }}
            ./configure --prefix={{ ffmpeg_prefix }} --enable-gpl --enable-nonfree --enable-openssl --enable-libfreetype --enable-libfontconfig --enable-libharfbuzz --enable-libfribidi --enable-libx264 --enable-libx265 --disable-static --enable-shared
            make -j$(nproc) && make install
          args:
            chdir: "{{ src_dir }}"
            creates: "{{ ffmpeg_prefix }}/bin/ffmpeg"

        - name: Setup System Links and LDConfig
          shell: |
            echo "{{ ffmpeg_prefix }}/lib" > /etc/ld.so.conf.d/ffmpeg.conf && ldconfig
            ln -sf {{ ffmpeg_prefix }}/bin/ffmpeg /usr/local/bin/ffmpeg
            ln -sf {{ ffmpeg_prefix }}/bin/ffprobe /usr/local/bin/ffprobe
          args:
            creates: "/usr/local/bin/ffmpeg"

        - name: Create project root with Ubuntu ownership
          file:
            path: /www
            state: directory
            owner: "{{ target_user }}"
            group: "{{ target_user }}"
            mode: '0755'

    # ===========================================================
    # 2. Ubuntu 用户权限任务：Conda 与项目部署
    # ===========================================================
    - name: Conda and Project Environment
      become: yes
      become_user: "{{ target_user }}"
      block:
        - name: Download & Install Miniconda
          shell: |
            wget -nc https://ops-kee-1392049403.cos.ap-guangzhou.myqcloud.com/kee-pubilc/{{ conda_installer }} -P /tmp/
            bash /tmp/{{ conda_installer }} -b -p {{ conda_path }} -u
          args:
            creates: "{{ conda_path }}/bin/conda"

        - name: Configure Git Credentials & Safe Directory
          shell: |
            git config --global credential.helper store
            git config --global --add safe.directory {{ project_path }}
            echo "http://kuangzhuoqi:Kzq010524%40@gitlab.yuetougz.com:5006" > ~/.git-credentials
            chmod 600 ~/.git-credentials
          args:
            creates: "~/.git-credentials"

        - name: Clone Repository
          git:
            repo: 'http://gitlab.yuetougz.com:5006/python/sucai-hw-cms-python.git'
            dest: "{{ project_path }}"
            update: no

        - name: Setup Conda Environment and Pip requirements
          shell: |
            {{ conda_path }}/bin/conda create -n sucai-hw-cms-python python=3.10 -y
            {{ conda_path }}/envs/sucai-hw-cms-python/bin/pip install -r requirements.txt
          args:
            chdir: "{{ project_path }}"
            creates: "{{ conda_path }}/envs/sucai-hw-cms-python"

        - name: Download Config Files
          get_url:
            url: "{{ item.url }}"
            dest: "{{ item.dest }}"
          loop:
            - { url: 'https://jishubu-1392049403.cos.ap-guangzhou.myqcloud.com/zl/.env', dest: '{{ project_path }}/.env' }
            - { url: 'https://jishubu-1392049403.cos.ap-guangzhou.myqcloud.com/zl/database.yaml', dest: '{{ project_path }}/app/config/database.yaml' }

    # ===========================================================
    # 3. Root 权限任务：Supervisor 服务管理
    # ===========================================================
    - name: Finalize Supervisor config
      become: yes
      block:
        - get_url:
            url: "https://jishubu-1392049403.cos.ap-guangzhou.myqcloud.com/zl/sucai-hw-cms-python.ini"
            dest: "/etc/supervisor/conf.d/sucai-hw-cms-python.ini"

        - name: Update Supervisor global config
          lineinfile:
            path: /etc/supervisor/supervisord.conf
            line: 'files = /etc/supervisor/conf.d/*.ini'
            insertafter: '^\[include\]'

        - name: Restart Supervisor Service
          shell: |
            systemctl enable supervisor
            systemctl restart supervisor
            sleep 2
            supervisorctl update
            supervisorctl status sucai-hw-cms-python