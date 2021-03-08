---
title: webpack 4.0
date: 2020-01-12 13:25:01
subtitle: webpack4
tags:
  - webpack
categories: [web]
---
随着前端的开发复杂度越来越庞大，简单的前端开发已经不满足我们需求了，一些代码浏览器并不能进行识别(如jsx、es6、vue...)，只有编译成浏览器能识别的才能使用，那么如果前端开发不使用打包工具，开发效率会大幅下降。而在众多的工具中 webpack 便是较为流行的前端构建工具。
webpack 可以看做是模块打包机：它做的事情是，分析你的项目结构，找到 JavaScript 模块以及其它的一些浏览器不能直接运行的拓展语言（Scss，TypeScript等），并将其打包为合适的格式以供浏览器使用。

<!-- more -->

## webpack-cli
自从 webpack `4.0+` 之后，我们使用 webpack 还需要安装 webpack-cli 用于提供 webpack 的命令行工具。使用下面的命令进行安装：
```
npm install --save-dev webpack webpack-cli
```
也可以进行全局安装如下：
```
npm install -global webpack
```
可以使用 **webpack -v** 查看版本。
全局安装完成后，可以新建一个文件 **/src/index.js**:
```javascript
let global = () => {
    console.log('hello word');
}
global();
```
一个简单的 es6 语法，下面使用 webpack 打包，执行 **webpack** 命令，可以看到打包的一些信息，默认webpack 会打包 **/src/index.js** 文件，输出到 **/dist/main.js** 文件，当然我们也可以自己配置，例如执行下面的命令 **webpack ./src/index.js --output ./dist/index.js** 便能把指定的文件打包到指定路径。
> 官网并不太推荐全局进行安装，全局安装不容易管理和升级项目。我们也可以使用 **node_modules/.bin/webpack** 指定相应的 webpack 进行打包处理(当然也可以使用npx解决)。

## mode
告诉webpack打包模式，以便于内置优化。主要有下面几种模式：
- production：告诉webpack执行生产模式打包，也就是需要把项目发布到服务器上。
- development：开发模式，我们本地的调试，需要一些日志插件、浏览器插件等调试工具。
- none：退出任何默认优化选项。

我们这些执行进行打包：**webpack --mode=development ./src/index.js --output ./dist/index.js**

## scripts
由于上方的 webpack 打包命令过长，运行并不好使，我们可以在 package.json 添加配置，执行 **npm init -y** 初始化，然后再 **scripts** 属性添加配置：
```json
{
  ...
  "scripts": {
    "dev": "webpack --mode=development ./src/index.js --output ./dist/index.js"
  },
  ...
}
```
执行下面的命令启动 **yarn dev**。

## webpack.config.js
上面都是在启动命令上添加参数，但项目开发最好还是需要config文件配置，而不是启动命令行进行配置。然后我们可以配置启动入口、和输出入口、打包模式等：
```javascript
const path = require('path');

module.exports = {
    entry: "./src/index.js",
    output: {
        path: path.resolve(__dirname, 'dist'),
        filename: "app.bundle.js"
    },
    mode: 'development'
}
```
这样配置便完成了，然后去掉打包命令的参数：
```json
{
  ...
  "scripts": {
    "dev": "webpack"
  },
  ...
}
```
即可自动读取config文件，添加打包的配置。

> webpack默认的配置文件为 **webpack.config.js** ，我们也可以使用 **webpack --config webpack.config.js** 修改配置文件默认路径。

## 多入口
项目有时需要多个入口文件，我们可以修改webpack.config.js文件，用于配置入口文件：
```javascript
const path = require('path');

module.exports = {
  entry: {
    app: './src/index.js',
    hello: './src/hello.js'
  },
  output: {
    path: path.resolve(__dirname, 'dist'),
    filename: "[name].bundle.js"
  },
  mode: 'development'
}
```
入口提供了多个，打包到dits目录[name].bundle.js文件。
> [name] 为项目入口文件的name，例如 app：'./src/index.js' 文件，那么打包输出的便是 app.bundle.js 文件。

## Loaders
webpack进行文件编译的主要配置。webpack可以通过对文件类型进行匹配，对匹配到的文件进行相应的 loading 插件处理，比如处理 scss 有 scss-loader、less 有 less-loader、es6 有 babel、css 有 css-loader、vue-loader...

