const { environment } = require("@rails/webpacker");

// resolve-url-loader must be used before sass-loader
environment.loaders.get("sass").use.splice(-1, 0, {
  loader: "resolve-url-loader",
  options: {
    attempts: 1
  }
});

const config = environment.toWebpackConfig();
config.devtool = "none";

module.exports = environment;