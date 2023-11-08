# Metalへようこそ！
## イントロダクション

Metal Tutorialへようこそ。このチュートリアルでは、AppleのMetal GraphicsおよびCompute APIの基本を学び、C++を使ってmetal-cppライブラリでプログラムする方法を理解するお手伝いをします。Appleが[正式にリリースしたこのライブラリ](https://developer.apple.com/metal/cpp/)には、まだ十分なドキュメントがなく、いくつかの機能が欠けていますので、次の章でそれらをどのように回避するかをお見せします。これは、コンピュータグラフィックスへのガイドや導入というよりも、C++を使用してMetalを使い始める方法として役立つでしょう。初心者の方には、できるだけ詳細に説明し、必要に応じて他の既存のガイドへのリンクも提供します。このチュートリアルが皆さんに役立てることを願っています。このチュートリアルシリーズに自分のコンテンツを追加したい方や、私が行ったミスを修正したい方は、GitHubリポジトリを[こちらから](https://github.com/wmarti/MetalTutorial)ご覧いただけます。

## Metalのドキュメンテーションとその他の有用なリソース
ここでは、これらのチュートリアルを完了するとき、および一般的にMetalを使用するときに役立つと思われるリソースをいくつか紹介します：
### 公式Apple Metalドキュメンテーション
- [Metal Documentation](https://developer.apple.com/documentation/metal)
- [Metal Specification](https://developer.apple.com/metal/Metal-Shading-Language-Specification.pdf)
- [テクスチャの作成とサンプリング](https://developer.apple.com/documentation/metal/creating_and_sampling_textures)
- [スレッドとスレッドグループの作成](https://developer.apple.com/documentation/metal/creating_threads_and_threadgroups)

### 有用なMetalリソース
- [Metal Compute入門](https://eugenebokhan.io/introduction-to-metal-compute-part-four)
- [定数対デバイスアドレス空間](https://stackoverflow.com/questions/59010429/what-the-purpose-of-declaring-a-variable-with-const-constant)
- [Metalでの「参照渡し」](https://stackoverflow.com/questions/39266789/glsl-out-in-the-argument)
- [Metalベストプラクティスガイド（Drawables）](https://developer.apple.com/library/archive/documentation/3DDrawing/Conceptual/MTLBestPracticesGuide/Drawables.html#//apple_ref/doc/uid/TP40016642-CH2-SW1)
- [Metal-CPPについてのRedditの議論](https://www.reddit.com/r/GraphicsProgramming/comments/qzyqjz/metalcpp_is_a_lowoverhead_c_interface_for_metal/)

### コンピュータグラフィックスの基本
- [線形代数](https://www.3blue1brown.com/topics/linear-algebra)

### レイトレーシング
- [GPUレイトレーシング：1日でできる基本](https://roar11.com/2019/10/gpu-ray-tracing-in-an-afternoon/)
- [GPUレイトレーシング：週末でできる基本](https://scribe.citizen4.eu/@jcowles/gpu-ray-tracing-in-one-weekend-3e7d874b3b0f)
- [CUDA Compute レイトレーシング](https://developer.nvidia.com/blog/accelerated-ray-tracing-cuda/)
- [GPU加速パストレーサー（半球/ランダム）](https://bheisler.github.io/post/writing-gpu-accelerated-path-tracer-part-2/)
- [乱数生成とサンプリング（半球上など）](https://cseweb.ucsd.edu/classes/sp17/cse168-a/CSE168_07_Random.pdf)
