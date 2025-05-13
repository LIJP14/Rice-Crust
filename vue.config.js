const { defineConfig } = require('@vue/cli-service');
const path = require("path");

// 混淆打包
const WebpackObfuscator = require("webpack-obfuscator");

module.exports = defineConfig({
    transpileDependencies: true,
    publicPath: '/public/xx',
    configureWebpack: {
        resolve: {
            alias: {
                '@img': path.join(__dirname, 'src/assets/img'),
            }
        },

        module: {
            // 打包，删除版本号
            rules: [
                {
                    test: /\.js$/,
                    use: [
                        {
                            loader: 'string-replace-loader',
                            options: {
                                search: /(version\s*[:=])\s*["'][^"']+["']/g, // 正则表达式匹配: version = "1.2.10" 或 version: "1.2.10"
                                replace: '$1""', // 版本号替换为空
                                flags: 'g' // 全局匹配
                            }
                        },
                        {
                            loader: 'string-replace-loader',
                            options: {
                                search: /(v\d+\.\d+(\.\d+))/g, // 正则表达式匹配: "v1.2.34"
                                replace: '', // 将其替换为空，即删除
                                flags: 'g' // 全局匹配
                            }
                        },
                    ]
                }
            ]
        },

        // 混淆打包
        plugins: process.env.NODE_ENV === 'production' ? [ new WebpackObfuscator() ] : []
    },
    chainWebpack: config => {
        config.module
            .rule('svg')
            .exclude.add(path.join(__dirname, 'src/assets/IconSvg'))
            .end();

        config.module
            .rule('iconSvg')
            .test(/\.svg$/)
            .include.add(path.join(__dirname, 'src/assets/IconSvg'))
            .end()
            .use('svg-sprite-loader')
            .loader('svg-sprite-loader')
            .options({ symbolId: 'icon-[name]' })
            .end();



        config.module
            .rule('images')
            .exclude.add(path.join(__dirname, 'src/assets/IconImg'))
            .end();
        config.module
            .rule('IconImg')
            .test(/\.(png|jpg)/)
            .include.add(path.join(__dirname, 'src/assets/IconImg'))
            .end()
            .use('url-loader')
            .loader('url-loader')
            .options({
                limit: 1024 * 15,
                esModule: false,
            })
            .end();


        // // 删除版本号，在 chainWebpack 中的配置，
        // // 在这里设置，替换的不全，会漏掉部分版本号
        // // 在 configureWebpack 中配置的，替换的全
        // config.module
        //     .rule('js')
        //     .use('string-replace-loader')
        //     .loader('string-replace-loader')
        //     .tap(options => {
        //         return {
        //             search: /(version\s*[:=])\s*["'][^"']+["']/g, // 正则表达式匹配version=
        //             replace: '$1""', // 将其替换为空，即删除
        //             flags: 'g' // 全局匹配
        //         };
        //     })
        //     .end();


    }
});
