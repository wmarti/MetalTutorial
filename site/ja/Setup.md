title: Lesson 0: セットアップ
comments: true

# `metal-cpp`とXcodeのセットアップ

iOSベースのデバイスやMacOSでMetalコードを書くためには、ほとんどの場合Xcodeが必要になります。Appleデバイス向けの開発は他のエディタでも行うことができますが、Appleのエコシステム内での開発に特化して作られたXcodeを使用することが推奨されます。まだお持ちでない場合は、 [Mac App Store](https://apps.apple.com/us/app/xcode/id497799835?mt=12)から無料でダウンロードできます。

**metal-cppやGLFWのセットアッププロセスを経ることなく進めたい方は、GitHubから[Lesson 0](https://github.com/wmarti/MetalTutorial/tree/Lesson_0)をクローンして、プロジェクトを設定済みの状態で始めてください。それ以外の方は、この記事を読み進めてください！**

Metalは、Objective-Cというプログラミング言語で書かれることを想定して設計されています。Objective-Cは、AppleのSwiftプログラミング言語とともに、macOSやiOSアプリケーションを書くために通常使用される言語です。しかし、このチュートリアルシリーズでは、コンピュータグラフィックス関連のアプリケーションを書く際の業界標準であるC++を主に使用してアプリケーションを作成します。これには、ビデオゲームでのリアルタイムレンダリングやCADソフトウェアなどが含まれます。私が「主に」と言うのは、実際には「Objective-C++」というものを少し使って、Objective-CのコードとC++を混ぜることで、私たちにとって少し簡単になるからです。Metalは通常、純粋なObjective-Cで書かれるものですが、便宜上Appleは、Metal Graphics APIとのインターフェースとして機能するC++バインディングのセットをリリースしており、これによってAppleデバイス向けの高性能なグラフィックスおよびコンピュートアプリケーションを（ほぼ）純粋なC++で書くことができます。このラッパーは非常に軽量であり、ネイティブのObjective-C関数呼び出しとC++との間で一対一の変換を行います。ライブラリは[こちらから](https://developer.apple.com/metal/cpp/)ダウンロードしなければいけません。

metal-cppライブラリをダウンロードしたら、Xcodeを開いて新しいXcodeプロジェクトを作成します。このチュートリアルではMacデバイスを対象としているので、macOSテンプレートの下でコマンドラインツールを選択します。これにより、デフォルト言語がC++に設定され、空のHello-Worldプロジェクトが作成されます。

まず最初にやりたいことは、ダウンロードして解凍したばかりの'metal-cpp'フォルダをXcodeプロジェクトにドラッグアンドドロップすることです。

![image](/en/images/metal-cpp.gif){ loading=lazy }

プロジェクトにコピーしたら、Xcodeがそれを見つけられるように設定する必要があります。プロジェクトターゲットのBuild Settingsセクションで、Search Pathsの下にあるヘッダーサーチパスにmetal-cppフォルダを追加します。

````
$(PROJECT_DIR)/metal-cpp
````

![header](/en/images/header_search_paths.png){loading=lazy}

次にすべきことは、Metalを使うために必要なAppleのフレームワークとリンクすることです。Build Phasesセクションに移動し、Link Binary With Librariesの下で、次の3つのフレームワークを追加します。
````
Foundation.framework
Metal.framework
QuartzCore.framework
````

![linking](/en/images/linking.png)

これで、Metalが使えるようになります。Appleのmetal-cppガイドによると、.cppファイルのうち1つだけでmetal-cppの実装を定義する必要があります。このために、mtl_implementation.cppという新しいファイルを作成し、必要なdefineとinclude文を記述します。

````cpp
//  mtl_implementation.cpp
#define NS_PRIVATE_IMPLEMENTATION
#define CA_PRIVATE_IMPLEMENTATION
#define MTL_PRIVATE_IMPLEMENTATION
#include <Foundation/Foundation.hpp>
#include <Metal/Metal.hpp>
#include <QuartzCore/QuartzCore.hpp>
````

main.cppファイルに戻って、Metalのインクルードを追加し、デフォルトデバイスを作成します。

````cpp
//  main.cpp
#include <Metal/Metal.hpp>
...
int main() {
    ...
    MTL::Device* device = MTL::CreateSystemDefaultDevice();
    ...
}
````
これで、ビルドして実行できます。
![ready](/en/images/ready.png)

すべてがスムーズに進んだ場合、XcodeのコンソールにMetal API Validationなどに関する出力が表示されるはずです。表示されない場合は、すべての手順が正しく実行されていることを確認してください。

# Window作成のためのGLFWのセットアップ

Metalのグラフィックスレンダリング機能を使用するには、アプリケーションをレンダリングするウィンドウが必要です。ここでGLFWというクロスプラットフォームのウィンドウライブラリが登場します。通常はOpenGLグラフィックスAPIと併用されますが、この機能を無効にしてMetalで使用できるようにします。簡単に言うと、ウィンドウの作成やキーボード/マウス/コントローラーの入力処理を簡単に行えるようになります。MacOSにはCocoaフレームワークの一部である独自のウィンドウライブラリがありますが、それの使い方がわからず、GLFWを設定し、Cocoaウィンドウのうち必要な部分を約5行のコードで公開できるようになります。

GLFWを取得する方法はいくつかあります。一つの方法は、glfwのウェブサイトで[macOS用の事前コンパイル済みバイナリ](https://www.glfw.org/download.html)をダウンロードすることです。これは、[Lesson 0](https://github.com/wmarti/MetalTutorial/tree/Lesson_0)からGitHubリポジトリで設定した方法です。IntelやM1以降のMacでサポートされているGLFWの事前コンパイル済みユニバーサルバイナリを使用したい場合は、そちらのプロジェクトをクローンしてください。

別の方法として、`brew`パッケージマネージャーを使って取得することができます。ここではそれを紹介します。`brew`をお持ちでない場合は、こちらから入手できます：[brew.sh](https://brew.sh/)。Macでのソフトウェア開発に非常に便利なツールです。Debian Linuxディストリビューションの`apt-get`のようなものです。

brewをインストールしたら、次のターミナルコマンドでglfwをインストールできます。
````
brew install glfw
````
次に、brewのヘッダー`include`ディレクトリをXcodeのヘッダー検索パスに追加して、XcodeがGLFWのヘッダーファイルを見つけられるようにします。

Macの種類がわからない場合は、画面左上のロゴをクリックし、「このMacについて」を選択してチップタイプを確認してください。

M1 Macをお使いの場合、私と同じように、Xcodeターゲットの`Build Settings`セクションにこのディレクトリを追加できます。
````
/opt/homebrew/Cellar/glfw/...version_goes_here.../include
````
![image](/en/images/glfw_include.png)

あるいは、Intel Macをお使いの場合、brewはパッケージを`/usr/local`ディレクトリにインストールします。それに応じて、代わりにこのディレクトリを使用できます。
````
/usr/local/Cellar/glfw/...version_goes_here.../include
````

次に、glfwのダイナミックライブラリとリンクします。`Build Phases`の下、`Link Binary With Libraries`の下で、+アイコンをクリックし、`Add Other`を選択し、`Add Files`...を選択します。Finder Windowが開きます。
![image](/en/images/finder.png)

ウィンドウが開いた状態で、同時にこれらの3つのキーを押します： ++command+shift+g++. M1 Macの場合：
````
/opt/homebrew/Cellar/glfw/...version_goes_here.../lib
````
Intel Macの場合：
````
/usr/local/Cellar/glfw/...version_goes_here.../lib
````
Select `libglfw.3.3.dylib`:
![image](/en/images/libglfw.png)

これでGLFWを使う準備が整いました！