### babel
随着es6越来越火，前端开发也逐渐进行使用，但是浏览器五花八门，有些较好的浏览器开始逐渐识别es6，但是还有一些并不能识别es6，这给前端开发带来许多问题。这时 babel 便出现解决这些问题了，它可以将 es6 代码转换为浏览器可以正常识别的代码，很优雅解决了浏览器不能识别 es6 不能被浏览器识别的问题，并且还可以和webpack进行结合，使项目更加自动化。
那么怎么结合呢?我们可以看下webpack的[GitHub](https://github.com/webpack/webpack)，提供了和一系列插件结合的方法。babel 通过 [babel-loader](https://github.com/babel/babel-loader) 和 webpack 进行结合。

babel-loader主要提供了下面几个插件：
- `@babel/core`：babel的核心库。
- `babel-loader`：webpack和babel结合需要的插件。
- `@babel/preset-env`：babel 对es6的常用解析插件集合(可以配置按需加载)。

但是安装完成后，根据官网给出的提示复制进 `webpack.config.js`，发现并没有解析 es6 中的代码，这是为什么呢？经过研究发现 babel 如果要解析特点 es6 代码，需要插件的支持，把es6代码主要分为很多类：
- `@babel/plugin-transform-arrow-functions`：箭头函数转换为普通的函数
- `@babel/plugin-transform-classes`： 解析class。
- `@babel/plugin-proposal-decorators`： 解析项目的注解。
- ...

可以根据自己需求选择所需插件，执行下面命令进行安装：
```javascript
yarn add @babel/plugin-transform-arrow-functions
```
安装完成后，我们添加 babel 配置 `.babelrc` 文件，但是我们每一个 es6 都这样配置会非常的麻烦，那么有没有一个已经完成的插件，可以将es6语法常用的插件添加进去。肯定有的：
- `@babel/preset-env`：将es6常用的语法插件加入到项目中。

我们这么配置即可：
```javascript
{
  "presets": [
    "@babel/preset-env"
  ],
  "plugins": []
}
```
即可将 es6 转换为浏览器能识别的 es5 代码。

> **@babel/preset-env**不是es6所有的语法插件，比如注解插件(@babel/plugin-proposal-decorators)便没有，我们可以根据官网将 **debug**设置为`true`来查看具体包含哪有插件。

#### @babel/polyfill
上面已经介绍了 **@babel/preset-env** 可以将 es6 语法解析为浏览器能识别的 es5 语法，如果我们使用es6箭头函数( => )，是正常可以转换的，但是如果使用别的es6语法呢？例如：
```javascript
Object.assign({})

Array.from([1, 2, 3])

new Promise(resolve => console.log('promise'))
```
然后将 `devtool` 设置为 `false`，方便我们看打包之后的代码，最后惊奇的发现，wdnmd就转换了一个箭头函数，其余的完全复制过来了，老版本浏览器肯定不能识别的，那么该如何解如何形成的、又该如何决、怎么解决呢、怎么使用？
1. `问题如何形成`：形成是因为Babel默认只转换新的JavaScript语法(比如箭头函数)，但是转化不了新的API(Iterator、Generator、Set、Maps、Proxy、Reflect、Symbol、Promise等全局对象)，以及一些定义在全局对象上的方法(Object.assign)都不会转码，所以造成了该问题。
2. `如何解决`：可以使用 polyfill 来解决，它的解决方式便是在window上定义全局属性，以后调用便是调用window上的方法，这样便解决这个问题。
3. 我们要使用 polyfill 使它在源代码之前运行，让他成为一个 dependency(生成环境) 的依赖。首先安装依赖：
```javascript
npm install --save @babel/polyfill
```
安装成功后，有两种使用方式：
1. 在 webpack.config.js 定义打包配置：
	```javascript
	...
	module.exports = {
	  entry: ["@babel/polyfill", './src/index.js'],
	}
	```
2. 修改 .babelrc 文件 babel 打包方式：
	```javascript
	...
	{
	  "presets": [["@babel/preset-env", { "debug": true, "useBuiltIns": "entry" }]],
	  "plugins": []
	}
	```
配置`useBuiltIns`属性便可，然后在需要的文件引入 **import "@babel/polyfill"** 这样便完成了。但是由于每个文件都需要引入 **@babel/polyfill** 并且打包面积过大，它是将所有的依赖都加载进去，这样我们项目便会过大，如果需要根据自己的需求进行按需加载该如何配置呢？很简单只需将 **useBuiltIns** 属性设置为 **usage** 即可(设置为usage后，界面需要引入@babel/polyfill 依赖)，这样便在打包前添加了 **@babel/polyfill** 处理文件。

#### @babel/runtime
上面说了 **@babel/polyfill** 解决babel打包的一些问题，但是它解决问题的同时也代码很多的问题例如：
- `全局变量污染`：由于它解决问题是在全局变量上定义属性，很容易造成全局变量的污染，比如它在全局变量定义了一个Promise，而一些其他的库也需要定义Promise，这便造成了冲突。
- `修改全局对实例的方法`：由于它为了解决全局实例问题(Array.form、Object.assign)，它是之间在全局实例定义方法这也可能造成以后的代码冲突。

总体来说便是 **@babel/polyfill** 可以解决我们的问题，但是其侵入性过强。那么我们还有别的更优的选择吗? [@babel/runtime](https://www.babeljs.cn/docs/babel-runtime) 便可以解决这样的问题，至于它如何解决并和@babel/polyfill的差异可以看下知乎大牛的[文章](https://zhuanlan.zhihu.com/p/58624930)。
这里简单说下如何使用。首先安装:
```javascript
npm install --save @babel/runtime
```
但是为了避免一些代码的重复(代码可能会有多个文件)我们还需要搭配一个插件:
```javascript
npm install --save-dev @babel/plugin-transform-runtime
```
然后修改 .babelrc 文件:
```javascript
{
  "presets": [['@babel/preset-env', { "debug": true }]],
  "plugins": [
    [
      "@babel/plugin-transform-runtime",
      {
        "corejs": 2,
        "helpers": true,
        "regenerator": true,
        "useESModules": false
      }
    ]
  ]
}
```
发现还需要安装`@babel/runtime-corejs2`主要添加项目对Promise的打包支持:
```javascript
npm install --save @babel/runtime-corejs2
```
最后打包项目，果然全局变量没有那些属性了，并且是按需加载。

### css-loader & style-loader
css样式是前端开发不可缺少的文件，但是一些css样式需要添加浏览器内核前缀，例如`-moz-`、`-webkit-`、`-o-`...这些前缀都非常统一，那么我们可以不可以使用一个插件让其自动给某些属性添加浏览器前缀，并且还可以为我们压缩 css 空格，减少代码体积等，那么 [css-loader](https://github.com/webpack-contrib/css-loader) 和 [style-loader](https://github.com/webpack-contrib/style-loader) 会是个不错的选择。
执行下面的命令安装：
```javascript
npm install --save-dev style-loader css-loader
```
然后添加webpack配置:
```javascript
...

module.exports = {
  ...
  module: {
      rules: [
      ..., {
          test: /\.css$/,
          use: ['style-loader', 'css-loader']
      }]
  },
  ...
}
```
注意执行顺序为 **从右到左**，也就是 css-loader 处理后交给 style-loader。

### sass-loader & less-loader
现在前端预编译样式也是使用者越来越多，但是浏览器并不支持这种语言，也需要webpack插件[sass-loader](https://github.com/webpack-contrib/sass-loader) 和 [less-loader](https://github.com/webpack-contrib/less-loader) 进行相应的解析，它们可以把 scss 或 less 解析为css。
这里只介绍less如何编译，至于scss其实方式一样，只是依赖插件不同。
安装插件：
```javascript
npm install less less-loader --save-dev
```
成功后，设置webpack配置即可：
```javascript
...

module.exports = {
  ...
  module: {
      rules: [
      ..., {
        test: /\.less$/,
        use: ['style-loader', 'css-loader', 'less-loader']
      }]
  },
  ...
}
```
注意 webpack 执行顺序为从右向左，也就是 less-loader -> css-loader -> style-loader。顺序不要搞反了。

### file-loader & url-loader
主要用于处理项目中出现的文件，主要靠 [url-loader](https://github.com/webpack-contrib/url-loader) 和 [file-loader](https://github.com/webpack-contrib/file-loader) 处理项目的文件，这里已 file-loader 为例，首先安装：
```javascript
npm install file-loader --save-dev
```
成功后，设置webpack配置即可：
```javascript
...

module.exports = {
  ...
  module: {
      rules: [
      ..., {
        test: /\.(png|jpe?g|gif)$/i,
        use: [
          {
            loader: 'file-loader',
          },
        ],
      }]
  },
  ...
}
```
### image-webpack-loader
项目中的图片有时候大小过大，打包发布后在生产环境下并不太好的加载，这时我们便需要在打包时压缩一下项目的图片文件。执行下面的命令安装：
```javascript
npm install image-webpack-loader --save-dev
```
完成后，修改webpack配置文件：
```javascript
...

module.exports = {
  ...
  module: {
      rules: [
      ..., {
        test: /\.(png|jpe?g|gif|svg)$/,
        use: [
          {
            loader: 'file-loader',
            options: {
              name: '[name].[ext]',
              outputPath: 'images/'
            }
          },
          {
            loader: 'image-webpack-loader'
          }
        ]
      }]
  },
  ...
}
```

## plugins
上面介绍了 webpack 的 Loaders 主要用于解析项目的文件，将一些浏览器不支持的语法(less、scss、es6、jsx、vue...)解析为浏览器可以识别的，而 plugins 则可以给指定文件添加一些拓展。
### html-webpack-plugin
html 的拓展插件，可以拓展html的一些功能。例如：我们一般 js 和 css 都是添加 hash 防止浏览器缓存，造成 js 和 css 修改而浏览器不刷新的问题。但是添加 hash 后文件名称一直改变，所以我们需要使用`html-webpack-plugin`根据一个模板文件动态引入 js 和 css 文件。
首先只需下面命令进行安装：
```javascript
yarn add --dev html-webpack-plugin
```
成功后，在webpack进行配置：
```javascript
...
const HtmlWebpackPlugin = require('html-webpack-plugin');

module.exports = {
    ...
    plugins: [
      ...
      new HtmlWebpackPlugin({
          filename: './index.html',
          template: './public/index.html'
      })
    ]
}
```
很简单根据模板引入所需文件，它还有其他的一些配置，详细可以看下github上的[介绍](https://github.com/jantimon/html-webpack-plugin)。

> 也可以进行多界面的配置，可以靠 **chunks** 配置多入口，如果多个界面入口，可以使用该配置，较多用于项目前端一个入口、后端一个入口，最好不要太多的界面入口。

### mini-css-extract-plugin
应为 webpack 处理样式默认都是设置到了 style 上，但是项目样式一般都提取到一些样式文件(css)中，这些既有利于代码复用，也有利于调整项目的样式。我们可以使用 **mini-css-extract-plugin** 提取 style css 到一个文件中。
执行下面的命令进行安装：
```javascript
npm install --save-dev mini-css-extract-plugin
```
然后再webpack添加配置：
```javascript
...
...
const MiniCssExtractPlugin = require("mini-css-extract-plugin");
const devMode = process.env.NODE_ENV !== 'production';

module.exports = {
  ...
  module: {
    rules: [...,{
      test: /\.css$/,
      use: [
        devMode ? 'style-loader' : MiniCssExtractPlugin.loader,
        'css-loader'
      ]
    }]
  },
  plugins: [
    ...
    new MiniCssExtractPlugin({
      filename: devMode ? '[name].css' : '[name].[hash].css',
      chunkFilename: devMode ? '[id].css' : '[id].[hash].css',
    })
  ]
}
```
这样便根据条件进行判断，开发模式下继续使用 style-loader 不会生成css文件，生成环境下会使用 mini-css-extract-plugin 提取 style 到一些文件中。

### webpack-dev-server
项目的开发过程中，不能像上面代码，没修改一下都需要重新打包下，但是真实开发环境中需要开启服务，并监听代码的修改，一旦修改便自动刷新界面。这样便能大大的缩减项目的开发时间。
执行下面的命令安装：
```javascript
npm install webpack-dev-server --save-dev
```
然后修改启动命令：
```json
...
{
  ...
  "scripts": {
    "dev": "npx webpack-dev-server"
  },
  ...
}
```
我们还可以添加一下具体的配置，详细可以看下[github](https://github.com/webpack/webpack-dev-server)。

### clean-webpack-plugin
因为项目文件打包多半文件名打包之后名称含有hash值，这样一旦打包次数过多，会堆积许多hash文件，我们需要每次打包前令项目自己清空文件夹，然后放入打包之后的内容。
执行下面的命令安装：
```javascript
npm install --save-dev clean-webpack-plugin
```
然后修改启动命令：
```javascript
...
const { CleanWebpackPlugin } = require('clean-webpack-plugin');
let pathsToClean = [
  'dist'
];

module.exports = {
  ...
  plugins: [
    ...
    new CleanWebpackPlugin(),
  ]
}
```
我们还可以添加一下具体的配置，详细可以看下[github](https://github.com/webpack/webpack-dev-server)。

### webpackbar
webpack打包时生成进度条，方便查看webpack打包进度和打包时间。
执行下面命令安装：
```javascript
npm install webpackbar -D
```
修改webpack配置：
```javascript
...
const WebpackBar = require('webpackbar');

module.exports = {
  ...
  plugins: [
    ...
    new WebpackBar()
  ]
}
```

## devtool
主要用于项目的调试，可以在找错的时候给我们一些帮助(可以为我们生成 sourcemap，非常在开发模式下找出错误)。也就是设置项目打包之后的代码。它的值有下面很多种，具体用法可以看官网的[介绍](https://webpack.js.org/configuration/devtool/)，它的配置方式很简单，只需在webpack.config.js添加：
```javascript
...
module.exports = {
  ...
  devtool: ...
  ...
}
```