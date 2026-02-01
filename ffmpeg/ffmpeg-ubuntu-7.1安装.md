FFmpeg 7.1（Ubuntu 24.04）完整可用方案整理
一、当前最终状态（确认）

你现在实际在用的是：

FFmpeg 7.1
安装路径：/usr/local/ffmpeg
编译方式：源码编译（动态）
drawtext：可用


验证命令（你已执行成功）：

/usr/local/ffmpeg/bin/ffmpeg -filters | grep drawtext


预期结果：

drawtext          V->V       Draw text on top of video frames using libfreetype library


➡️ 这一步成立，就说明当前环境已经完全可用，无需再动。

二、你这套 FFmpeg 为什么“现在就可以用了”

关键点只有三个：

FFmpeg 版本本身没问题

7.1 完全支持 drawtext

编译时启用了正确选项

--enable-libfreetype
--enable-libfontconfig


系统中真实存在 freetype / fontconfig 的开发库

libfreetype6-dev
libfontconfig1-dev


只要这三点同时成立，drawtext 一定会被编译进 libavfilter。

三、推荐的“固定使用方式”（避免将来混乱）
1️⃣ 明确只用这一份 ffmpeg

建议以后只认这一条路径：

/usr/local/ffmpeg/bin/ffmpeg


不要混用：

/usr/bin/ffmpeg

/usr/local/bin/ffmpeg

static 包里的 ffmpeg

如果你希望系统默认就是这一版：

ln -sf /usr/local/ffmpeg/bin/ffmpeg /usr/local/bin/ffmpeg
ln -sf /usr/local/ffmpeg/bin/ffprobe /usr/local/bin/ffprobe


验证：

which ffmpeg
ffmpeg -version

2️⃣ 字体使用的推荐写法（生产环境）

不要依赖系统自动找字体，统一指定字体文件：

/usr/local/ffmpeg/bin/ffmpeg -i input.mp4 \
-vf "drawtext=fontfile=/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf:text='Hello 世界':x=20:y=40:fontsize=36:fontcolor=white" \
-c:a copy output.mp4


这样可以避免：

中文乱码

容器 / 精简系统找不到字体

不同服务器渲染不一致

四、以后如果要“重装 / 升级”，标准流程（留档）

这一段你可以直接存到运维文档

1️⃣ 安装依赖
apt update
apt install -y \
  build-essential pkg-config yasm nasm \
  libfreetype6-dev libfontconfig1-dev \
  libharfbuzz-dev libfribidi-dev \
  libx264-dev libx265-dev libssl-dev

2️⃣ configure（关键）
./configure \
  --prefix=/usr/local/ffmpeg \
  --enable-gpl \
  --enable-nonfree \
  --enable-libfreetype \
  --enable-libfontconfig \
  --enable-libharfbuzz \
  --enable-libfribidi \
  --enable-libx264 \
  --enable-libx265 \
  --enable-openssl

3️⃣ 验证 drawtext 是否被启用（必做）
grep DRAWTEXT ffbuild/config.mak


必须是：

CONFIG_DRAWTEXT_FILTER=yes

4️⃣ 编译安装
make -j$(nproc)
make install

五、你这次踩坑的“真实原因总结”

这次问题不是你操作水平问题，而是 FFmpeg 的一个典型坑：

./configure 不会报错

依赖缺失时会静默禁用 drawtext

只有去看 ffbuild/config.mak 才能发现

你这次已经完整走过一次“源码级排错路径”，以后再遇到类似问题（x264 / x265 / ass / vmaf）都会很快定位。

六、最终结论

✔ 你现在这套 FFmpeg 7.1 是完全可用的
✔ drawtext 已正确编译
✔ 不需要再删、不需要重装
✔ 可以直接进入业务使用阶段

如果你后面要做的是：

PHP 调 ffmpeg

批量加水印 / 字幕

动态时间 / 变量文本

性能调优（多核 / preset）

直接说一句 “下一步我想做 XX”，我按你实际业务给你方案。