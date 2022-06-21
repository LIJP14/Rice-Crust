const { defineConfig } = require('@vue/cli-service')
const path = require("path");
module.exports = defineConfig({
    transpileDependencies: true,
    publicPath: '/public/xx',
    configureWebpack: {
        resolve: {
            alias: {
                '@img': path.join(__dirname, 'src/assets/img'),
            }
        },
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


    }
});
