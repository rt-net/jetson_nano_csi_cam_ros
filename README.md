# jetson_nano_csi_cam

Jetson Nano DevKit B01 + dual CSI cameraのROSドライバです。

![](https://rt-net.github.io/images/jetson-nano/jetson_nano_dual_csi.jpg)

このROSパッケージはJetson Nano DevKit B01に取り付けたCSI camera（1つまたは2つ）の画像を[GStreamer](https://github.com/GStreamer/gstreamer)または[Jetson Linux Multimedia API](https://docs.nvidia.com/jetson/l4t-multimedia/index.html)経由で取得し、ROSの[sensor_msgs/Image](http://docs.ros.org/api/sensor_msgs/html/msg/Image.html)として配信するためのものです。  

launchファイルで[`gscam`](http://wiki.ros.org/gscam)を呼び出し、GStreamerまたはJetson Linux Multimedia APIを経由して

* 解像度とフレームレートの設定
* カメラのキャリブレーション
* 複数のCSIカメラ画像の取得・配信

を実現しています。

---

## インストール方法

`jetson_nano_csi_cam`を動かすためには本リポジトリとその依存関係にあるソフトウェアをダウンロードします。

`gscam`の詳細については、[ROS Wiki](http://wiki.ros.org/gscam)または[ros-drivers/gscam@GitHub](https://github.com/ros-drivers/gscam)を参照してください。

以下のソフトウェアがインストールされたNVIDIA Jetson Nano DevKit B01に[SainSmart IMX219 Camera Module for NVIDIA Jetson Nano Board (160 Degree FoV)](https://www.sainsmart.com/products/sainsmart-imx219-camera-module-for-nvidia-jetson-nano-board-8mp-sensor-160-degree-fov)を2つ接続して動作確認をしています。

* [L4T R32.4.2](https://developer.nvidia.com/embedded/linux-tegra-r32.4.2) + [ROS Melodic](http://wiki.ros.org/melodic)

### 依存関係

* GStreamer-1.0 または Jetson Linux Multimedia API（JetPackとともにインストールされます）
* ROS Melodic
* GStreamer-1.0をサポートした`gscam`

### 1. `jetson_nano_csi_cam`のダウンロード

このリポジトリを`catkin_ws`にダウンロードします。

```
cd ~/catkin_ws/src
git clone https://github.com/rt-net/jetson_nano_csi_cam_ros.git 
```

### 2. `gscam`のダウンロードとGStreamer-1.0対応

`gscam`を`catkin_ws`にダウンロードします。

```
cd ~/catkin_ws/src
git clone https://github.com/ros-drivers/gscam.git
```

ダウンロード後、`./gscam/Makefile`を編集してCMakeのオプションを変更します。以下のように`-DGSTREAMER_VERSION_1_x=On`を追加します。

    EXTRA_CMAKE_FLAGS = -DUSE_ROSBUILD:BOOL=1 -DGSTREAMER_VERSION_1_x=On

ダウンロードしてきた`gscam`ディレクトリ内で以下のコマンドを実行すると簡単に編集できます。

```
sed -e "s/EXTRA_CMAKE_FLAGS = -DUSE_ROSBUILD:BOOL=1$/EXTRA_CMAKE_FLAGS = -DUSE_ROSBUILD:BOOL=1 -DGSTREAMER_VERSION_1_x=On/" -i Makefile
```

### 3. ビルド＆セットアップ

`jetson_nano_csi_cam`と`gscam`をビルドしセットアップします。

```
cd ~/catkin_ws
catkin build
source devel/setup.bash
```

---

## 使い方

### Quick Start

CAM0として接続されたカメラストリームのデータを`/csi_cam_0/image_raw`のROSトピックとして配信するには以下のコマンドを端末で実行します。

```
roslaunch jetson_nano_csi_cam jetson_csi_cam.launch sensor_id:=0 width:=<image width> height:=<image height> fps:=<desired framerate>
```

CAM0とCAM1に接続されたカメラストリームのデータをそれぞれ`/csi_cam_0/image_raw`と`/csi_cam_1/image_raw`のROSトピックとして同時に配信するには以下のコマンドを実行します。

```
roslaunch jetson_nano_csi_cam jetson_dual_csi_cam.launch width:=<image width> height:=<image height> fps:=<desired framerate>
```

### 映像取得・配信

#### 映像配信

ROSトピックとしてカメラの映像を配信するには以下のコマンドを実行します。

```
roslaunch jetson_csi_cam jetson_csi_cam.launch
```

このlaunchでは配信用のノードを起動するだけです。配信されている映像を確認するには何かしら別の手段を利用します。  
映像が配信されているかを簡単に確認するには、端末を起動して`rostopic list`を実行し、配信中のROSトピック一覧から`/csi_cam_0/image_raw`という名前のトピックを探します。

#### オプション

`roslaunch`する際のオプションで映像配信のパラメータを決めることができます。

```
roslaunch jetson_csi_cam jetson_csi_cam.launch width:=1920 height:=1080 fps:=15
```

その他の引数については`roslaunch`の際に`<arg_name>:=<arg_value>`形式でオプションを指定できます。

##### `jetson_csi_cam.launch`の引数

* **`sensor_id`** (default: `0`) -- カメラのID
* **`width`** (default: `480`) -- 配信する映像の横幅
* **`height`** (default: `270`) -- 配信する映像の高さ
* **`cap_width`** (default: `1920`) -- カメラから取得する映像の横幅
* **`cap_height`** (default: `1080`) -- カメラから取得する映像の高さ
* **`fps`** (default: `30`) -- 配信するフレームレート（解像度次第ではこのフレームレートに満たない場合があります）
* **`cam_name`** (default: `csi_cam_$(arg sensor_id)`) -- `camera info`に対応したカメラ名
* **`frame_id`** (default: `/$(arg cam_name)_link`) -- tfに使用するカメラのフレーム名
* **`sync_sink`** (default: `true`) -- [appsink](https://gstreamer.freedesktop.org/documentation/app/appsink.html?gi-language=c)を同期設定（フレームレートを低く設定して問題が起きたときにこのオプションを`false`にすると、問題が解決する場合があります）
* **`flip_method`** (default: `0`) -- 映像配信する際の画像の反転オプション

### 映像配信のテスト

#### カメラ映像の確認

簡単にカメラ映像を確認するには、GNOME等のデスクトップ環境で端末を起動して`rqt_img_view`を実行します。  
起動した画像ビューアの左上のプルダウンメニューからカメラ映像のトピックを選択します。
`jetson_csi_cam.launch`のデフォルト設定の場合は`/csi_cam_0/image_raw`です。

![](https://rt-net.github.io/images/jetson-nano/csi_cam_rqt_image_view.png)

#### フレームレートの計測

次のコマンドでROSトピックの更新頻度を確認できます。

```
rostopic hz /csi_cam_0/image_raw
```

カメラ映像のROSトピックの更新頻度 == 配信されている映像のフレームレートではありませんが、ほぼ一致します。
設定したフレームレートよりも低い場合は以下の原因が考えられます。

* Jetson Nanoの[PowerManagement](https://www.jetsonhacks.com/2019/04/10/jetson-nano-use-more-power/)がパフォーマンスを制限するモードになっている
* Jetson Nanoと映像を受信しているコンピュータ間のネットワークが不安定
* 接続しているカメラモジュールの最大フレームレート以上の値を指定した

### カメラのキャリブレーション
`jetson_nano_csi_cam`はカメラのキャリブレーションを簡単にできるようにカメラ情報もROSトピックとして配信しています。  
カメラ情報を実際に使用しているカメラに合わせるにはROS Wikiの[monocular camera calibration guide](http://wiki.ros.org/camera_calibration/Tutorials/MonocularCalibration)に従ってキャリブレーションしてください。キャリブレーションをしなくてもカメラ映像の配信は可能です。
その際、以下の情報を参考にしてください。

1. ROS Wikiの説明にあるようにチェッカーボードの印刷が必要です。

2. [映像配信](#映像配信)にて説明した`roslaunch`コマンドでカメラの映像配信をします。

3. `image`と`camera`オプションとチェッカーボードのサイズを以下のコマンドのように指定し、キャリブレーションを行います。

```
rosrun camera_calibration cameracalibrator.py --size 8x6 --square <square size in meters> image:=/csi_cam_0/image_raw camera:=/csi_cam_0
```

カメラに映る範囲内である程度チェッカーボードを動かすと「CALIBRATE」ボタンが押せるようになるので、キャリブレーションファイルを書き出します。

![](https://rt-net.github.io/images/jetson-nano/camera_calibration.png)

## ライセンス

(C) 2020 RT Corporation

各ファイルはライセンスがファイル中に明記されている場合、そのライセンスに従います。特に明記されていない場合は、Apache License, Version 2.0に基づき公開されています。  
ライセンスの全文は[LICENSE](./LICENSE)または[apache.org/licenses/LICENSE-2.0](https://www.apache.org/licenses/LICENSE-2.0)から確認できます。

### 謝辞

* [peter-moran/jetson_csi_cam](https://github.com/peter-moran/jetson_csi_cam)
    * Copyright (c) 2017 Peter Moran
    * MIT License
    * https://github.com/peter-moran/jetson_csi_cam/blob/b4d839bdfca0e2714103c1d2fe3750f3a8f36832/LICENSE

## 関連資料

* [Accelerated GStreamer documentation on NVIDIA Jetson Linux Developer Guide](https://docs.nvidia.com/jetson/l4t/index.html#page/Tegra%2520Linux%2520Driver%2520Package%2520Development%2520Guide%2Faccelerated_gstreamer.html%23)
* [Power Management for Jetson Nano and Jetson TX1 Devices on NVIDIA Jetson Linux Developer Guide](https://docs.nvidia.com/jetson/l4t/index.html#page/Tegra%20Linux%20Driver%20Package%20Development%20Guide/power_management_nano.html)